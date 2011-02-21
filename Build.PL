#!/usr/bin/perl -w
use strict;
use warnings;
use lib 'lib';
use GenomeREST::Builder;

my $builder = GenomeREST::Builder->new(
    module_name  => 'GenomeREST',
    license      => 'perl',
    dist_author  => 'Siddhartha Basu <siddhartha-basu@northwestern.edu>',
    dist_version => '1.4.0',
    requires     => {
        'Mojolicious'                => '0.999938',
        'FCGI::Engine'               => '0.16',
        'Plack'                      => '0.9941',
        'Config::Simple'             => '',
        'Homology::Group'            => '',
        'MooseX::Singleton'          => '0.24',
        'Modware'                    => '0.001',
        'dicty::Feature'             => '',
        'dicty::Search::Gene'        => '',
        'dicty::UI::Tabview::Config' => '',
        'dicty::Tests::Data'         => '',
    },
    configure_requires => {
        'Try::Tiny'    => '0.09',
        'TAP::Harness' => '3.22',
    },
    add_to_cleanup => ['GenomeREST-*'],
    create_readme  => 1,
);

$builder->create_build_script();

1;
