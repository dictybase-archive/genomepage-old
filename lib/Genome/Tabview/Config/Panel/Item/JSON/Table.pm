
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
use namespace::autoclean;
use Mouse;
use MouseX::Params::Validate;

has [qw/id paginator filter class table_class/] => (
    is  => 'rw',
    isa => 'Str'
);

has 'type' => ( is => 'rw', isa => 'Str', lazy => 1, default => 'table' );

=head2 class

 Title    : class
 Function : sets/gets class property
 Usage    : my $table->class('go_table');
 Returns  : string
 Args     : string
 
=cut

=head2 type

 Title    : type
 Function : sets/gets type property, that is "table" for this class
 Usage    : my $table->type('table');
 Returns  : string
 Args     : string
 
=cut

=head2 id

 Title    : id
 Function : sets/gets id property
 Usage    : my $table->id('123_table');
 Returns  : string
 Args     : string
 
=cut

=head2 filter

 Title    : filter
 Function : sets/gets filter property
 Usage    : my $table->filter('true');
 Returns  : string
 Args     : string
 
=cut

=head2 paginator

 Title    : paginator
 Function : sets/gets paginator property
 Usage    : my $table->paginator('true');
 Returns  : string
 Args     : string
 
=cut

=head2 columns

 Title    : columns
 Function : sets/gets columns for the table
 Usage    : my $table->columns(\@columns);
 Returns  : array reference
 Args     : array reference
 
=cut

has '_column_stack' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    traits  => [qw/Array/],
    lazy    => 1,
    default => sub { [] },
    handles => {
        'add_to_column' => 'push',
        'columns'       => 'elements'
    }
);

=head2 add_column

 Title    : add_column
 Function : adds column for the table 
 Usage    : $table->add_column(key => 'name', label => ' ', sortable => 'true');
 Returns  : nothing
 Args     : key        : column key
            label      : column label to be displayed
            sortable   : whether column should be sortable
=cut

sub add_column {
    my $self = shift;
    my ( $key, $label, $sortable, $width, $formatter, $group, $hidden )
        = validated_list(
        \@_,
        key      => { isa => 'Str' },
        label    => { isa => 'Str', optional => 1 },
        sortable => { isa => 'Str', optional => 1, default => 'false' },
        width     => { isa => 'Str', optional => 1 },
        formatter => { isa => 'Str', optional => 1 },
        group     => { isa => 'Str', optional => 1 },
        hidden    => { isa => 'Str', optional => 1 }
        );

    $label = $key if !$label;
    my $column = {
        key      => $key,
        label    => $label,
        sortable => $sortable
    };
    $column->{width}     = $width     if $width;
    $column->{formatter} = $formatter if $formatter;
    $column->{group}     = $group     if $group;
    $column->{hidden}    = $hidden    if $hidden;
    $self->add_to_column($column);
}

=head2 records

 Title    : records
 Function : sets/gets records for the table
 Usage    : my $table->records(\@columns);
 Returns  : array reference
 Args     : array reference
 
=cut

has '_record_stack' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    traits  => [qw/Array/],
    lazy    => 1,
    default => sub { [] },
    handles => {
        'add_record' => 'push',
        'records'    => 'elements'
    }
);

=head2 add_record

 Title    : add_record
 Function : adds record for the table 
 Usage    : my $record = { name => $label, local => $rel_start - $rel_end, chrom => $start - $end };
            $table->add_record($record);
 Returns  : nothing
 Args     : hash with keys matching table columns
 
=cut

=head2 structure

 Title    : structure
 Function : returns table structure suitable for further JSON convertion
 Usage    : my $structure = $table->structure;
 Returns  : hash
 Args     : none
 
=cut

sub structure {
    my ($self) = @_;
    my $structure;
    $structure->{$_} = $self->$_ for qw/type table_class/;
    for my $param (qw/id filter paginator/) {
        $structure->{$param} = $self->$param if $self->$param;
    }
    for my $param (qw/records columns/) {
        push @{ $structure->{$param} }, $_ for $self->$param;
    }
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
    my ($self) = @_;
    my $structure = $self->structure();
    return $structure;
}

1;
