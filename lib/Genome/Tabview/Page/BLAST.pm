
=head1 NAME

   B<Genome::Tabview::Page::BLAST> - Class for handling BLAST page configuration

=head1 VERSION

    This document describes B<Genome::Tabview::Page::BLAST> version 1.0.0

=head1 SYNOPSIS
    # -- to display blast page with selector for sequences available for the gene
    my $page = Genome::Tabview::Page::BLAST->new( 
        -primary_id => <GENE ID>, 
    );
    
    # -- to display blast page prefilled with feature sequence 
    my $page = Genome::Tabview::Page::BLAST->new( 
        -primary_id => 'DDB0185055',
        -sequence   => 'Protein' 
    );
    
    # -- to display generic blast page
    my $page = Genome::Tabview::Page::BLAST->new();
    
    # -- to get resulting HTML
    my $output = $page->process();
    print $cgi->header(), $output;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::BLAST> handles tabbed gene page configuration. It allows to set up
    tabs to show, their order and provides functionality to checks aviability of each tab for the 
    particular gene. Expects gene primary id to be passed. Uses gene_tabview.tt and error.tt 
    templates as default page and error templates respectively. For reserved genes, such as actin, 
    only gene summary tab will be displayed. Sets Gene Summary Tab as active if active tab parameter 
    is not passed.

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

 dicty::Template;
 Bio::Root::Root;
 Genome::Tabview::Page;
 SOAP::Lite;
 IO::String;
 Bio::SearchIO;
 Bio::Graphics;
 Bio::SeqFeature::Generic;
 File::Spec::Functions;
 
=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.Please report any bugs or feature requests to B<dictybase@northwestern.edu>

=head1 TODO

=head1 AUTHOR

I<Yulia Bushmanova> B<y-bushmanova@northwestern.edu>
I<Siddhartha Basu>  B<siddhartha-basu@northwestern.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) B<2007>, dictyBase <<dictybase@northwestern.edu>>. All rights reserved.

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

package Genome::Tabview::Page::BLAST;

use strict;
use dicty::Template;
use Bio::Root::Root;
use Bio::SearchIO::Writer::HTMLResultWriter;
use SOAP::Lite;
use IO::String;
use Bio::SearchIO;
use Bio::Graphics;
use Bio::SeqFeature::Generic;
use File::Spec::Functions;
use ModConfig;
use JSON;

use base qw(Genome::Tabview::Page);

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Page::BLAST> object. 
            Sets templates and configuration parameters for tabs to be displayed.
            Uses gene_tabview.tt template and error.tt template a default page 
            and error templates respectively. 
            If active tab have not been set, activates Gene Summary tab, if available.
 Usage    : # -- to display blast page with selector for sequences available for the gene
            my $page = Genome::Tabview::Page::BLAST->new( 
                -primary_id => <GENE ID>, 
            );

            # -- to display blast page prefilled with feature sequence 
            my $page = Genome::Tabview::Page::BLAST->new( 
                -primary_id => 'DDB0185055',
                -sequence   => 'Protein' 
            );
    
            # -- to display generic blast page
            my $page = Genome::Tabview::Page::BLAST->new();
 Returns  : Genome::Tabview::Page::BLAST object with default configuration if.
 Args     : -primary_id : feature primary id (mandatory)
          : -template : name of the TT template(optional), default is gene_tabview_test.tt
 
=cut

sub new {
    my ( $class, @args ) = @_;

    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    $self->{root} = Bio::Root::Root->new();
    my $arglist = [qw/PRIMARY_ID SEQUENCE/];

    my ( $primary_id, $sequence ) =
        $self->{root}->_rearrange( $arglist, @args );

    $self->primary_id($primary_id) if $primary_id;
    $self->sequence($sequence)     if $sequence;

    ## -- BLAST server settings
    my $conf       = ModConfig->load;
    my $blast_host = $conf->value('BLAST_SERVER');
    $blast_host .= ":" . $conf->value('BLAST_PORT')
        if $conf->value('BLAST_PORT');

    my $blast_server =
        SOAP::Lite->ns( 'http://' . $conf->value('SITE_NAME') . '.org/Blast' )
        ->proxy("http://$blast_host/cgi-bin/blast.pl");

    $self->server($blast_server);

    my ( $programs, $databases, $matrices ) =
        @{ $blast_server->config->result };
    $self->programs($programs);
    $self->databases($databases);

    ## -- defaut templates to use
    my $page_template  = dicty::Template->new( -name => 'blast.tt' );
    my $error_template = dicty::Template->new( -name => 'error.tt' );

    $self->template($page_template);
    $self->error_template($error_template);
    $self->{conf} = $conf;

    return $self;
}

=head2 sequence

 Title    : sequence
 Usage    : $page->sequence($sequence);
 Function : gets/sets sequence parameter
 Returns  : string
 Args     : string

=cut

sub sequence {
    my ( $self, $arg ) = @_;
    $self->{sequence} = $arg if defined $arg;
    return $self->{sequence};
}

=head2 server

 Title    : server
 Usage    : $page->server($server);
 Function : gets/sets server
 Returns  : string
 Args     : string

=cut

sub server {
    my ( $self, $arg ) = @_;
    $self->{server} = $arg if defined $arg;
    return $self->{server};
}

=head2 programs

 Title    : programs
 Usage    : $page->programs($programs);
 Function : gets/sets programs
 Returns  : string
 Args     : string

=cut

sub programs {
    my ( $self, $arg ) = @_;
    $self->{programs} = $arg if defined $arg;
    return $self->{programs};
}

=head2 databases

 Title    : databases
 Usage    : $page->databases($databases);
 Function : gets/sets programs
 Returns  : string
 Args     : string

=cut

sub databases {
    my ( $self, $arg ) = @_;
    $self->{databases} = $arg if defined $arg;
    return $self->{databases};
}

=head2 process

 Title    : process
 Usage    : my $output = $page->process();
 Function : Processes page config and returns html. Chooses the template to use 
            based on the result of the ID validation.
 Returns  : string
 Args     : none

=cut

sub process {
    my ( $self, $arg ) = @_;
    my $params;
    my $output;
    my $message = $self->validate_id if $self->primary_id;

    if ($message) {
        $params->{message} = $message;
        $output = $self->error_template->process($params);
    }
    else {
        $params->{primary_id} = $self->primary_id if $self->primary_id;
        $params->{sequence}   = $self->sequence   if $self->sequence;
        $params->{header}     = "BLAST";
        $params->{site_name}  = $self->{conf}->value('SITE_NAME');
        $output = $self->template->process($params);
    }
    return $output;
}

=head2 blast

 Title    : blast
 Usage    : my $report = $page->blast(
                -e => '0.1', 
                -M => 'BLOSUM62', 
                -F => 'T', 
                -g => 'T', 
                -b => 50, 
                -p => 'blastn', 
                -d => 'dicty_chromosomal', 
                -i => 'SAMPLESEQUENCE' 
            );
 Function : Runs BLAST and returnes report
 Returns  : string
 Args     : blast parameters

=cut

sub blast {
    my ( $self, @args ) = @_;
    my $arglist =
        [qw/PROGRAM DATABASE EVALUE MATRIX FILTER GAPPED LIMIT SEQUENCE/];

    my ($program, $database, $evalue, $matrix,
        $filter,  $gapped,   $limit,  $sequence
    ) = $self->{root}->_rearrange( $arglist, @args );

    $self->{root}->throw('Program should be defined')  if !$program;
    $self->{root}->throw('Database should be defined') if !$database;
    $self->{root}->throw('Sequence should be defined') if !$sequence;
    $self->{root}->throw('Matrix should be defined')   if !$matrix;

    my %options = (
        p => $program,
        d => $database,
        M => $matrix,
        i => $sequence
    );

    $options{e} = $evalue if $evalue;
    $options{F} = $filter if $filter;
    $options{g} = $gapped if $gapped;
    $options{b} = $limit  if $limit;
    $options{v} = $limit  if $limit;

    my $blast_server = $self->server;

    # Check if server is available
    eval { $blast_server->config->result };
    if ($@) {
        return
            "Sorry for the inconvenience, but the BLAST server is temporarily unavailable.";
    }

    my $report = $blast_server->blastall(%options);
    if ( $report->fault ) {
        my $email = $self->{conf}->value('SITE_ADMIN_EMAIL');
        return
            "Sorry, an error occurred on our server. This is usually due to the BLAST report being too large. You can try reducing the number of alignments to show, increasing the E value and/or leaving the gapped alignment to 'True' and filtering 'On'. If you still get an error, please email $email with the sequence you were using for the BLAST and the alignment parameters.";
    }
    my ($report_text) = $report->result();
    return $report_text;
}

sub blast_report {
    my ( $self, $report_text) = @_;
    my $page_template = dicty::Template->new( -name => 'blast_report.tt' );

    my $graph     = $self->format_result_graph($report_text);
    my $html_hash = $self->format_result_html($report_text);

    my $params;
    $params->{graph}      = $graph;
    $params->{top}        = $html_hash->{top};
    $params->{table}      = $html_hash->{table};
    $params->{results}    = $html_hash->{results};
    $params->{parameters} = $html_hash->{parameters};
    $params->{statistics} = $html_hash->{statistics};
    $params->{header}     = 'BLAST Result';
    $self->template($page_template);
    return $self->template->process($params);
}

sub format_result_html {
    my ( $self, $report_text ) = @_;

    my $str;
    my $output = IO::String->new( \$str );

    my $stringio = IO::String->new($report_text);
    my $parser   = Bio::SearchIO->new(
        -fh     => $stringio,
        -format => 'blast'
    );

    my $feature_url = $self->{conf}->value('BLAST_LINK_OUT').'/';
    my $writer      = Bio::SearchIO::Writer::HTMLResultWriter->new(
        -nucleotide_url => $feature_url . '%s',
        -protein_url    => $feature_url . '%s'
    );

    $writer->title( sub { } );

    my $out = Bio::SearchIO->new( -writer => $writer, -fh => $output );
    $out->write_result( $parser->next_result, 1 );

    my $header;
    my $table;
    my $results;
    my $parameters;
    my $statistics;

    if ( $str =~
        m{(.+?)(<table.+?table>)(.+?)<hr>.+?Parameters.+?(<table.+?table>).+?Statistics(.+?)<hr}s
        ) {
        $header     = $1;
        $table      = $2;
        $results    = $3;
        $parameters = $4;
        $statistics = $5;
    }
    $header  =~ s{<br>}{}g;
    $results =~ s{</br>}{}g;
    #$table   =~ s{<br>}{}g;

    # -- search witch site id prefix belongs to
    my $map      = {};
    my %organism = $self->{conf}->obj('ORGANISMS')->hash('ORGANISM');

    foreach my $instance ( keys %organism ) {
        my $settings = $organism{$instance};
        $map->{ $settings->{'IDENTIFIER_PREFIX'} } = $settings->{'SITE_URL'};
    }

    foreach my $prefix ( keys %$map ) {
        my $url = $map->{$prefix};
        #$table   =~ s{(_ROOT_)(.+?$prefix)}{$url$2}g;
        $results =~ s{(_ROOT_)(.+?$prefix)}{$url$2}g;
    }

    my $html_hash;
    $html_hash->{top}        = $header     if $header;
    $html_hash->{table}      = $table      if $table;
    $html_hash->{results}    = $results    if $results;
    $html_hash->{parameters} = $parameters if $parameters;
    $html_hash->{statistics} = $statistics if $statistics;
    return $html_hash;
}

sub format_result_graph {
    my ( $self, $report_text ) = @_;

    my $stringio = IO::String->new($report_text);
    my $parser   = Bio::SearchIO->new(
        -fh     => $stringio,
        -format => 'blast'
    );
    my $result = $parser->next_result;
    return if !$result;

    my $panel = Bio::Graphics::Panel->new(
        -length    => $result->query_length,
        -width     => 750,
        -pad_left  => 10,
        -pad_right => 10,
    );
    my $full_length = Bio::SeqFeature::Generic->new(
        -start        => 1,
        -end          => $result->query_length,
        -display_name => ((split(/\|/, $result->query_name))[0]),
    );
    $panel->add_track(
        $full_length,
        -glyph   => 'arrow',
        -tick    => 2,
        -fgcolor => 'black',
        -double  => 1,
        -label   => 1,
    );
    my $track = $panel->add_track(
        -glyph     => 'generic',
        -label     => 1,
        -connector => 'dashed',
        -bgcolor   => 'blue',
        -height    => '5',
    );

    while ( my $hit = $result->next_hit ) {
        my $feature = Bio::SeqFeature::Generic->new(
            -score        => $hit->raw_score,
            -display_name => ((split(/\|/,$hit->name))[0]),
        );
        while ( my $hsp = $hit->next_hsp ) {
            $feature->add_sub_SeqFeature( $hsp, 'EXPAND' );
        }
        $track->add_feature($feature);
    }
    my ( $url, $map, $mapname ) = $panel->image_and_map(
        -root  => catfile(
        $self->{conf}->value('DICTY_DIR_ROOT'),$self->{conf}->value('WEB_ROOT') ),
        -url   => '/gbrowse/tmp/'.$self->{conf}->value('SITE_NAME').'/img',
        -title => '',
        -link  => '#$name'
    );
    return
          '<img src="' 
        . $url
        . '" usemap="#'
        . $mapname
        . '" border=1/>'
        . $map;
}

1;
