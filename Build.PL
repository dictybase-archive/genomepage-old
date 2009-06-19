use strict;
use warnings;
use Module::Build;

my $class = Module::Build->subclass (
	 class => 'DictyREST::Builder',
	 code => q {
	 		sub ACTION_deploy {
	 			 my ($self) = @_;
			}
	 },
);
my $builder = $class->new(
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
