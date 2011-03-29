package GenomeREST::Build::Role::SGD;

use strict;
use warnings;

# Other modules:
use Moose::Role;
use MOD::SGD;
use namespace::autoclean;

# Module implementation
#
requires 'dbh_withcommit';

has 'schema' => (
    is         => 'rw',
    isa        => 'MOD::SGD',
    lazy_build => 1,
);

sub _build_schema {
    my ($self) = @_;
    MOD::SGD->connect( sub { $self->dbh_withcommit } );
}


1;    # Magic true value required at end of module

