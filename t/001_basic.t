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

my $tx = Mojo::Transaction->new_get('/gene');
$client->process_app('DictyREST',  $tx);

is($tx->res->code, 404, 'resource does not exist');
like($tx->res->body, qr/File not found/i, 'is a generic error response');

#canonical url with gene name
$tx = Mojo::Transaction->new_get('/gene/sadA');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for sadA');
like($tx->res->headers->content_type,  qr/html/,  'is a html response for sadA');
like($tx->res->body,  qr/Gene page for sadA/i,  'is the title for sadA gene page');
like($tx->res->body,  qr/Supported by NIH/i,  'is the common footer for every gene page');

#canonical url with gene id
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for DDB_G0288511');
like($tx->res->headers->content_type,  qr/html/,  'is a html response for DDB_G0288511');
like($tx->res->body,  qr/Gene page for sadA/i,  'is the title for DDB_G0288511 gene page');
like($tx->res->body,  qr/Supported by NIH/i,  'is the common footer for every gene page');


#canonical url with gene name and format extension
$tx = Mojo::Transaction->new_get('/gene/sadA.html');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for sadA');
like($tx->res->headers->content_type,  qr/html/,  'is a html response for sadA');
like($tx->res->body,  qr/Gene page for sadA/i,  'is the title for sadA gene page');
like($tx->res->body,  qr/Supported by NIH/i,  'is the common footer for every gene page');

#canonical url with gene name and json format
$tx = Mojo::Transaction->new_get('/gene/sadA.json');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for sadA');
like($tx->res->headers->content_type,  qr/json/,  'is a json response for sadA');
like($tx->res->body,  qr/tabview/,  'default layout for json response of gene');




