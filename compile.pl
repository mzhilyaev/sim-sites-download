#!/usr/bin/perl

use strict;
use Data::Dumper;
use JSON;
use HTML::ExtractMeta;
use XML::LibXML::Simple   qw(XMLin);
use Getopt::Long;
use Encode;
use HTML::Entities;
use HTML::HeadParser;

#binmode STDOUT, ":utf8";
#use open ':encoding(utf8)';

my $encodings = {
 "437" => 1,
 "850" => 1,
 "852" => 1,
 "855" => 1,
 "857" => 1,
 "860" => 1,
 "861" => 1,
 "862" => 1,
 "863" => 1,
 "865" => 1,
 "866" => 1,
 "869" => 1,
 "ANSI_X3.4-1968" => 1,
 "ANSI_X3.4-1986" => 1,
 "ARABIC" => 1,
 "ARMSCII-8" => 1,
 "ASCII" => 1,
 "ASMO-708" => 1,
 "ATARI" => 1,
 "ATARIST" => 1,
 "BIG-5" => 1,
 "BIG-FIVE" => 1,
 "BIG5" => 1,
 "BIG5-2003" => 1,
 "BIG5-HKSCS" => 1,
 "BIG5-HKSCS:1999" => 1,
 "BIG5-HKSCS:2001" => 1,
 "BIG5-HKSCS:2004" => 1,
 "BIG5HKSCS" => 1,
 "BIGFIVE" => 1,
 "C99" => 1,
 "CHINESE" => 1,
 "CN" => 1,
 "CN-BIG5" => 1,
 "CN-GB" => 1,
 "CN-GB-ISOIR165" => 1,
 "CP-GR" => 1,
 "CP-IS" => 1,
 "CP1046" => 1,
 "CP1124" => 1,
 "CP1125" => 1,
 "CP1129" => 1,
 "CP1133" => 1,
 "CP1161" => 1,
 "CP1162" => 1,
 "CP1163" => 1,
 "CP1250" => 1,
 "CP1251" => 1,
 "CP1252" => 1,
 "CP1253" => 1,
 "CP1254" => 1,
 "CP1255" => 1,
 "CP1256" => 1,
 "CP1257" => 1,
 "CP1258" => 1,
 "CP1361" => 1,
 "CP154" => 1,
 "CP367" => 1,
 "CP437" => 1,
 "CP737" => 1,
 "CP775" => 1,
 "CP819" => 1,
 "CP850" => 1,
 "CP852" => 1,
 "CP853" => 1,
 "CP855" => 1,
 "CP856" => 1,
 "CP857" => 1,
 "CP858" => 1,
 "CP860" => 1,
 "CP861" => 1,
 "CP862" => 1,
 "CP863" => 1,
 "CP864" => 1,
 "CP865" => 1,
 "CP866" => 1,
 "CP869" => 1,
 "CP874" => 1,
 "CP922" => 1,
 "CP932" => 1,
 "CP936" => 1,
 "CP943" => 1,
 "CP949" => 1,
 "CP950" => 1,
 "CSASCII" => 1,
 "CSBIG5" => 1,
 "CSEUCKR" => 1,
 "CSEUCPKDFMTJAPANESE" => 1,
 "CSEUCTW" => 1,
 "CSGB2312" => 1,
 "CSHALFWIDTHKATAKANA" => 1,
 "CSHPROMAN8" => 1,
 "CSIBM1161" => 1,
 "CSIBM1162" => 1,
 "CSIBM1163" => 1,
 "CSIBM855" => 1,
 "CSIBM857" => 1,
 "CSIBM860" => 1,
 "CSIBM861" => 1,
 "CSIBM863" => 1,
 "CSIBM864" => 1,
 "CSIBM865" => 1,
 "CSIBM866" => 1,
 "CSIBM869" => 1,
 "CSISO14JISC6220RO" => 1,
 "CSISO159JISX02121990" => 1,
 "CSISO2022CN" => 1,
 "CSISO2022JP" => 1,
 "CSISO2022JP2" => 1,
 "CSISO2022KR" => 1,
 "CSISO57GB1988" => 1,
 "CSISO58GB231280" => 1,
 "CSISO87JISX0208" => 1,
 "CSISOLATIN1" => 1,
 "CSISOLATIN2" => 1,
 "CSISOLATIN3" => 1,
 "CSISOLATIN4" => 1,
 "CSISOLATIN5" => 1,
 "CSISOLATIN6" => 1,
 "CSISOLATINARABIC" => 1,
 "CSISOLATINCYRILLIC" => 1,
 "CSISOLATINGREEK" => 1,
 "CSISOLATINHEBREW" => 1,
 "CSKOI8R" => 1,
 "CSKSC56011987" => 1,
 "CSMACINTOSH" => 1,
 "CSPC775BALTIC" => 1,
 "CSPC850MULTILINGUAL" => 1,
 "CSPC862LATINHEBREW" => 1,
 "CSPC8CODEPAGE437" => 1,
 "CSPCP852" => 1,
 "CSPTCP154" => 1,
 "CSSHIFTJIS" => 1,
 "CSUCS4" => 1,
 "CSUNICODE" => 1,
 "CSUNICODE11" => 1,
 "CSUNICODE11UTF7" => 1,
 "CSVISCII" => 1,
 "CYRILLIC" => 1,
 "CYRILLIC-ASIAN" => 1,
 "DEC-HANYU" => 1,
 "DEC-KANJI" => 1,
 "ECMA-114" => 1,
 "ECMA-118" => 1,
 "ELOT_928" => 1,
 "EUC-CN" => 1,
 "EUC-JISX0213" => 1,
 "EUC-JP" => 1,
 "EUC-KR" => 1,
 "EUC-TW" => 1,
 "EUCCN" => 1,
 "EUCJP" => 1,
 "EUCKR" => 1,
 "EUCTW" => 1,
 "EXTENDED_UNIX_CODE_PACKED_FORMAT_FOR_JAPANESE" => 1,
 "GB18030" => 1,
 "GB2312" => 1,
 "GBK" => 1,
 "GB_1988-80" => 1,
 "GB_2312-80" => 1,
 "GEORGIAN-ACADEMY" => 1,
 "GEORGIAN-PS" => 1,
 "GREEK" => 1,
 "GREEK8" => 1,
 "HEBREW" => 1,
 "HP-ROMAN8" => 1,
 "HZ" => 1,
 "HZ-GB-2312" => 1,
 "IBM-1161" => 1,
 "IBM-1162" => 1,
 "IBM-1163" => 1,
 "IBM-CP1133" => 1,
 "IBM1161" => 1,
 "IBM1162" => 1,
 "IBM1163" => 1,
 "IBM367" => 1,
 "IBM437" => 1,
 "IBM775" => 1,
 "IBM819" => 1,
 "IBM850" => 1,
 "IBM852" => 1,
 "IBM855" => 1,
 "IBM857" => 1,
 "IBM860" => 1,
 "IBM861" => 1,
 "IBM862" => 1,
 "IBM863" => 1,
 "IBM864" => 1,
 "IBM865" => 1,
 "IBM866" => 1,
 "IBM869" => 1,
 "ISO-10646-UCS-2" => 1,
 "ISO-10646-UCS-4" => 1,
 "ISO-2022-CN" => 1,
 "ISO-2022-CN-EXT" => 1,
 "ISO-2022-JP" => 1,
 "ISO-2022-JP-1" => 1,
 "ISO-2022-JP-2" => 1,
 "ISO-2022-JP-3" => 1,
 "ISO-2022-KR" => 1,
 "ISO-8859-1" => 1,
 "ISO-8859-10" => 1,
 "ISO-8859-11" => 1,
 "ISO-8859-13" => 1,
 "ISO-8859-14" => 1,
 "ISO-8859-15" => 1,
 "ISO-8859-16" => 1,
 "ISO-8859-2" => 1,
 "ISO-8859-3" => 1,
 "ISO-8859-4" => 1,
 "ISO-8859-5" => 1,
 "ISO-8859-6" => 1,
 "ISO-8859-7" => 1,
 "ISO-8859-8" => 1,
 "ISO-8859-9" => 1,
 "ISO-CELTIC" => 1,
 "ISO-IR-100" => 1,
 "ISO-IR-101" => 1,
 "ISO-IR-109" => 1,
 "ISO-IR-110" => 1,
 "ISO-IR-126" => 1,
 "ISO-IR-127" => 1,
 "ISO-IR-138" => 1,
 "ISO-IR-14" => 1,
 "ISO-IR-144" => 1,
 "ISO-IR-148" => 1,
 "ISO-IR-149" => 1,
 "ISO-IR-157" => 1,
 "ISO-IR-159" => 1,
 "ISO-IR-165" => 1,
 "ISO-IR-166" => 1,
 "ISO-IR-179" => 1,
 "ISO-IR-199" => 1,
 "ISO-IR-203" => 1,
 "ISO-IR-226" => 1,
 "ISO-IR-230" => 1,
 "ISO-IR-57" => 1,
 "ISO-IR-58" => 1,
 "ISO-IR-6" => 1,
 "ISO-IR-87" => 1,
 "ISO646-CN" => 1,
 "ISO646-JP" => 1,
 "ISO646-US" => 1,
 "ISO8859-1" => 1,
 "ISO8859-10" => 1,
 "ISO8859-11" => 1,
 "ISO8859-13" => 1,
 "ISO8859-14" => 1,
 "ISO8859-15" => 1,
 "ISO8859-16" => 1,
 "ISO8859-2" => 1,
 "ISO8859-3" => 1,
 "ISO8859-4" => 1,
 "ISO8859-5" => 1,
 "ISO8859-6" => 1,
 "ISO8859-7" => 1,
 "ISO8859-8" => 1,
 "ISO8859-9" => 1,
 "ISO_646.IRV:1991" => 1,
 "ISO_8859-1" => 1,
 "ISO_8859-10" => 1,
 "ISO_8859-10:1992" => 1,
 "ISO_8859-11" => 1,
 "ISO_8859-13" => 1,
 "ISO_8859-14" => 1,
 "ISO_8859-14:1998" => 1,
 "ISO_8859-15" => 1,
 "ISO_8859-15:1998" => 1,
 "ISO_8859-16" => 1,
 "ISO_8859-16:2001" => 1,
 "ISO_8859-1:1987" => 1,
 "ISO_8859-2" => 1,
 "ISO_8859-2:1987" => 1,
 "ISO_8859-3" => 1,
 "ISO_8859-3:1988" => 1,
 "ISO_8859-4" => 1,
 "ISO_8859-4:1988" => 1,
 "ISO_8859-5" => 1,
 "ISO_8859-5:1988" => 1,
 "ISO_8859-6" => 1,
 "ISO_8859-6:1987" => 1,
 "ISO_8859-7" => 1,
 "ISO_8859-7:1987" => 1,
 "ISO_8859-7:2003" => 1,
 "ISO_8859-8" => 1,
 "ISO_8859-8:1988" => 1,
 "ISO_8859-9" => 1,
 "ISO_8859-9:1989" => 1,
 "JAVA" => 1,
 "JIS0208" => 1,
 "JISX0201-1976" => 1,
 "JIS_C6220-1969-RO" => 1,
 "JIS_C6226-1983" => 1,
 "JIS_X0201" => 1,
 "JIS_X0208" => 1,
 "JIS_X0208-1983" => 1,
 "JIS_X0208-1990" => 1,
 "JIS_X0212" => 1,
 "JIS_X0212-1990" => 1,
 "JIS_X0212.1990-0" => 1,
 "JOHAB" => 1,
 "JP" => 1,
 "KOI8-R" => 1,
 "KOI8-RU" => 1,
 "KOI8-T" => 1,
 "KOI8-U" => 1,
 "KOREAN" => 1,
 "KSC_5601" => 1,
 "KS_C_5601-1987" => 1,
 "KS_C_5601-1989" => 1,
 "L1" => 1,
 "L10" => 1,
 "L2" => 1,
 "L3" => 1,
 "L4" => 1,
 "L5" => 1,
 "L6" => 1,
 "L7" => 1,
 "L8" => 1,
 "LATIN-9" => 1,
 "LATIN1" => 1,
 "LATIN10" => 1,
 "LATIN2" => 1,
 "LATIN3" => 1,
 "LATIN4" => 1,
 "LATIN5" => 1,
 "LATIN6" => 1,
 "LATIN7" => 1,
 "LATIN8" => 1,
 "MAC" => 1,
 "MACARABIC" => 1,
 "MACCENTRALEUROPE" => 1,
 "MACCROATIAN" => 1,
 "MACCYRILLIC" => 1,
 "MACGREEK" => 1,
 "MACHEBREW" => 1,
 "MACICELAND" => 1,
 "MACINTOSH" => 1,
 "MACROMAN" => 1,
 "MACROMANIA" => 1,
 "MACTHAI" => 1,
 "MACTURKISH" => 1,
 "MACUKRAINE" => 1,
 "MS-ANSI" => 1,
 "MS-ARAB" => 1,
 "MS-CYRL" => 1,
 "MS-EE" => 1,
 "MS-GREEK" => 1,
 "MS-HEBR" => 1,
 "MS-TURK" => 1,
 "MS936" => 1,
 "MS_KANJI" => 1,
 "MULELAO-1" => 1,
 "NEXTSTEP" => 1,
 "PT154" => 1,
 "PTCP154" => 1,
 "R8" => 1,
 "RISCOS-LATIN1" => 1,
 "ROMAN8" => 1,
 "SHIFT-JIS" => 1,
 "SHIFT_JIS" => 1,
 "SHIFT_JISX0213" => 1,
 "SJIS" => 1,
 "TCVN" => 1,
 "TCVN-5712" => 1,
 "TCVN5712-1" => 1,
 "TCVN5712-1:1993" => 1,
 "TDS565" => 1,
 "TIS-620" => 1,
 "TIS620" => 1,
 "TIS620-0" => 1,
 "TIS620.2529-1" => 1,
 "TIS620.2533-0" => 1,
 "TIS620.2533-1" => 1,
 "UCS-2" => 1,
 "UCS-2-INTERNAL" => 1,
 "UCS-2-SWAPPED" => 1,
 "UCS-2BE" => 1,
 "UCS-2LE" => 1,
 "UCS-4" => 1,
 "UCS-4-INTERNAL" => 1,
 "UCS-4-SWAPPED" => 1,
 "UCS-4BE" => 1,
 "UCS-4LE" => 1,
 "UHC" => 1,
 "UNICODE-1-1" => 1,
 "UNICODE-1-1-UTF-7" => 1,
 "UNICODEBIG" => 1,
 "UNICODELITTLE" => 1,
 "US" => 1,
 "US-ASCII" => 1,
 "UTF-16" => 1,
 "UTF-16BE" => 1,
 "UTF-16LE" => 1,
 "UTF-32" => 1,
 "UTF-32BE" => 1,
 "UTF-32LE" => 1,
 "UTF-7" => 1,
 "UTF-8" => 1,
 "UTF-8-MAC" => 1,
 "UTF8" => 1,
 "UTF8-MAC" => 1,
 "VISCII" => 1,
 "VISCII1.1-1" => 1,
 "WINBALTRIM" => 1,
 "WINDOWS-1250" => 1,
 "WINDOWS-1251" => 1,
 "WINDOWS-1252" => 1,
 "WINDOWS-1253" => 1,
 "WINDOWS-1254" => 1,
 "WINDOWS-1255" => 1,
 "WINDOWS-1256" => 1,
 "WINDOWS-1257" => 1,
 "WINDOWS-1258" => 1,
 "WINDOWS-874" => 1,
 "WINDOWS-936" => 1,
 "X0201" => 1,
 "X0208" => 1,
 "X0212" => 1,
};

my $langs = {
  "en" => 1,
};

my $codes = {
  US => 1,
  GB => 1,
  IN => 1,
  AU => 1,
  CA => 1,
  ZA => 1,
};

my $badTitles = {
 "Home" => 1,
 "Access Denied" => 1,
 "Suspicious Activity Detected" => 1,
 "Homepage" => 1,
 "Apache HTTP Server Test Page powered by CentOS" => 1,
 "Not Found" => 1,
 "Home Page" => 1,
 "Search" => 1,
 "Just a moment..." => 1,
 "Request Rejected" => 1,
 "Contact Us" => 1,
 "Access is denied." => 1,
 "Sign In" => 1,
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
my $relatedLimit = 1000;
my $simScoreLimit = 0.9;

if(
   !GetOptions (
            "help|h" => \$help ,
            "dump|d" => \$dump ,
            "rlimit|r=i" => \$relatedLimit ,
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
my $siteCount = 0;
my $comaPrefix = "";


sub readFile {
  my $file = shift;
  open(my $fh, "<", $file);
  my $data;
  $fh->read($data, 100000000);
  # replace escaped html chars to avoid HTML parser interpreting them
  $data =~ s/\&\#([0-9]+);/_AND_SPECIAL_CHAR_HASH_BEG\1_AND_SPECIAL_CHAR_HASH_END/g;
  $data =~ s/\&([a-zA-Z0-9]+);/_AND_SPECIAL_CHAR_BEG\1_AND_SPECIAL_CHAR_END/g;
  return $data;
}

sub print_jsonify {
  my $obj = shift;
  print "{";
  my $prefix = "";
  for my $prop (sort {$a cmp $b} keys %$obj) {
    print "$prefix\"$prop\": ";
    $prefix = ",";
    my $val = $obj->{$prop};
    if (ref($val) eq "ARRAY") {
      my $prf = "";
      print "[";
      map {print "$prf\"$_\""; $prf = ","} @$val;
      print "]";
    }
    elsif ($val =~ /^[0-9]+$/) {
      print $val;
    }
    else {
      ## put escaped chars back
      $val =~ s/_AND_SPECIAL_CHAR_HASH_BEG([0-9]+)_AND_SPECIAL_CHAR_HASH_END/&#\1;/g;
      $val =~ s/_AND_SPECIAL_CHAR_BEG([a-zA-Z0-9]+)_AND_SPECIAL_CHAR_END/&\1;/g;
      $val =~ s/\\/&#92;/g;
      print '"',$val,'"';
    }
  }
  print "}";
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
    if ($xml->{SD}) {
      if (ref($xml->{SD}) eq "ARRAY") {
        my $sd = $xml->{SD}->[1];
        $siteEntry->{alexa}->{rank} = $sd->{POPULARITY}->{TEXT} + 0;
        $siteEntry->{alexa}->{reach} = $sd->{REACH}->{RANK} + 0;
        $siteEntry->{alexa}->{country} = $sd->{COUNTRY};
        $siteEntry->{alexa}->{country}->{RANK} = $siteEntry->{alexa}->{country}->{RANK} + 0;

        $sd = $xml->{SD}->[0];
        $siteEntry->{alexa}->{lang} = $sd->{'LANG'}->{LEX};
      }
      else {
        $siteEntry->{alexa}->{lang} = $xml->{SD}->{'LANG'}->{LEX};
      }
    }
  }
};

sub readPage {
  my $site = shift;
  my $data = readFile("$pagePath/$site");
  if ($data) {
    ### test if html is utf-8 encoded
    my $em = HTML::HeadParser->new();
    $em->parse($data);
    my $charset = $em->header("X-Meta-Charset");
    if (!$charset) {
      $charset = $em->header("Content-Type");
      $charset =~ s/^.*charset=//;
    }

    ## upper case charset
    $charset = uc($charset);

    if (!$charset || lc($charset) eq "TEXT/HTML" || !$encodings->{$charset}) {
      ### assume utf-8
      $charset = "UTF-8";
    }

    ### if it's not UTF-8, convert
    if ($charset ne "UTF-8") {
      print STDERR "iconv -f $charset -t UTF8 -c $pagePath/$site \n";
      system("iconv -f $charset -t UTF8 -c $pagePath/$site > $$.converted 2> /dev/null");
        ### read converted file
      $data = readFile("$$.converted");
      if($? != 0) {
        print STDERR "warnings while converting from $charset to utf8 for file $site\n";
      }
    }

    ## now extract data from head tag
    $em = HTML::ExtractMeta->new(
        html => $data, # required
    );
    my $image = $em->get_image_url;
    if ($image && $image =~ /^\/\//) {
      $image = "http$image";
    }
    if ($image && $image =~ /^\//) {
      $image = "http://$site$image";
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
  $siteEntry->{sims}->{related} = [map { {url => $_->{Url}, score => $_->{Score} + 0 } } grep {$_->{Score} > $simScoreLimit} @{$jsn->{SimilarSites}}];
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

  return undef if (!$siteEntry->{alexa}
                   || !$siteEntry->{sims}
                   || !$siteEntry->{sims}->{category}
                   || !$siteEntry->{alexa}->{country}
                   || !$codes->{$siteEntry->{alexa}->{country}->{CODE}});

  $entry->{title} = $siteEntry->{page}->{title} if (titleOK($siteEntry->{page}->{title}));

  if (!$entry->{title} && $siteEntry->{alexa}->{dmoz}) {
    $entry->{title} = $siteEntry->{alexa}->{dmoz}->{title}
  }
  return undef if (!$entry->{title});

  $entry->{description} = $siteEntry->{page}->{description};
  if (!$entry->{description} && $siteEntry->{alexa}->{dmoz}) {
    $entry->{description} = $siteEntry->{alexa}->{dmoz}->{descr}
  }

  if ($siteEntry->{page}->{image}) {
    $entry->{image} = $siteEntry->{page}->{image};
  }
  ## use global site rank
  $entry->{rank} = $siteCount + 1;

  if ($siteEntry->{alexa}->{country}) {
    $entry->{code} = $siteEntry->{alexa}->{country}->{CODE};
  }

  $entry->{category} = $siteEntry->{sims}->{category}->{name};

  if ($siteCount < $relatedLimit && scalar(@{$siteEntry->{sims}->{related}})>0) {
    $entry->{related} = [ map {$_->{url}} @{$siteEntry->{sims}->{related}}];
  }

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
      $titleMap->{$entry->{title}} = 1;
      print "$comaPrefix\"$site\": ";
      print_jsonify($entry);
      $comaPrefix = ",";
    }
  }

  $siteEntry = {};
}

if ($dump) {
  print "{";
}
while(<STDIN>) {
  my $site = $_;
  chomp($site);
  procSite($site);
  $siteCount ++;
}
if ($dump) {
  print "}";
}
