package GenomeREST::Builder;
use File::Spec::Functions;
use Carp;
use Try::Tiny;
use DBI;
use Class::MOP;
use Storable qw/dclone/;
use base qw/Module::Build::Chado/;


__PACKAGE__->property('legacy_ddl' ,  default => sub {
	return catfile(__PACKAGE__->current->base_dir,  'share',  'ddl',
	'multigenome_legacy.oracle');	
});

__PACKAGE__->property('ddl' ,  default => sub {
	return catfile(__PACKAGE__->current->base_dir,  'share',  'ddl',
	'multigenome_chado.oracle');	
});

__PACKAGE__->property('user' => 'TEST_CHADO');
__PACKAGE__->property('password' => 'TEST_CHADO');

__PACKAGE__->property('legacy_dsn' => 'dbi:Oracle:host=192.168.60.10;sid=dictybase');
__PACKAGE__->property('legacy_user' => 'TEST_LEGACY');
__PACKAGE__->property('legacy_password' => 'TEST_LEGACY');
__PACKAGE__->property('_legacy_handler');


sub legacy_setup {
	my ($self) = @_;
    print "running legacy setup\n" if $self->args('test_debug');
    
    return if $self->config('legacy_setup_done');

    my ( $scheme, $driver, $attr_str, $attr_hash, $driver_dsn )
        = DBI->parse_dsn( $self->legacy_dsn )
        or croak "cannot parse dbi dsn";

	my $db_class = 'Module::Build::Chado::' . ucfirst lc $driver;
    Class::MOP::load_class($db_class);
    my $legacy = $db_class->new( module_builder => $self );
    for my $attr (qw/ddl dsn user password/) {
    	my $api = 'legacy_'.$attr;
    	$legacy->$attr($self->$api);
    }
    $self->_legacy_handler($legacy);
    $self->config( 'legacy_setup_done', 1 );
    print "done with legacy setup\n" if $self->args('test_debug');

}

sub ACTION_deploy_legacy_schema {
	my ($self) = @_;
	$self->setup_legacy;
    $self->config( 'is_legacy_db_created', 1 );
	if (!$self->config('is_legacy_schema_loaded')) {
		$self->_legacy_handler->deploy_schema;
		$self->config('is_legacy_schema_loaded');
        print "loaded legacy schema\n" if $self->args('test_debug');
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
    $self->depends_on('legacy_setup');
}

sub ACTION_prune_fixture {
	my ($self) = @_;
    $self->SUPER::ACTION_prune_fixture(@_);
    $self->depends_on('legacy_setup');
    $self->_legacy_handler->prune_fixture;
    $self->config( 'is_legacy_fixture_loaded',   0 );
    $self->config( 'is_legacy_fixture_unloaded', 1 );
}


sub ACTION_drop_schema {
    my ($self) = @_;
    $self->SUPER::ACTION_drop_schema(@_);
    $self->depends_on('legacy_setup');
    $self->_legacy_handler->drop_schema;
    $self->config_data( 'is_legacy_schema_loaded' => 0 );
}


1;
