use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'DictyREST',
    license             => 'perl',
    dist_author         => 'Siddhartha Basu <siddhartha-basu@northwestern.edu>',
    dist_version => '1.0',
    requires => {
    	 'Mojo' => '',
    	 'Apache2::Mojo' => ''
    },
    add_to_cleanup      => [ 'DictyREST-*' ],
    create_readme => 1,
);

$builder->create_build_script();
