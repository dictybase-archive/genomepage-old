#!/usr/bin/perl -w
use strict;
use warnings;
use lib 'lib';
use GenomeREST::Builder;

my $builder = GenomeREST::Builder->new(
    module_name  => 'GenomeREST',
    license      => 'perl',
    dist_author  => 'Siddhartha Basu<siddhartha-basu@northwestern.edu>',
    dist_version => '1.4.1',
    requires     => {
        'Mojolicious'                 => '1.21',
        'YAML::XS'                    => '0.34',
        'Plack'                       => '0.9941',
        'Module::Versions'            => '0.02',
        'FCGI::Engine'                => '0.16',
        'Modware'                     => '0.001',
        'Mojolicious::Plugin::Bundle' => '0.001',
        'Mojolicious::Plugin::Cache'  => '0.0011',
        'MouseX::Params::Validate'    => '0.04',
        'MouseX::NativeTraits'        => '1.07',
        'JSON'                        => '2.50'
    },
    add_to_cleanup => ['GenomeREST- *'],
    create_readme  => 1,
);

$builder->create_build_script();

1;
