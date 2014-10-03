#!/usr/bin/perl

use strict;
use Data::Dumper;
use JSON;
use HTML::ExtractMeta;

open(FILE, "< $ARGV[0]");
my $data = "";
while(<FILE>) {
  $data .= $_;
}

my $em = HTML::ExtractMeta->new(
    html => $data, # required
);

print encode_json({
  title => $em->get_title,
  description => $em->get_description,
  image => $em->get_image_url,
  keywords => $em->get_keywords,
});
