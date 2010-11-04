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

my $species = $ENV{SPECIES} || 'discoideum';
my $base_url = '/'.$species.'/gene';
my $name = 'test_CURATED';

my ($gene) = dicty::Search::Gene->find(
    -name       => $name,
    -is_deleted => 'false'
);
my $gene_id       = $gene->primary_id;
my ($transcript)  = @{ $gene->transcripts };
my $transcript_id = $transcript->primary_id();


#request for section info under default gene topic
$t->get_ok("$base_url/$gene_id/gene/info.json")
    ->status_is( 200, 'successful response for info section' )
    ->content_type_like( qr/json/, 'is a json content for info' )
    ->content_like(qr/layout.+row/, 'has a row layout in info');

#request for product section
$t->get_ok("$base_url/$gene_id/gene/genomic_info.json")
    ->status_is( 200, 'successful response for genomic info section' )
    ->content_type_like( qr/json/, 'is a json content for genomic info' )
    ->content_like(qr/layout.+row/, 'has a row layout in genomic info');

#request for product section
$t->get_ok("$base_url/$gene_id/gene/product.json")
    ->status_is( 200, 'successful response for product section' )
    ->content_type_like( qr/json/, 'is a json content for product' )
    ->content_like(qr/layout.+row/, 'has a row layout in product');

#request for section info under protein topic
$t->get_ok("$base_url/$gene_id/protein/$transcript_id/info")
    ->status_is( 200, 'successful response for protein info section' )
    ->content_type_like( qr/json/, 'is a json content for protein info' )
    ->content_like(qr/layout.+row/, 'has a row layout in protein info');

#request for section sequence under protein topic
$t->get_ok("$base_url/$gene_id/protein/$transcript_id/sequence")
    ->status_is( 200, 'successful response for protein sequence section' )
    ->content_type_like( qr/json/, 'is a json content for protein sequence' )
    ->content_like(qr/layout.+row/, 'has a row layout in protein sequence');

#request for section sequence under protein topic with explicit json requirement
$t->get_ok("$base_url/$gene_id/protein/$transcript_id/sequence.json")
    ->status_is( 200, 'successful.json response for protein sequence section' )
    ->content_type_like( qr/json/, 'is a json content for protein sequence' )
    ->content_like(qr/layout.+row/, 'has a row layout in protein sequence');

#request for feature tab
$t->get_ok("$base_url/$gene_id/feature")
    ->status_is( 200, 'successful.json response for feature section' )
    ->content_type_like( qr/html/, 'is a html content for protein sequence' );

#explicit request for feature tab
$t->get_ok("$base_url/$gene_id/feature/$transcript_id")
    ->status_is( 200, 'successful.json response for feature section' )
    ->content_type_like( qr/html/, 'is a html content for protein sequence' )
    ->content_like(qr/Gene information for $name/i, "title for $gene_id gene page")
    ->content_like(qr/Supported by NIH/i, 'common footer for every gene page');
