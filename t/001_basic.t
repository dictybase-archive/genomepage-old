!perl

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


my $name = 'test_CURATED';

my $client = Mojo::Client->new();
    my ($gene) = dicty::Search::Gene->find(
        -name       => $name, 
        -is_deleted => 'false'
    );
my $gene_id = $gene->primary_id;

my $tx = Mojo::Transaction->new_get('/gene');
$client->process_app('DictyREST',  $tx);

is($tx->res->code, 404, 'resource does not exist');
like($tx->res->body, qr/File not found/i, 'is a generic error response');

#canonical url with gene name
$tx = Mojo::Transaction->new_get("/gene/$name");
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for sadA');
like($tx->res->headers->content_type,  qr/html/,  'is a html response for gene');
like($tx->res->body,  qr/Gene page for $name/i,  'is the title for gene page');
like($tx->res->body,  qr/Supported by NIH/i,  'is the common footer for every gene page');

#canonical url with gene id
$tx = Mojo::Transaction->new_get("/gene/$gene_id");
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, "is a successful response for $gene_id");
like($tx->res->headers->content_type,  qr/html/,  "is a html response for $gene_id");
like($tx->res->body,  qr/Gene page for $name/i,  "is the title for $gene_id gene page");
like($tx->res->body,  qr/Supported by NIH/i,  'is the common footer for every gene page');


#canonical url with gene name and format extension
$tx = Mojo::Transaction->new_get("/gene/$name.html");
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, "is a successful response for $name");
like($tx->res->headers->content_type,  qr/html/,  "is a html response for $name");
like($tx->res->body,  qr/Gene page for $name/i,  "is the title for $name gene page");
like($tx->res->body,  qr/Supported by NIH/i,  'is the common footer for every gene page');

#canonical url with gene name and json format
$tx = Mojo::Transaction->new_get("/gene/$name.json");
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, "is a successful response for $name");
like($tx->res->headers->content_type,  qr/json/,  "is a json response for $name");
like($tx->res->body,  qr/tabview/,  'default layout for json response of gene');




