#!/usr/bin/perl -w
use strict;
use warnings;
use lib 'lib';
use GenomeREST::Builder;

my $builder = GenomeREST::Builder->new(
    module_name  => 'GenomeREST',
    license      => 'perl',
    dist_author  => 'Yulia Bushmanova <y-bushmanova@northwestern.edu>',
    dist_version => '1.4.1',
    requires     => {
        'Mojolicious'                 => '1.21',
        'YAML::XS'                    => '',
        'Plack'                       => '0.9941',
        'Module::Versions'            => '0.02',
        'FCGI::Engine'                => '0.16',
        'Homology::Group'             => '',
        'Modware'                     => '0.001',
        'Mojolicious::Plugin::Bundle' => '0.001',
        'Mojolicious::Plugin::Cache'  => '0.0011',
        'dicty::Tests::Data'          => '',
        'dicty::Search::Gene'         => '',
        'dicty::UI::Tabview::Config'  => '',
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
