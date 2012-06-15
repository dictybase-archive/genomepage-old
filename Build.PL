#!/usr/bin/perl -w
use strict;
use Module::Build;

my $builder = Module::Build->new(
    module_name  => 'GenomeREST',
    license      => 'perl',
    dist_author  => 'Siddhartha Basu<siddhartha-basu@northwestern.edu>',
    dist_version => '1.4.1',
    requires     => {
        'Mojolicious'                 => '1.21',
        'Module::Versions'            => '0.02',
        'Modware'                     => '0.001',
        'Mojolicious::Plugin::Bundle' => '0.005',
        'Mojolicious::Plugin::Cache'  => '0.0011',
        'MouseX::Params::Validate'    => '0.04',
        'MouseX::NativeTraits'        => '1.07',
        'JSON'                        => '2.50', 
        'DBIx::Class'                 => '0.08127',
        'Math::BigInt'                => '1.99',
        'Math::Base36'                => '0.09',
        'DBI'                         => '1.51',
        'DBD::Oracle'                 => '1.27'
    },
    add_to_cleanup => ['GenomeREST- *'],
    create_readme  => 1,
);

$builder->create_build_script();

1;
