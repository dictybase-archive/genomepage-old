
package DictyRESTBuilder;
use File::Spec::Functions;
use Carp;
use Archive::Extract;
use File::Path;

use base qw/Module::Build/;

sub ACTION_deploy {
    my ($self) = @_;
    $self->depends_on('dist');
    my $file = catfile( $self->base_dir, $self->dist_dir . '.tar.gz' );
    my $archive = Archive::Extract->new( archive => $file );
    my $path = $self->prompt( 'Extract archive to:', $ENV{HOME} );
    my $fullpath = catdir( $path, $self->dist_dir );
    if ( -e $fullpath ) {
        rmtree $fullpath;
    }
    $archive->extract( to => $path ) or confess $archive->error;

}

1;
