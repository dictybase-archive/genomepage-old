
=head1 NAME

   B<Genome::Tabview::Config::Panel::Item::JSON::Table> - Class for handling JSON table structures

=head1 VERSION

    This document describes B<Genome::Tabview::Config::Panel::Item::JSON::Table> version 1.0.0

=head1 SYNOPSIS

    my $table = Genome::Tabview::Config::Panel::Item::JSON::Table->new( -id => '12345_table');
    $table->add_column( -key => 'name',-label => ' ', -sortable => 'true');
    $table->add_column( -key => 'local', -label => 'Local coords.', -sortable => 'true');
    $table->add_column( -key => 'chrom', -label => 'Chrom. coords.', -sortable => 'true', -hidden => 'true');    
    
    my $data = {
        name => $label,
        local => $rel_start - $rel_end,
        chrom => $start - $end,
    }
    $table->add_record($data);
        return $table->structure;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Config::Panel::Item::JSON::Table> handles JSON::Table implementation.

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

package Genome::Tabview::Config::Panel::Item::JSON::Table;

use strict;
use Bio::Root::Root;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Config::Panel::Item::JSON::Table> object. 
 Usage    : my $json_section = Genome::Tabview::Config::Panel::Item::JSON::Table->new( 
                -id         => '123_table',
                -paginator  => 'true',
                -filter     => 'true' 
            );
 Returns  : Genome::Tabview::Config::Panel::Item::JSON::Table object.
 Args     : -id         :   optional, defines inner id for the table, generally used if 
                            table has to be tied to the different element function
            -paginator  :   optional, if set to be true, table will be displayed with paging
            -filter     :   optional, if set to be true, table will be displayed with filter
=cut

sub new {
    my ( $class, @args ) = @_;

    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    $self->{root} = Bio::Root::Root->new();

    my $arglist = [qw/ID PAGINATOR FILTER/];
    my ( $id, $paginator, $filter ) =
        $self->{root}->_rearrange( $arglist, @args );

    $self->id($id)               if $id;
    $self->filter($filter)       if $filter;
    $self->paginator($paginator) if $paginator;

    $self->type('table');
    return $self;
}

=head2 class

 Title    : class
 Function : sets/gets class property
 Usage    : my $table->class('go_table');
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
 Usage    : my $table->type('table');
 Returns  : string
 Args     : string
 
=cut

sub type {
    my ( $self, $arg ) = @_;
    $self->{type} = $arg if defined $arg;
    return $self->{type};
}

=head2 id

 Title    : id
 Function : sets/gets id property
 Usage    : my $table->id('123_table');
 Returns  : string
 Args     : string
 
=cut

sub id {
    my ( $self, $arg ) = @_;
    $self->{id} = $arg if defined $arg;
    return $self->{id};
}

=head2 filter

 Title    : filter
 Function : sets/gets filter property
 Usage    : my $table->filter('true');
 Returns  : string
 Args     : string
 
=cut

sub filter {
    my ( $self, $arg ) = @_;
    $self->{filter} = $arg if defined $arg;
    return $self->{filter};
}

=head2 paginator

 Title    : paginator
 Function : sets/gets paginator property
 Usage    : my $table->paginator('true');
 Returns  : string
 Args     : string
 
=cut

sub paginator {
    my ( $self, $arg ) = @_;
    $self->{paginator} = $arg if defined $arg;
    return $self->{paginator};
}

=head2 columns

 Title    : columns
 Function : sets/gets columns for the table
 Usage    : my $table->columns(\@columns);
 Returns  : array reference
 Args     : array reference
 
=cut

sub columns {
    my ( $self, $arg ) = @_;
    $self->{columns} = $arg if defined $arg;
    return $self->{columns};
}

=head2 records

 Title    : records
 Function : sets/gets records for the table
 Usage    : my $table->records(\@columns);
 Returns  : array reference
 Args     : array reference
 
=cut

sub records {
    my ( $self, $arg ) = @_;
    $self->{records} = $arg if defined $arg;
    return $self->{records};
}

=head2 add_column

 Title    : add_column
 Function : adds column for the table 
 Usage    : $table->add_column( -key => 'name', -label => ' ', -sortable => 'true');
 Returns  : nothing
 Args     : -key        : column key
            -label      : column label to be displayed
            -sortable   : whether column should be sortable
=cut

sub add_column {
    my ( $self, @args ) = @_;

    my $arglist = [qw/KEY LABEL SORTABLE WIDTH FORMATTER GROUP HIDDEN/];
    my ( $key, $label, $sortable, $width, $formatter, $group, $hidden ) =
        $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('key is not provided') if !$key;
    $label    = $key    if !$label;
    $sortable = 'false' if !$sortable;

    my $column = {
        key      => $key,
        label    => $label,
        sortable => $sortable
    };
    $column->{width}     = $width     if $width;
    $column->{formatter} = $formatter if $formatter;
    $column->{group}     = $group     if $group;
    $column->{hidden}    = $hidden    if $hidden;

    push @{ $self->{columns} }, $column;
    return;
}

=head2 add_record

 Title    : add_record
 Function : adds record for the table 
 Usage    : my $record = { name => $label, local => $rel_start - $rel_end, chrom => $start - $end };
            $table->add_record($record);
 Returns  : nothing
 Args     : hash with keys matching table columns
 
=cut

sub add_record {
    my ( $self, $arg ) = @_;
    push @{ $self->{records} }, $arg;
    return;
}

=head2 structure

 Title    : structure
 Function : returns table structure suitable for further JSON convertion
 Usage    : my $structure = $table->structure;
 Returns  : hash
 Args     : none
 
=cut

sub structure {
    my ( $self, $arg ) = @_;
    my $structure = {
        type        => $self->type,
        columns     => $self->columns,
        records     => $self->records,
        table_class => $self->class,
    };
    $structure->{id}        = $self->id        if $self->id;
    $structure->{filter}    = $self->filter    if $self->filter;
    $structure->{paginator} = $self->paginator if $self->paginator;
    return $structure;
}

=head2 to_json

 Title    : to_json
 Function : returns table structure suitable for further JSON convertion
 Usage    : my $structure = $table->structure;
 Returns  : hash
 Args     : none
 
=cut

sub to_json {
    my ( $self, $arg ) = @_;
    my $structure = $self->structure();
    return $structure;
}

1;
