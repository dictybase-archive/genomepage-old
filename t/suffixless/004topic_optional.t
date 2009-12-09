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

#request for GO 
my $tx = Mojo::Transaction->new_get("/gene/$gene_id/go");
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for GO');
like($tx->res->headers->content_type,  qr/html/,  'is a html content for GO');
like($tx->res->body,  qr/Gene page for sadA/i,  'is the title for sadA gene page');
like($tx->res->body,  qr/Supported by NIH/i,  'is the common footer for every gene page');

#request for GO with json format 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/go.json');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful json response for GO');
like($tx->res->headers->content_type,  qr/json/,  'is a html content for GO');
like($tx->res->body,  qr/layout.+accordion/,  'has a row layout in json content');

#request for phenotypes 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/phenotypes');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for phenotypes');
like($tx->res->headers->content_type,  qr/html/,  'is a json content for phenotype');
like($tx->res->body,  qr/Gene page for sadA/i,  'is the title with phenotype tab selected');
like($tx->res->body,  qr/Supported by NIH/i,  'is the common footer for every gene page');


#request for phenotypes 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/phenotypes.json');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for phenotypes');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for phenotype');
like($tx->res->body,  qr/layout.+row/,  'has a row layout in json content for phenotype');


#request for references 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/references');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for references');
like($tx->res->headers->content_type,  qr/html/,  'is a html content for references');
like($tx->res->body,  qr/Gene page for sadA/i,  'is the title with reference tab selected');
like($tx->res->body,  qr/Supported by NIH/i,  'is the common footer for every gene page');


#request for references 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/references.json');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for references');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for references');
like($tx->res->body,  qr/layout.+column/,  'has a column layout in json content');

#default request for references with gene name 
$tx = Mojo::Transaction->new_get('/gene/sadA/references');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for references');
like($tx->res->headers->content_type,  qr/html/,  'is a html content for references');
like($tx->res->body,  qr/Gene page for sadA/i,  'is the title with reference tab selected');
like($tx->res->body,  qr/Supported by NIH/i,  'is the common footer for every gene page');


#request for references with gene name 
$tx = Mojo::Transaction->new_get('/gene/sadA/references.json');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for references');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for references');
like($tx->res->body,  qr/layout.+column/,  'has a column layout in json content');




