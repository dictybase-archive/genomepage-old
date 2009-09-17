
package DictyRESTBuilder;
use File::Spec::Functions;
use Carp;
use Archive::Extract;
use File::Path;
use Path::Class;
use IPC::Cmd qw/run/;
use dicty::Tests::Test_setup;

use base qw/Module::Build/;

sub load_fixture {
    my ($self) = @_;

    eval { dicty::Tests::Test_setup->check_fake_whole_chromosome() };
    return if !$@;

    my $script
        = file( $self->base_dir(), 'bin', 'load_fixture.pl' )->stringify;
    die "fixture script $script do not exist\n" if !-e $script;

    my ( $success, $error_code, $full_buff ) = run(
        command => [ 'perl', $script ],
        verbose => 0
    );

    if ( !$success ) {
        die join( "\n", @$full_buff ), "\n";
    }

}

sub unload_fixture {
    my ($self) = @_;
    my $script
        = file( $self->base_dir(), 'bin', 'unload_fixture.pl' )->stringify;
    die "fixture script $script do not exist\n" if !-e $script;

    my ( $success, $error_code, $full_buff ) = run(
        command => [ 'perl', $script ],
        verbose => 0
    );

    if ( !$success ) {
        die join( "\n", @$full_buff ), "\n";
    }

}

sub ACTION_deploy {
    my ($self) = @_;
    $self->depends_on('dist');
    my $file = catfile( $self->base_dir, $self->dist_dir . '.tar.gz' );
    my $archive = Archive::Extract->new( archive => $file );
    my $path = $self->prompt( 'Extract archive to:', $ENV{HOME} );
    my $fullpath = catdir( $path, $self->dist_dir );
    if ( -e $fullpath ) {
        rmtree( $fullpath, { verbose => 1 } );
    }
    $archive->extract( to => $path ) or confess $archive->error;
    my $logpath    = catdir( $fullpath, 'log' );
    my $cache_path = catdir( $logpath,  'prod_cache' );

    mkpath( $logpath, { verbose => 1, mode => 0777 } );
    chmod 0777, $logpath;

    mkpath( $cache_path, { verbose => 1, mode => 0777 } );
    chmod 0777, $cache_path;

    #now make the conf files readable
    my @conf = map { $_->stringify } dir( $fullpath, 'conf' )->children();
    chmod 0644, $_ foreach @conf;

}

#run tests files without the string 'optional' in their name
sub ACTION_testcore {
    my ($self) = @_;

    $self->load_fixture;

    my $test_files = [ grep { !/optional/ } @{ $self->find_test_files } ];
    $self->run_tap_harness($test_files);

    $self->unload_fixture;
}

1;
