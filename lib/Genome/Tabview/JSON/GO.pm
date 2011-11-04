
=head1 NAME

   B<Genome::Tabview::JSON::GO> - Class for handling JSON representation of gene GO information

=head1 VERSION

    This document describes B<Genome::Tabview::JSON::GO> version 1.0.0

=head1 SYNOPSIS

    my $json_gene = Genome::Tabview::JSON::GO->new( -primary_id => <GENE ID>);
    my $gene_name =  = json_gene->name;
    
=head1 DESCRIPTION

    B<Genome::Tabview::JSON::GO> is a proxy class that provides gene information representation
    in a way suitable for furthure JSON convertion

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported. Please report any bugs or feature requests to B<dictybase@northwestern.edu>

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

package Genome::Tabview::JSON::GO;

use strict;
use Bio::Root::Root;
use Genome::Tabview::JSON::Reference;
use Genome::Tabview::Config::Panel::Item::JSON::Table;
use Modware::Publication::DictyBase;
use Modware::DataSource::Chado;
use DateTime::Format::Strptime;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::JSON::GO> object. 
 Usage    : my $page = Genome::Tabview::JSON::GO->new();
 Returns  : Genome::Tabview::JSON::GO object with default configuration.     
 Args     : -primary_id   - gene primary id.
 
=cut

sub new {
    my ( $class, @args ) = @_;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    my $arglist = [qw/PRIMARY_ID/];
    $self->{root} = Bio::Root::Root->new();
    my ( $primary_id, $section ) =
        $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('primary id is not provided') if !$primary_id;

    #    $self->{root}->throw('Id provided does not belong to a gene')
    #        if $primary_id !~ m{DDB_G}i;
    my $gene = dicty::Feature->new( -primary_id => $primary_id );
    my $schema     = Modware::DataSource::Chado->handler;
    
    my $rs = $schema->resultset('Sequence::FeatureCvterm')->search(
        { 'dbxref.accession' => $primary_id },
        { join               => { 'feature' => 'dbxref' } }
    );

    $self->{function_annotations} = $rs->search(
        { 'cv.name' => 'molecular_function' },
        { join      => { 'cvterm' => 'cv' } }
    );
    
    $self->{process_annotations} = $rs->search(
        { 'cv.name' => 'biological_process' },
        { join      => { 'cvterm' => 'cv' } }
    );
      
    $self->{component_annotations} = $rs->search(
        { 'cv.name' => 'cellular_component' },
        { join      => { 'cvterm' => 'cv' } }
    );  
    
    $self->{has_annotations} = 1
        if $self->{function_annotations}->count > 0
            || $self->{process_annotations}->count > 0
            || $self->{component_annotations}->count > 0;

#    my $go = $gene->go;
#    $self->source_go($go);
    return $self;
}

sub context {
    my ( $self, $arg ) = @_;
    $self->{context} = $arg if defined $arg;
    return $self->{context} if defined $self->{context};
}

=head2 json

 Title    : json
 Usage    : $reference->json->link(....);
 Function : gets/sets json handler. Uses Genome::Tabview::Config::Panel::Item::JSON as default one
 Returns  : nothing
 Args     : JSON handler

=cut

sub json {
    my ( $self, $arg ) = @_;
    $self->{json} = $arg if $arg;
    $self->{json} = Genome::Tabview::Config::Panel::Item::JSON->new()
        if !$self->{json};
    return $self->{json};
}

=head2 source_go

 Title    : source_go
 Usage    : $go->source_go($go);
 Function : gets/sets go, that would be used as a source for all calls
 Returns  : dicty::GO::GeneOntology object
 Args     : dicty::GO::GeneOntology object

=cut

sub source_go {
    my ( $self, $arg ) = @_;
    $self->{source_go} = $arg if defined $arg;
    $self->{root}->throw('GO is not defined')
        if not defined $self->{source_go};
    $self->{root}->throw('GO should be dicty::GO::GeneOntology')
        if ref( $self->{source_go} ) !~ m{dicty::GO::GeneOntology}x;
    return $self->{source_go};
}

=head2 function_annotations

 Title    : function_annotations
 Function : returns gene function_annotations
 Usage    : my $function_annotations = $go->function_annotations();
 Returns  : hash
 Args     : none
 
=cut

sub function_annotations {
    my ($self) = @_;
#    return $self->source_go->function_annotations;
    return $self->{function_annotations};
}

=head2 process_annotations

 Title    : process_annotations
 Function : returns gene process_annotations
 Usage    : my $process_annotations = $go->process_annotations();
 Returns  : hash
 Args     : none
 
=cut

sub process_annotations {
    my ($self) = @_;
#    return $self->source_go->process_annotations;
    return $self->{process_annotations};
}

=head2 component_annotations

 Title    : component_annotations
 Function : returns gene component_annotations
 Usage    : my $component_annotations = $go->component_annotations();
 Returns  : hash
 Args     : none
 
=cut

sub component_annotations {
    my ($self) = @_;
#    return $self->source_go->component_annotations;
    return $self->{component_annotations};
}

=head2 annotation_table

 Title    : annotation_table
 Function : Returns json formatted annotation table for the annotation
 Returns  : hash  
 Args     : none
 
=cut

sub annotation_table {
    my ( $self, $annotations ) = @_;
    my $table = Genome::Tabview::Config::Panel::Item::JSON::Table->new();
    $table->class('general');
    $table->add_column(
        -key       => 'ann',
        -label     => 'GO Term',
        -sortable  => 'true',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'evid',
        -label     => 'Evidence Code',
        -sortable  => 'true',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'ref',
        -label     => 'Reference',
        -sortable  => 'true',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'ref_link',
        -label     => ' ',
        -sortable  => 'true',
        -width     => '118',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'date',
        -label     => 'Date',
        -formatter => 'grouper',
    );

    foreach my $ann ($annotations->all) {
        my $json_ref = Genome::Tabview::JSON::Reference->new(
            -pub_id => $ann->pub_id );
		$json_ref->context($self->context) if $self->context;
        my $data = {
            ann      => $self->annotation_link($ann),
            evid     => $self->evidence($ann),
            ref      => [ $json_ref->citation ],
            ref_link => $json_ref->links,
            date     => [ $self->date($ann) ]
        };
        $table->add_record($data);
    }
    return $table->structure;
}

=head2 annotation_link

 Title    : annotation_link
 Function : Returns json formatted annotation link for the annotation
 Returns  : hash  
 Args     : none
 
=cut

sub annotation_link {
    my ( $self, $ann ) = @_;
    my $go_link = $self->json->link(
        -url => '/ontology/go/'
            . $ann->cvterm->dbxref->accession.'/annotation/page/1',
        -caption => $ann->cvterm->name,
        -type    => 'outer',
    );
    my @data;    
    my $qualifier = $self->get_qualifier($ann);

    push @data, $qualifier if $qualifier;
    push @data, $go_link;
    return \@data;
}

=head2 get_qualifier

 Title    : get_qualifier
 Function : Returns json formatted qualifier for the annotation
 Returns  : hash  
 Args     : none
 
=cut

sub get_qualifier {
    my ( $self, $ann ) = @_;

    my @data;
    push @data, '<B><i><font color="#CC0000">NOT</font></B></i>' if $ann->is_not;

    my $qualifiers =
        $ann->feature_cvtermprops->search( { 'type.name' => 'qualifier' },
        { join => 'type' } );
    while ( my $qualifier = $qualifiers->next ) {
        my $value = ucfirst($qualifier->value);
        $value =~ s{_}{ }g;
        push @data, $value;
    }

    return if !@data;
    return $self->json->text( '<b>' . join( ' ', @data ) . ' </b>' );
}

=head2 evidence

 Title    : evidence
 Function : Returns json formatted evidence for the annotation
 Returns  : hash  
 Args     : none
 
=cut

sub evidence {
    my ( $self, $ann ) = @_;
    my $json     = $self->json;
    my $evidence = $self->get_evidence($ann);
    my $code = $self->evidence_code($evidence);

    my $description_link = $json->link(
        -url     => "/db/cgi-bin/$ENV{'SITE_NAME'}/GO/goEvidence.pl#" . $code,
        -caption => '(' . $evidence->name . ')',
        -type    => 'outer',
    );
    
    my @evidence = ( $json->text( $code . '&nbsp;' ), $description_link );

    my $with      = $self->with($ann);
    if ($with) {
        my $with_from = $code eq 'IEA' ? 'from ' : 'with ';
        push @evidence, $json->text( '&nbsp;' . $with_from );
        push @evidence, @$with;
    }
    return \@evidence;
}

sub get_evidence {
    my ($self, $ann) = @_;
    return $ann->feature_cvtermprops->search_related(
        'type',
        { 'cv.name' => { -like => 'evidence_code%' } },
        { join      => 'cv' }
    )->first;
}

sub evidence_code {
    my ($self,$evidence)= @_;
    my $code = $evidence->search_related(
        'cvtermsynonym_cvterms',
        { 'type.name' => { -in => [qw/EXACT RELATED/] } },
        { join        => 'type' }
    )->first->synonym_;
    
    return $code
}

=head2 uppercaseWords

 Title    : uppercaseWords
 Function : This method converst all the words to Capital case. UI::Util stuff to replace later on
 Returns  : string  
 Args     : string
 
=cut

sub uppercaseWords {
    my ( $self, $sentence ) = @_;
    my @words = split( / /, $sentence );
    undef $sentence;
    foreach my $word (@words) {
        if ( $word !~ /^(from|on|in|of|or|structural)$/ ) {
            $word = "\u$word";
        }
        $sentence .= " " . $word;
    }
    $sentence =~ s/^ //;
    return $sentence;
}

=head2 with

 Title    : with_from
 Function : Returns with/ from part of the evidence
 Returns  : hash  
 Args     : string
 
=cut

sub with {
    my ( $self, $ann ) = @_;
    my $json   = $self->json;
    
    my $with = $ann->feature_cvtermprops->search( 
        { 'type.name' => 'with' },
        { join => 'type' } 
    );
    return if !$with->count;

    my @data;
    while (my $dbxref = $with->next){
        my ($db, $id) = split(':', $dbxref->value );
        my $url =
              $db =~ m{TAIR}i ? $self->link('TAIR')->get_links($id)
            : $db =~ m{EC}i
            ? $self->link('EC')->get_links( split( /\./, $id ) )
            : $db =~ m{DDB}i || $db =~ m{DictyBas}i
            ? $self->link('dictyBase Gene Page')->get_links($id)
            : $self->link($db)->get_links($id);

        my $link = $json->link(
            -url     => $url,
            -caption => $id,
            -type    => 'outer',
        ) if $url;

        push @data, ( $json->text( '&nbsp;' . $db . ':&nbsp;' ), $link )
            if $link;
    }

    return if !@data;
    return \@data;
}

=head2 date

 Title    : date
 Function : Returns date part of the evidence
 Returns  : hash  
 Args     : string
 
=cut

sub date {
    my ( $self, $ann ) = @_;
    my $json   = $self->json;
    
    my $date = $ann->feature_cvtermprops->search( 
        { 'type.name' => 'date' },
        { join => 'type' } 
    )->first;
    return if !$date;
    
    my $parser = DateTime::Format::Strptime->new(pattern => '%Y%m%d');
    return $json->text($parser->parse_datetime($date->value)->strftime('%d-%b-%y'));
}

=head2 link

 Title    : link
 Function : returns link object for provided source
 Returns  : dicty::Link
 Usage    : $self->link('UniProt')->get_links('O77203')
 Args     : string

=cut

sub link {
    my ( $self, $source ) = @_;
    $self->throw('source not provided') if !$source;
    return dicty::Link->new( -SOURCE => $source );
}

1;
