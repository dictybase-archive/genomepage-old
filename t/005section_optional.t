#!perl

use strict;
use warnings;

use Test::More qw/no_plan/;
use FindBin;
use lib "$FindBin::Bin/lib";
use Mojo::Client;
use Mojo::Transaction;
use Data::Dumper;
use dicty::Search::Gene;

use_ok('DictyREST');

my $client = Mojo::Client->new();

my $name = 'test_BFNVI_0C0011_07646';
my ($gene) = dicty::Search::Gene->find(
    -name       => $name,
    -is_deleted => 'false'
);
my $gene_id = $gene->primary_id;

#request for section sequences under default gene topic
my $tx = Mojo::Transaction->new_get("/gene/$gene_id/gene/sequences.json");
$client->process_app( 'DictyREST', $tx );
is( $tx->res->code, 200, 'is a successful response for sequences section' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for sequences' );
like( $tx->res->body, qr/layout.+row/, 'has a row layout in sequences' );

#request for section links under default gene topic
$tx = Mojo::Transaction->new_get("/gene/$gene_id/gene/links.json");
$client->process_app( 'DictyREST', $tx );
is( $tx->res->code, 200, 'is a successful response for links section' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for links' );
like( $tx->res->body, qr/layout.+row/, 'has a row layout in links' );

#request for summary section under default gene topic
$tx = Mojo::Transaction->new_get("/gene/$gene_id/gene/summary.json");
$client->process_app( 'DictyREST', $tx );
is( $tx->res->code, 200,
    'is a successful response for summary section with explicit json format'
);
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for summary' );
like( $tx->res->body, qr/layout.+row/, 'has a row layout in summary' );

#request for function section under GO topic
$tx = Mojo::Transaction->new_get("/gene/$gene_id/go/function.json");
$client->process_app( 'DictyREST', $tx );
is( $tx->res->code, 200,
    'is a successful response for function section under GO' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for function' );
like( $tx->res->body, qr/layout.+json/, 'has a json layout in function' );

#request for component section under GO topic
$tx = Mojo::Transaction->new_get("/gene/$gene_id/go/component.json");
$client->process_app( 'DictyREST', $tx );
is( $tx->res->code, 200,
    'is a successful response for component section under GO' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for component' );
like( $tx->res->body, qr/layout.+json/, 'has a json layout in componet' );

