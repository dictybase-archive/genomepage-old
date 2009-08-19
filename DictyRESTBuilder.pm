
package DictyRESTBuilder;
use File::Spec::Functions;
use Carp;
use Archive::Extract;
use File::Path;
use Path::Class;

use base qw/Module::Build/;

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
    my $logpath = catdir( $fullpath, 'log' );
    my $cache_path = catdir($logpath,  'prod_cache');

    mkpath( $logpath, { verbose => 1, mode => 0777 } );
    chmod 0777, $logpath;

    mkpath( $cache_path, { verbose => 1, mode => 0777 } );
    chmod 0777, $cache_path;

    #now make the conf files readable
    my @conf = map { $_->stringify } dir ($fullpath, 'conf' )->children();
    chmod 0644, $_ foreach @conf;

}

1;
