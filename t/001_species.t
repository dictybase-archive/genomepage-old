#!perl

use strict;

#use FindBin;
#use lib "$FindBin::Bin/../lib";
use Test::More qw/no_plan/;
use Test::Mojo;
use GenomeREST::Build;

BEGIN {
    $ENV{MOJO_LOG_LEVEL} = 'debug';
}

my $builder = GenomeREST::Build->current;
use_ok 'GenomeREST';
my $t = Test::Mojo->new( app => 'GenomeREST' );

my $dicty_url = '/discoideum';
my $sp        = $t->get_ok($dicty_url);
$sp->status_is( 200, "successful response for $dicty_url" );
$sp->content_type_like( qr/html/, "html response for $dicty_url" );
$sp->element_exists( 'html head title', 'It has title' );
$sp->text_like(
    'html head title' => qr/discoideum/,
    'has species abbreviation in title'
);

my $bad_species = '/break';
my $wrong = $t->get_ok($bad_species);
$wrong->status_is(404, "is a error response from $bad_species");
$sp->content_type_like( qr/html/, "html response for $bad_species" );
$sp->text_is('html head title' => 'Page not found','has page not found title');
$sp->text_like('div.warning p:first-child' => qr/$bad_species/,"has $bad_species url in the body");


