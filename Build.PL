#!/usr/bin/perl -w
use strict;
use warnings;
use YAML qw/LoadFile/;
use File::Spec::Functions;
use lib 'lib';
use GenomeREST::Build;

my $builder = GenomeREST::Build->new(
    module_name  => 'GenomeREST',
    license      => 'perl',
    dist_author  => 'Siddhartha Basu <siddhartha-basu@northwestern.edu>',
    dist_version => '1.4.0',
    requires     => {
        'Mojolicious'                 => '0.999938',
        'YAML::XS'               => '0.32',
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
        'Try::Tiny'            => '0.09',
        'TAP::Harness'         => '3.22',
        'Module::Build::Chado' => '0.0011'
    },
    add_to_cleanup => ['GenomeREST-*'],
    create_readme  => 1,
);

my ( $conf, $file );

## -- default is to use test.yaml from conf folder of the application
if ( !$builder->dsn ) {
    $file = catfile( $builder->base_dir, 'conf', 'test.yaml' );
    die "test.yaml config file not found in $file !!!! Please create one\n"
        if !-e $file;

    $conf = LoadFile($file);
    die "no database section found!! Please create one\n"
        if not defined $conf->{database};

    my $db_conf = $conf->{database};
    $builder->dsn( $db_conf->{dsn} );
    $builder->user( $db_conf->{user} );
    $builder->password( $db_conf->{password} );
}

$builder->ddl(
    catfile( $builder->base_dir, 'share', 'ddl', 'multigenome_chado.oracle' )
) if !$builder->ddl;

if ( !$builder->legacy_dsn ) {
    if ( !$file ) {
        $file = catfile( $builder->base_dir, 'conf', 'test.yaml' );
        die
            "test.yaml config file not found in $file !!!! Please create one\n"
            if !-e $file;
    }

    $conf = $conf ? $conf : LoadFile($file);
    die "no legacy database section found!! Please create one\n"
        if not defined $conf->{legacy_database};

    my $ldb_conf = $conf->{legacy_database};
    $builder->legacy_dsn( $ldb_conf->{legacy_dsn} );
    $builder->legacy_user( $ldb_conf->{legacy_user} );
    $builder->legacy_password( $ldb_conf->{legacy_password} );
}

$builder->legacy_ddl(
    catfile( $builder->base_dir, 'share', 'ddl', 'multigenome_legacy.chado' )
) if !$builder->legacy_ddl;

$builder->create_build_script();

1;
