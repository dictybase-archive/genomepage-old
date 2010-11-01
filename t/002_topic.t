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
my $gene_id = $gene->primary_id;
my ($transcript)  = @{ $gene->transcripts };
my $transcript_id = $transcript->primary_id();

$t->get_ok("$base_url/$gene_id/gene.json")
    ->status_is( 200, 'successful response for gene' )
    ->content_type_like( qr/json/, 'json content for gene' )
    ->content_like(qr/layout.+accordion/,'has a accordion layout in json content');

#request for gene with name
$t->get_ok("$base_url/$name/gene.json")
    ->status_is( 200, "successful response for $name gene" )
    ->content_type_like( qr/json/, 'json content for gene' )
    ->content_like(qr/layout.+accordion/,'has a accordion layout in json content');
    
#request for protein
$t->get_ok("$base_url/$gene_id/protein")
    ->status_is( 200, "successful response for $name gene" )
    ->content_type_like( qr/html/, 'html content for gene' )
    ->content_like(qr/Gene Information for $name/, "has a the title for $name gene page");

#request for protein with gene name
$t->get_ok("$base_url/$gene_id/protein")
    ->status_is( 200, "successful response for  protein topic of $name gene" )
    ->content_type_like( qr/html/, 'html content for gene' )
    ->content_like(qr/Gene Information for $name/, "has a the title for $name gene page");

#request for protein section for json response
$t->get_ok("$base_url/$gene_id/protein/$transcript_id\.json")
    ->status_is( 200, "successful response for protein section with json query" )
    ->content_type_like( qr/json/, 'json content for protein' )
    ->content_like(qr/layout.+accordion/, 'has a accordion layout in protein');
