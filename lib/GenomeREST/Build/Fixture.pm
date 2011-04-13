package GenomeREST::Build::Fixture;

# Other modules:
use Moose;
use namespace::autoclean;

# Module implementation
#

has 'chado_handler' => (
    is      => 'rw',
    does    => 'Module::Build::Chado::Loader::Bcs',
    handles => { chado => 'schema' }
);

has 'legacy_handler' => (
    is      => 'rw',
    does    => 'GenomeREST::Build::Role::SGD',
    handles => {
        'legacy'            => 'legacy_schema',
        'all_organism_rows' => 'all_organisms'
    }
);

1;    # Magic true value required at end of module

__END__

=head1 NAME

<MODULE NAME> - [One line description of module's purpose here]


=head1 SYNOPSIS

use <MODULE NAME>;

=for author to fill in:
Brief code example(s) here showing commonest usage(s).
This section will be as far as many users bother reading
so make it as educational and exeplary as possible.


=head1 DESCRIPTION

=for author to fill in:
Write a full description of the module and its features here.
Use subsections (=head2, =head3) as appropriate.


