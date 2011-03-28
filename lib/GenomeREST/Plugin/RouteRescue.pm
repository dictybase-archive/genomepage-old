package GenomeREST::Plugin::RouteRescue;

use strict;
use base qw/Mojolicious::Plugin/;

sub register {
    my ( $self, $app ) = @_;
   
    $app->helper( get_resources => sub { 
        my ($c, $config) = @_;
        return $self->get_all_resources($config); 
    });
    $app->helper( assign_controllers => sub { 
        my ($c, $resources_hash) = @_;
        return $self->assign_controllers($resources_hash);        
    });

}

sub get_subresources {
    my ( $self, $hash ) = @_;
    return $hash->{content} || [];
}

sub get_all_resources {
    my ( $self, $hash ) = @_;
    my $allroutes;
    my $name = $hash->{name};

    my $branches = $self->get_subresources($hash);
    return {$name} if @$branches == 0;    # we've reached the end/leaf node

    foreach my $branch (@$branches) {
        my $partial_routes = $self->get_all_resources($branch);
        foreach my $route ( keys %$partial_routes ) {
            $allroutes->{$name} = 1 if $name;
            $allroutes->{ $name . '/' . $route } = 1;
        }
    }
    return $allroutes;
}

sub assign_controllers {
    my ( $self, $resource_hash ) = @_;
    foreach my $resource ( keys %$resource_hash ) {
        $resource =~ m{^(\/\S+\/)*(\S+)$};
        $resource_hash->{$resource} = {};
        my $controller = $1;
        my $action     = $2;
        $controller =~ s{^\/|\/$}{}g;
        $controller =~ s{\/}{-}g;
        $action     =~ s{\/}{}g;
        
#        if (!$controller){
#            $controller = $action;
#            $action = 'index';
#        }

        $resource_hash->{$resource}->{'controller'} = $controller
            if $controller;
        $resource_hash->{$resource}->{'action'} = $action if $action;
    }
    return $resource_hash;
}

1;

=head1 NAME

GenomeRest::Plugin::RouteRescue - parses routes out of config

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

## in application
plugin "GenomeREST::Plugin::RouteRescue"

my $resources_hash = $self->get_resources( $self->config->{page} );
my $resources_hash_with_controllers = $self->assign_controllers( $resources_hash );

foreach my $resource ( keys %$resources_hash_with_controllers ) {
    my $root       = 'genepage';
    my $controller = $resources_hash_with_controllers->{$resource}->{controller};
    my $action     = $resources_hash_with_controllers->{$resource}->{action};
    
    $root .= '-' . $controller if $controller;
    $root .= '#' . $action if $action;
    
    $self->app->log->debug($resource, $root);
    $r->route($resource)->to($root);
}

=head1 DESCRIPTION

provides get_resources method that accepts following configuration hash

{
   content :
      -  name   : path
         content: 
            -  name    : first
            -  name    : next
               content :
                  - name : show
}

returns hash in following format:
{
    '/path'           => { controller => 'path',      action => 'index' },
    '/path/first'     => { controller => 'path',      action => 'first' },
    '/path/next/show' => { controller => 'path-next', action => 'show' }
}

=head1 AUTHOR

I<Yulia Bushmanova> B<y-bushmanova@northwestern.edu>

    
