#!/usr/bin/perl -w
use strict;
use warnings;
use lib '.';
use DictyRESTBuilder;

my $builder = DictyRESTBuilder->new(
    module_name  => 'DictyREST',
    license      => 'perl',
    dist_author  => 'Siddhartha Basu <siddhartha-basu@northwestern.edu>',
    dist_version => '1.0',
    requires     => {
        'Mojo'          => '',
        'Apache2::Mojo' => ''
    },
    build_requires => {
    	 'Archive::Extract' => '',
		},
    add_to_cleanup => ['DictyREST-*'],
    create_readme  => 1,
);

$builder->create_build_script();


package DictyRESTBuilder;

use base qw/Module::Build/;

sub ACTION_deploy {
    my ($self) = @_;
    $self->depends('dist');
    my $file = catfile( $self->base_dir, $self->dist_dir . '.tar.gz' );
    print $file, "\n";
}

1;
