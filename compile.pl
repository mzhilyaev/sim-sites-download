#!/usr/bin/perl

use strict;
use Data::Dumper;
use JSON;
use HTML::ExtractMeta;
use XML::LibXML::Simple   qw(XMLin);
use Getopt::Long;


my $badTitles = {
 "Home" => 1,
 "Access Denied" => 1,
 "Google" => 1,
 "Suspicious Activity Detected" => 1,
 "Homepage" => 1,
 "Apache HTTP Server Test Page powered by CentOS" => 1,
 "Not Found" => 1,
 "Home Page" => 1,
 "Search" => 1,
 "Just a moment..." => 1,
 " Error " => 1,
 "Request Rejected" => 1,
 "Contact Us" => 1,
 "Access is denied." => 1,
 "Sign In" => 1,
 "Read Manga Online" => 1,
 "ProBoards" => 1,
 "Redirect" => 1,
 "An error has occurred" => 1,
 "Bad Request" => 1,
 "Landing" => 1,
 "(no title)" => 1,
};

my $badBegins = {
 "406" => 1,
 "404" => 1,
 "404" => 1,
 "404" => 1,
 "404" => 1,
 "401" => 1,
 "503" => 1,
 "500" => 1,
};

my $help;
my $dump;

if(
   !GetOptions (
            "help|h" => \$help ,
            "dump|d" => \$dump ,
   )
   || defined($help)
) {
  usage( );
}

sub usage {

   print "Usage $0 [OPTIONS] alexaPath simPath pagePath outputPath
            --help|-h - prints this help
            --dump|-d  - output full dump
            \n";
    exit 1;
}


my $alexaPath = @ARGV[0];
my $simPath = @ARGV[1];
my $pagePath = @ARGV[2];
my $outDir = @ARGV[3];

my $siteEntry = {};
my $sites = {};
my $titleMap = {};

sub readFile {
  my $file = shift;
  open(FILE, "< $file") || return;
  my $data = "";
  while(<FILE>) {
    $data .= $_;
  }
  close(FILE);
  return $data;
}

sub readAlexa {
  my $site = shift;
  my $data = readFile("$alexaPath/$site");
  if ($data) {
    my $xml = XMLin($data);
    # related
    if ($xml->{RLS}->{RL}) {
      if (ref($xml->{RLS}->{RL}) eq "ARRAY") {
        $siteEntry->{alexa}->{related} = [map {my $x = $_->{HREF}; $x =~ s/\/$//; $x} @{$xml->{RLS}->{RL}}];
      }
      elsif (ref($xml->{RLS}->{RL}) eq "HASH") {
        my $rel = $xml->{RLS}->{RL}->{HREF};
        $rel =~ s/\/$//;
        $siteEntry->{alexa}->{related} = [$rel];
      }
    }
    # dmoz
    if ($xml->{DMOZ}->{SITE}) {
      $siteEntry->{alexa}->{dmoz}->{title} = $xml->{DMOZ}->{SITE}->{TITLE};
      $siteEntry->{alexa}->{dmoz}->{descr} = $xml->{DMOZ}->{SITE}->{DESC};
      if (ref($xml->{DMOZ}->{SITE}->{CATS}->{CAT}) eq "ARRAY") {
        $siteEntry->{alexa}->{dmoz}->{cats} = [map {$_->{TITLE}} @{$xml->{DMOZ}->{SITE}->{CATS}->{CAT}}];
      }
      elsif (ref($xml->{DMOZ}->{SITE}->{CATS}->{CAT}) eq "HASH") {
        $siteEntry->{alexa}->{dmoz}->{cats} = [$xml->{DMOZ}->{SITE}->{CATS}->{CAT}->{TITLE}];
      }
    }
    # ranks
    if ($xml->{SD} && ref($xml->{SD}) eq "ARRAY") {
      my $sd = $xml->{SD}->[1];
      $siteEntry->{alexa}->{rank} = $sd->{POPULARITY}->{TEXT} + 0;
      $siteEntry->{alexa}->{reach} = $sd->{REACH}->{RANK} + 0;
      $siteEntry->{alexa}->{country} = $sd->{COUNTRY};
      $siteEntry->{alexa}->{country}->{RANK} = $siteEntry->{alexa}->{country}->{RANK} + 0;
    }
  }
};

sub readPage {
  my $site = shift;
  my $data = readFile("$pagePath/$site");
  if ($data) {
    my $em = HTML::ExtractMeta->new(
        html => $data, # required
    );
    my $image = $em->get_image_url;
    if ($image && $image =~ /^\/\//) {
      $image = "http$image";
    }
    $siteEntry->{page} = {
      title => $em->get_title,
      description => $em->get_description,
      image => $image,
      keywords => $em->get_keywords,
    };
  }
}

sub readSims {
  my $site = shift;
  open(FILE, "< $simPath/$site") || return;
  my $line1 = <FILE>;
  my $line2 = <FILE>;
  close(FILE);
  return if ($line1 =~ /Data Not Found/);
  my $jsn = decode_json($line1);
  $siteEntry->{sims}->{category} = {name => $jsn->{Category}, rank => $jsn->{CategoryRank}};
  $jsn = decode_json($line2);
  $siteEntry->{sims}->{related} = [map { {url => $_->{Url}, score => $_->{Score} + 0 } } @{$jsn->{SimilarSites}}];
  close(FILE);
}

sub titleOK {
  my $title = shift;
  return 0 if ($badTitles->{$title});
  my $beg = substr($title,0,3);
  return 0 if ($badBegins->{$beg});
  return 0 if (lc($title) =~ /error/);
  return 1;
}

sub procSiteEntry {
  my $site = shift;
  my $entry = {site => $site};

  return undef if (!$siteEntry->{alexa} || !$siteEntry->{sims});

  $entry->{title} = $siteEntry->{page}->{title};
  if ((!$entry->{title} || !titleOK($entry->{title})) && $siteEntry->{alexa}->{dmoz}) {
    $entry->{title} = $siteEntry->{alexa}->{dmoz}->{title}
  }
  return undef if (!$entry->{title} || $entry->{title} =~ /403 Forbidden/);

  $entry->{description} = $siteEntry->{page}->{description};
  if (!$entry->{description} && $siteEntry->{alexa}->{dmoz}) {
    $entry->{description} = $siteEntry->{alexa}->{dmoz}->{descr}
  }

  if ($siteEntry->{page}->{image}) {
    $entry->{image} = $siteEntry->{page}->{image};
  }
  $entry->{reach} = $siteEntry->{alexa}->{reach};
  $entry->{rank} = $siteEntry->{alexa}->{rank};

  if ($siteEntry->{alexa}->{country}) {
    $entry->{code} = $siteEntry->{alexa}->{country}->{CODE};
  }

  # deal with category and related sites
  if (!$siteEntry->{sims}->{category}) {
    return undef;
  }

  $entry->{category} = $siteEntry->{sims}->{category}->{name};

  return $entry;
}

sub procSite {
  my $site = shift;
  readAlexa($site);
  readPage($site);
  readSims($site);
  if (!$dump) {
    open(FILE, "> $outDir/$site");
    print FILE encode_json($siteEntry);
    close(FILE);
  }
  else {
    my $entry = procSiteEntry($site);
    if ($entry && !$titleMap->{$entry->{title}}) {
      $sites->{$site} = $entry;
      $titleMap->{$entry->{title}} = 1;
    }
  }

  $siteEntry = {};
}

while(<STDIN>) {
  my $site = $_;
  chomp($site);
  procSite($site);
}

if ($dump) {
  print encode_json($sites);
}

