package DictyRESTBuilder;
use File::Spec::Functions;
use Carp;
use Archive::Extract;
use File::Path;
use Path::Class;
use Try::Tiny;
use TAP::Harness;
use IPC::Cmd qw/run/;
use File::Spec::Functions;
use Data::Dumper;
use base qw/Module::Build/;

sub load_core_fixture {
    my ($self) = @_;

    require dicty::Tests::Data;
    my $data = dicty::Tests::Data->new();
    $self->notes( loader => $data );

    if ( !$data->check_chromosome() ) {
        try {
            $data->insert_core_data();
        }
        catch {
            die "unable to insert data: $_";
        }
    }
}

sub load_fixture {
    my ($self) = @_;

    require dicty::Tests::Data;
    my $data = dicty::Tests::Data->new();
    $self->notes( loader => $data );

    if ( !$data->check_chromosome() ) {
        try {
            $data->insert_whole_chromosome();
        }
        catch {
            die "unable to insert data: $_";
        }
    }
}

sub unload_fixture {
    my ($self) = @_;
    my $loader = $self->notes('loader');
    try {
        $loader->unload_data();
    }
    catch {
        die "error in unloading: $_";
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
    my $logpath        = catdir( $fullpath, 'log' );
    my $cache_path     = catdir( $fullpath, 'tmp' );
    my $web_cache_path = catdir( $fullpath, 'webtmp' );

    mkpath( $logpath, { verbose => 1, mode => 0777 } );
    chmod 0777, $logpath;

    mkpath( $cache_path, { verbose => 1, mode => 0777 } );
    chmod 0777, $cache_path;

    mkpath( $web_cache_path, { verbose => 1, mode => 0774 } );
    chmod 0777, $web_cache_path;

    #now make the conf files readable
    my @conf = map { $_->stringify } dir( $fullpath, 'conf' )->children();
    chmod 0644, $_ foreach @conf;

}

#run tests files without the string 'optional' in their name
sub ACTION_testcore {
    my ($self) = @_;
    $self->load_core_fixture;

    $self->depends_on('build');
    my $tap = TAP::Harness->new(
        { lib => [ catdir( $self->base_dir, 'blib', 'lib' ) ] } );
    my @test_files = grep { !/optional/ } @{ $self->find_test_files };

    $tap->runtests(@test_files);
    $self->unload_fixture;
}

sub ACTION_test {
    my ( $self, @arg ) = @_;
    $self->load_core_fixture();
    $self->SUPER::ACTION_test(@arg);
    $self->unload_fixture;
}

sub ACTION_start_daemon {
    my $self = shift;
    my $script = catfile( 'bin', 'dicty_rest' );
    my $cmd
        = "$script daemon_prefork --daemonize --clients 250 --keepalive 60 --servers 250";
    $cmd .= '--port ' . $self->args('port') if $self->args('port');
    if ( scalar run( command => $cmd, verbose => 1 ) ) {
        print "started the prefork daemon\n";
    }
    else {
        warn "daemon did not start\n";
    }
}

sub ACTION_stop_daemon {
    my $self = shift;
    my $buffer;
    my $cmd
        = 'ps -f `pgrep dicty_rest` | awk \'{if ($3 == 1) { print $2 }}\'';

	## -- bunch of if else loop follows
    if ( scalar run( command => $cmd, verbose => 1, buffer => \$buffer ) ) {
        if ($buffer) {
            chomp $buffer;
            if ( scalar run( command => "kill -TERM $buffer", verbose => 1 ) )
            {
                print "prefork daemon stopped\n";
            }
            else {
                print "unable to stop prefork daemon\n";
            }
        }
        else {
            print "daemon not running\n";
        }
    }
    else {
        print "issue with running command\n";
    }
}

1;
