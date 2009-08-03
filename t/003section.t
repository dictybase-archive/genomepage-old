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

#request for section info under default gene topic 
my $tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/gene/info');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for info section');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for info');
like($tx->res->body,  qr/layout.+row/,  'has a row layout in info');

#request for section sequences under default gene topic 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/gene/sequences');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for sequences section');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for sequences');
like($tx->res->body,  qr/layout.+row/,  'has a row layout in sequences');

#request for section links under default gene topic 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/gene/links');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for links section');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for links');
like($tx->res->body,  qr/layout.+row/,  'has a row layout in links');

#request for summary section under default gene topic 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/gene/summary.json');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for summary section with explicit json format');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for summary');
like($tx->res->body,  qr/layout.+row/,  'has a row layout in summary');


#request for section info under protein topic 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/protein/DDB0191090/info');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for protein info section');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for protein info');
like($tx->res->body,  qr/layout.+row/,  'has a row layout in protein links');

#request for section sequence under protein topic 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/protein/DDB0191090/sequence');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for protein info sequence');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for protein sequence');
like($tx->res->body,  qr/layout.+row/,  'has a row layout in protein sequence');

#request for function section under GO topic 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/go/function');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for function section under GO');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for function');
like($tx->res->body,  qr/layout.+json/,  'has a json layout in function');

#request for component section under GO topic 
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511/go/component.json');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for component section under GO');
like($tx->res->headers->content_type,  qr/json/,  'is a json content for component');
like($tx->res->body,  qr/layout.+json/,  'has a json layout in componet');











