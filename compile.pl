#!/usr/bin/perl

use strict;
use Data::Dumper;
use JSON;
use HTML::ExtractMeta;
use XML::LibXML::Simple   qw(XMLin);

my $alexaPath = @ARGV[0];
my $simPath = @ARGV[1];
my $pagePath = @ARGV[2];

my $sites = {};

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
      $sites->{$site}->{alexa}->{related} = [map {my $x = $_->{HREF}; $x =~ s/\/$//; $x} @{$xml->{RLS}->{RL}}];
    }
    # dmoz
    if ($xml->{DMOZ}->{SITE}) {
      $sites->{$site}->{alexa}->{dmoz}->{title} = $xml->{DMOZ}->{SITE}->{TITLE};
      $sites->{$site}->{alexa}->{dmoz}->{descr} = $xml->{DMOZ}->{SITE}->{DESC};
      if (ref($xml->{DMOZ}->{SITE}->{CATS}->{CAT}) eq "ARRAY") {
        $sites->{$site}->{alexa}->{dmoz}->{cats} = [map {$_->{TITLE}} @{$xml->{DMOZ}->{SITE}->{CATS}->{CAT}}];
      }
      elsif (ref($xml->{DMOZ}->{SITE}->{CATS}->{CAT}) eq "HASH") {
        $sites->{$site}->{alexa}->{dmoz}->{cats} = [$xml->{DMOZ}->{SITE}->{CATS}->{CAT}->{TITLE}];
      }
    }
    # ranks
    my $sd = $xml->{SD}->[1];
    $sites->{$site}->{alexa}->{rank} = $sd->{POPULARITY}->{TEXT} + 0;
    $sites->{$site}->{alexa}->{reach} = $sd->{REACH}->{RANK} + 0;
    $sites->{$site}->{alexa}->{country} = $sd->{COUNTRY};
    $sites->{$site}->{alexa}->{country}->{RANK} = $sites->{$site}->{alexa}->{country}->{RANK} + 0;
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
    $sites->{$site}->{page} = {
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
  $sites->{$site}->{sims}->{category} = {name => $jsn->{Category}, rank => $jsn->{CategoryRank}};
  $jsn = decode_json($line2);
  $sites->{$site}->{sims}->{related} = [map { {url => $_->{Url}, score => $_->{Score} + 0 } } @{$jsn->{SimilarSites}}];
}

while(<STDIN>) {
  my $site = $_;
  chomp($site);
  readAlexa($site);
  readPage($site);
  readSims($site);
}

print encode_json($sites);

