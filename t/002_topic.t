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

#request for GO 
my $tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/go');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for GO');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for GO');
like($tx->res->body,  qr/layout.+accordion/,  'has a accordion layout in json content');

#request for phenotypes 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/phenotypes');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for phenotypes');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for phenotype');
like($tx->res->body,  qr/layout.+row/,  'has a row layout in json content');

#request for references 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/references');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for references');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for references');
like($tx->res->body,  qr/layout.+column/,  'has a column layout in json content');


