use strict;
use warnings;

use Test::More qw/no_plan/;
use FindBin;
use lib "$FindBin::Bin/lib";
use Mojo::Client;
use Mojo::Transaction;
use Data::Dumper;
use dicty::Search::Gene;

use_ok('GenomeREST');

my $wrong_species = 'ringding';
my $species       = $ENV{SPECIES} || 'discoideum';
my $wrong_url     = '/' . $wrong_species . '/gene';
my $base_url      = '/' . $species . '/gene';
my $name          = 'test_CURATED';

my $client = Mojo::Client->new();
my ($gene) = dicty::Search::Gene->find(
    -name       => $name,
    -is_deleted => 'false'
);
my $gene_id = $gene->primary_id;

my $tx;
#my $tx = Mojo::Transaction->new_get($base_url);
#$client->process_app( 'GenomeREST', $tx );

#is( $tx->res->code, 404, 'resource does not exist' );
#like( $tx->res->body, qr/File not found/i, 'is a generic error response' );
#exit;

#canonical url with gene name
$tx = Mojo::Transaction->new_get("$base_url/$name");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200, "is a successful response for $name" );
like( $tx->res->headers->content_type,
    qr/html/, 'is a html response for gene' );
like( $tx->res->body, qr/Gene information for $name/i,
    'is the title for gene page' );
like(
    $tx->res->body,
    qr/Supported by NIH/i,
    'is the common footer for every gene page'
);


#with non-existant species
$tx = Mojo::Transaction->new_get($wrong_url.'/'.$gene_id);
$client->process_app( 'GenomeREST', $tx );
like(
    $tx->res->body,
    qr/organism $wrong_species/,
    'should be an error with wrong species name'
);

#canonical url with gene id
$tx = Mojo::Transaction->new_get("$base_url/$gene_id");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200, "is a successful response for $gene_id" );
like( $tx->res->headers->content_type,
    qr/html/, "is a html response for $gene_id" );
like(
    $tx->res->body,
    qr/Gene information for $name/i,
    "is the title for $gene_id gene page"
);
like(
    $tx->res->body,
    qr/Supported by NIH/i,
    'is the common footer for every gene page'
);


#canonical url with gene name and format extension
$tx = Mojo::Transaction->new_get("$base_url/$name.html");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200, "is a successful response for $name" );
like( $tx->res->headers->content_type,
    qr/html/, "is a html response for $name" );
like(
    $tx->res->body,
    qr/Gene information for $name/i,
    "is the title for $name gene page"
);
like(
    $tx->res->body,
    qr/Supported by NIH/i,
    'is the common footer for every gene page'
);
