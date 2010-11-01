#!perl

use strict;
use warnings;

use Test::More qw/no_plan/;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::Mojo;
use dicty::Search::Gene;

use_ok 'GenomeREST';

my $t = Test::Mojo->new( app => 'GenomeREST' );

my $wrong_species = 'ringding';
my $species       = $ENV{SPECIES} || 'discoideum';
my $wrong_url     = '/' . $wrong_species . '/gene';
my $base_url      = '/' . $species . '/gene';
my $name          = 'test_CURATED';

my ($gene) = dicty::Search::Gene->find(
    -name       => $name,
    -is_deleted => 'false'
);
my $gene_id = $gene->primary_id;

$t->get_ok("$base_url/$name")
    ->status_is( 200, "successful response for $name" )
    ->content_type_like( qr/html/, "html response for $name" )
    ->content_like(qr/Gene information for $name/i,'title for gene page')
    ->content_like(qr/Supported by NIH/i, 'common footer for every gene page');

#with non-existant species
$t->get_ok($wrong_url . '/' . $gene_id )
    ->status_is( 200, "is a successful response for $name" )
    ->content_type_like( qr/html/, 'is a html response for gene' )
    ->content_like(qr/organism $wrong_species/,'should be an error with wrong species name');

#canonical url with gene id
$t->get_ok("$base_url/$gene_id")
    ->status_is( 200, "successful response for $gene_id" )
    ->content_type_like( qr/html/, "html response for $gene_id" )
    ->content_like(qr/Gene information for $name/i, "title for $gene_id gene page")
    ->content_like(qr/Supported by NIH/i, 'common footer for every gene page');

#canonical url with gene name and format extension
$t->get_ok("$base_url/$name.html")
    ->status_is( 200, "successful response for $name" )
    ->content_type_like( qr/html/, "html response for $name" )
    ->content_like(qr/Gene information for $name/i,'title for gene page')
    ->content_like(qr/Supported by NIH/i, 'common footer for every gene page');

