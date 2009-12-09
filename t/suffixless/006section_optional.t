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

my $name = 'test_CURATED';
my ($gene) = dicty::Search::Gene->find(
    -name       => $name,
    -is_deleted => 'false'
);
my $gene_id = $gene->primary_id;

#request for section links under default gene topic
my $tx = Mojo::Transaction->new_get("/gene/$gene_id/gene/links.json");
$client->process_app( 'DictyREST', $tx );
is( $tx->res->code, 200, 'is a successful response for links section' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for links' );
like( $tx->res->body, qr/layout.+row/, 'has a row layout in links' );
diag( $tx->res->body);



