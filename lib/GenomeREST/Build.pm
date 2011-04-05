package GenomeREST::Build;
use File::Spec::Functions;
use Carp;
use Try::Tiny;
use DBI;
use Class::MOP;
use base qw/Module::Build::Chado/;

__PACKAGE__->add_property('legacy_ddl');
__PACKAGE__->add_property('legacy_dsn');
__PACKAGE__->add_property('legacy_user');
__PACKAGE__->add_property('legacy_password');
__PACKAGE__->add_property('data_folder');
__PACKAGE__->add_property('_legacy_handler');

sub legacy_setup {
    my ($self) = @_;
    print "running legacy setup\n" if $self->test_debug;

    return if $self->config('legacy_setup_done');

    my ( $scheme, $driver, $attr_str, $attr_hash, $driver_dsn )
        = DBI->parse_dsn( $self->legacy_dsn )
        or croak "cannot parse dbi dsn";

    my $db_class = 'Module::Build::Chado::' . ucfirst lc $driver;
    Class::MOP::load_class($db_class);
    my $legacy = $db_class->new( loader => 'GenomeREST::Build::Role::SGD' );
    $legacy->module_builder($self);
    for my $attr (qw/ddl dsn user password/) {
        my $api = 'legacy_' . $attr;
        $legacy->$attr( $self->$api );
    }
    $legacy->superuser($self->legacy_user);
    $legacy->superpassword($self->legacy_password);

    $self->_legacy_handler($legacy);
    $self->config( 'legacy_setup_done' ,  1 );
    print "done with legacy setup\n" if $self->test_debug;

}

sub ACTION_deploy_legacy_schema {
    my ($self) = @_;
    $self->legacy_setup;
    $self->feature( 'is_legacy_db_created' => 1 );
    if ( !$self->feature('is_legacy_schema_loaded') ) {
        $self->_legacy_handler->deploy_schema;
        $self->feature('is_legacy_schema_loaded' => 1);
        print "loaded legacy schema\n" if $self->test_debug;
    }
}

sub ACTION_deploy_schema {
    my ($self) = @_;
    $self->SUPER::ACTION_deploy_schema(@_);
    $self->depends_on('deploy_legacy_schema');
}

sub ACTION_load_fixture {
    my ($self) = @_;
    $self->depends_on('deploy_schema');
    $self->SUPER::ACTION_load_fixture(@_);

    ## -- now load additional data

    ## -- then load fixtures for legacy schema
}

sub ACTION_unload_fixture {
    my ($self) = @_;
    $self->SUPER::ACTION_unload_fixture(@_);

    ## -- unload anything additional

    ## -- unload legacy fixture
    $self->legacy_setup;
    $self->feature( 'is_legacy_fixture_loaded' =>  0 );
    $self->feature( 'is_legacy_fixture_unloaded' => 1 );
}

sub ACTION_prune_fixture {
    my ($self) = @_;
    $self->SUPER::ACTION_prune_fixture(@_);
    $self->legacy_setup;
    $self->_legacy_handler->prune_fixture;
    $self->feature( 'is_legacy_fixture_loaded' =>  0 );
    $self->feature( 'is_legacy_fixture_unloaded' => 1 );
}

sub ACTION_drop_schema {
    my ($self) = @_;
    $self->SUPER::ACTION_drop_schema(@_);
    $self->legacy_setup;
    $self->_legacy_handler->drop_schema;
    $self->feature( 'is_legacy_schema_loaded' => 0 );
}

sub ACTION_show_properties {
    my ($self) = @_;
    for my $prop (
        qw/ddl dsn user password legacy_ddl legacy_dsn legacy_password
        legacy_user/
        )
    {
        print $prop, " => ", $self->$prop, "\n" if $self->$prop;
    }
}

1;
