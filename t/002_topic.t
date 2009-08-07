#!perl

use strict;
use warnings;

use Test::More qw/no_plan/;
use FindBin;
use lib "$FindBin::Bin/lib";
use Mojo::Client;
use Mojo::Transaction;
use Data::Dumper;

use_ok('DictyREST');


my $client = Mojo::Client->new();

#request for gene 
my $tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/gene.json');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for gene');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for gene');
like($tx->res->body,  qr/layout.+accordion/,  'has a accordion layout in json content');



#request for GO 
my $tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/go');
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


#request for gene 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0286355/gene.json');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for mhcA gene');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for gene');
like($tx->res->body,  qr/layout.+accordion/,  'has a accordion layout in json content');


