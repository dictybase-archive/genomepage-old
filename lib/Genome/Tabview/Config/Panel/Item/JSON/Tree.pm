
=head1 NAME

   B<Genome::Tabview::Config::Panel::Item::JSON::Tree> - Class for handling JSON Tree structures

=head1 VERSION

    This document describes B<Genome::Tabview::Config::Panel::Item::JSON::Tree> version 1.0.0

=head1 SYNOPSIS

    my $tree = Genome::Tabview::Config::Panel::Item::JSON::Tree->new( 
        -action => 'filter',  
        -argument => 'table_0001'
    );
    my $child_node = $tree->node(
        -type     => 'text',
        -label    => 'Mutants/Phenotypes',
        -title => 'Click to show only papers with Mutants/Phenotypes topic',       
    );
    my $node = $tree->node(
        -type     => 'text',
        -label    => 'Genetics/Cell Biology',
        -expanded => 'true',
        -children => [$child_node],     
    );
    
    $tree->add_node($node);   
    my $json = $tree->structure;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Config::Panel::Item::JSON::Tree> handles JSON::Tree implementation.

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.Please report any bugs or feature requests to

B<dictybase@northwestern.edu>

=head1 TODO

=head1 AUTHOR

I<Yulia Bushmanova> B<y-bushmanova@northwestern.edu>
I<Siddhartha Basu>  B<siddhartha-basu@northwestern.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) B<2007>, Dictybase C<<dictybase@northwestern.edu>>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=head1 APPENDIX

   The rest of the documentation details each of the object
   methods. Internal methods are usually preceded with a _

=cut

package Genome::Tabview::Config::Panel::Item::JSON::Tree;

use strict;
use Bio::Root::Root;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Config::Panel::Item::JSON::Tree> object. 
 Usage    : my $json_section = Genome::Tabview::Config::Panel::Item::JSON::Tree->new(
                -action => 'filter',  
                -argument => 'table_0001'
            );
 Returns  : Genome::Tabview::Config::Panel::Item::JSON::Tree object.
 Args     :  -action :    optional string, defines action to be associated 
                            with the onClick event for tree nodes,  
             -argument :   required if action argument have been passed, 
                            defines id of the element, action to be used on
=cut

sub new {
    my ( $class, @args ) = @_;

    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    $self->{root} = Bio::Root::Root->new();

    my $arglist = [qw/ACTION ARGUMENT/];
    my ( $action, $argument ) = $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('argument is not provided') if $action && !$argument;
    $self->{root}->throw('action is not provided') if $argument && !$action;

    $self->action($action);
    $self->argument($argument);
    $self->type('tree');
    return $self;
}

=head2 class

 Title    : class
 Function : sets/gets class property
 Usage    : my $tree->class('topic_tree');
 Returns  : string
 Args     : string
 
=cut

sub class {
    my ( $self, $arg ) = @_;
    $self->{class} = $arg if defined $arg;
    return $self->{class};
}

=head2 type

 Title    : type
 Function : sets/gets type property, that is "table" for this class
 Usage    : my $tree->type('tree');
 Returns  : string
 Args     : string
 
=cut

sub type {
    my ( $self, $arg ) = @_;
    $self->{type} = $arg if defined $arg;
    return $self->{type};
}

=head2 nodes

 Title    : nodes
 Function : sets/gets nodes for the tree
 Usage    : my $tree->nodes(\@nodes);
 Returns  : array reference
 Args     : array reference
 
=cut

sub nodes {
    my ( $self, $arg ) = @_;
    $self->{nodes} = $arg if defined $arg;
    return $self->{nodes};
}

=head2 action

 Title    : action
 Function : sets/gets action property
 Usage    : my $tree->action('filter');
 Returns  : string
 Args     : string
 
=cut

sub action {
    my ( $self, $arg ) = @_;
    $self->{action} = $arg if defined $arg;
    return $self->{action};
}

=head2 argument

 Title    : argument
 Function : sets/gets argument property
 Usage    : my $tree->argument('table_0010101');
 Returns  : string
 Args     : string
 
=cut

sub argument {
    my ( $self, $arg ) = @_;
    $self->{argument} = $arg if defined $arg;
    return $self->{argument};
}

=head2 node

 Title    : node
 Function : creates tree node
 Usage    : my $node = $tree->node( 
                -type => 'Text', 
                -label => 'Hello', 
                -title => 'click here',
                -expanded => 'true',
                -children => \@child_nodes, 
            );
 Returns  : hash
 Args     : -type       : type of the node (Text/HTML/MenuNode), 
            -label      : label to display, 
            -title      : text to show in tooltip,
            -expanded   : is node expanded by default,
            -children   : reference to an array of child nodes 
=cut

sub node {
    my ( $self, @args ) = @_;

    my $arglist = [qw/TYPE LABEL TITLE EXPANDED CHILDREN/];
    my ( $type, $label, $title, $expanded, $children ) =
        $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('type is not provided')  if !$type;
    $self->{root}->throw('label is not provided') if !$label;

    my $node = {
        type  => $type,
        label => $label,
    };
    $node->{title}    = $title    if $title;
    $node->{expanded} = $expanded if $expanded;
    $node->{children} = $children if $children;

    return $node;
}

=head2 add_node

 Title    : add_node
 Function : adds tree node 
 Usage    : $tree->add_node($node);
 Returns  : nothing
 Args     : node 
 
=cut

sub add_node {
    my ( $self, $node ) = @_;
    return if !$node;
    push @{ $self->{nodes} }, $node;
}

=head2 structure

 Title    : structure
 Function : returns table structure suitable for further JSON convertion
 Usage    : my $structure = $table->structure;
 Returns  : hash
 Args     : none
 
=cut

sub structure {
    my ($self) = @_;
    my $structure = {
        type  => $self->type,
        nodes => $self->nodes,
    };
    $structure->{action}   = $self->action   if $self->action;
    $structure->{argument} = $self->argument if $self->argument;
    return $structure;
}

1;
