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
diag($tx->res->body);
exit;

#canonical url with gene id
$tx = Mojo::Transaction->new_get('/gene/DDB_G0288511');
$client->process_app('DictyREST',  $tx);
is($tx->res->code, 200, 'is a successful response for DDB_G0288511');
like($tx->res->headers->content_type,  qr/html/,  'is a html response for DDB_G0288511');
like($tx->res->body,  qr/Gene page for sadA/i,  'is the title for DDB_G0288511 gene page');



