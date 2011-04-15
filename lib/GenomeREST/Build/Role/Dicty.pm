package GenomeREST::Build::Role::Dicty;

# Other modules:
use Moose::Role;
use Bio::SeqIO;
use MooseX::Params::Validate;
use Carp::Always;
use namespace::autoclean;

# Module implementation
#
has 'schema' => (
    is      => 'ro',
    isa     => 'Bio::Chado::Schema',
    lazy    => 1,
    default => sub {
        my ($self) = shift;
        return $self->module_builder->_handler->schema;
    }
);

has 'fake_chr_feature_id' => (
    is      => 'ro',
    isa     => 'Int',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->schema->resultset('Sequence::Feature')
            ->find( { name => $self->seqobj->display_id } )->feature_id;
    }
);

has 'dicty_db_namespace' => (
    is      => 'ro',
    isa     => 'Maybe[Str]',
    default => sub {
        my ($self) = @_;
        $self->has_db_namespace
            ? return 'DB:' . $self->db_namespace
            : return 'DB:dictyBase';
    },
    lazy => 1
);

has 'db_namespace' => (
    is        => 'rw',
    isa       => 'Maybe[Str]',
    predicate => 'has_db_namespace',
);

has 'feature_source' => ( is => 'rw', isa => 'Str', default => 'GFF_source' );

has '_organism_rows' => (
    is      => 'rw',
    isa     => 'HashRef[Bio::Chado::Schema::Organism::Organism]',
    traits  => [qw/Hash/],
    handles => {
        'get_organism_row'   => 'get',
        'add_organism_row'   => 'set',
        'exist_organism_row' => 'defined',
        'all_organism_rows'  => 'values'
    },
    builder => '_build_organism_rows',
    lazy    => 1
);

sub _build_organism_rows {
    my ($self) = @_;
    my $rs
        = $self->schema->resultset('Organism::Organism')
        ->search( {},
        { select => [qw/genus species common_name organism_id/] } );

    my $hash = {};
    while ( my $row = $rs->next ) {
        $hash->{ $row->genus . $row->species } = $row;
    }
    return $hash;
}

sub find_or_create_organism_id {
    my ( $self, $genus, $species ) = validated_list(
        \@_,
        genus   => { isa => 'Str' },
        species => { isa => 'Str' }
    );
    my $str = $genus . $species;
    if ( $self->exist_organism_row($str) ) {
        return $self->get_organism_row($str)->organism_id;
    }

    my $row = $self->schema->txn_do(
        sub {
            return $self->schema->resultset('Organism::Organism')->create(
                {   genus   => $genus,
                    species => $species
                }
            );
        }
    );

    $self->add_organism_row( $str, $row );
    return $row->organism_id;
}

sub organism_id_from_seqobj {
    my ($self) = @_;
    my $seqobj = $self->seqobj;
    my $org_id = $self->find_or_create_organism_id(
        genus   => $seqobj->species->genus,
        species => $seqobj->species->species
    );

}

has 'id_prefix' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'DDB',
    lazy    => 1
);

has 'resultset_name' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'Sequence::Feature',
    lazy    => 1
);

has 'seqobj' => (
    is      => 'ro',
    isa     => 'Bio::Seq',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $seqio = Bio::SeqIO->new(
            -file   => $self->module_builder->feature_fixture,
            -format => 'genbank'
        );
        return $seqio->next_seq;
    }
);

sub generate_uniquename {
    my ( $self, $id_prefix, $rs_name ) = @_;
    $id_prefix ||= $self->id_prefix;
    $rs_name   ||= $self->resultset_name;

    my $schema    = $self->schema;
    my $rs_source = $schema->resultset($rs_name)->result_source;
    my ($column)  = $rs_source->primary_columns;
    my $seq_name  = $rs_source->column_info($column)->{sequence};

    $seq_name =~ s{\_seq$}{}i;
    $seq_name = 'SQ_' . uc $seq_name;

    my $nextval = $schema->storage->dbh->selectcol_arrayref(
        "SELECT $seq_name.NEXTVAL FROM DUAL")->[0];

    return $id_prefix . sprintf( "%07d", $nextval );
}

sub load_chromosome {
    my ($self) = @_;
    my $cvterm_id = $self->find_or_create_cvterm_id(
        cvterm => 'chromosome',
        cv     => 'sequence'
    );
    my $uniq_name = $self->generate_uniquename;

    my $schema   = $self->schema;
    my $feat_row = $schema->txn_do(
        sub {
            return $schema->resultset('Sequence::Feature')->create(
                {   uniquename  => $uniq_name,
                    name        => $self->seqobj->display_id,
                    residues    => $self->seqobj->seq,
                    seqlen      => $self->seqobj->length,
                    organism_id => $self->organism_id_from_seqobj,
                    type_id     => $cvterm_id,
                    dbxref      => {
                        accession => $uniq_name,
                        db_id     => $self->find_or_create_db_id(
                            $self->dicty_db_namespace
                        )
                    },
                    feature_dbxrefs => [
                        {   dbxref => {
                                accession => $self->feature_source,
                                db_id     => $self->find_or_create_db_id(
                                    $self->feature_source
                                )
                            }
                        }
                    ]
                }
            );
        }
    );
}

sub load_contig {
    my ($self) = @_;
    my $create_array;
    my @contigs = grep { $_->primary_tag() eq 'contig' }
        $self->seqobj->get_SeqFeatures();

    for my $feat (@contigs) {
        my $uniquename = $self->generate_uniquename;
        my $hash       = {
            name        => 'Fake_contig_' . $uniquename,
            uniquename  => $uniquename,
            organism_id => $self->organism_id_from_seqobj,
            type_id     => $self->find_or_create_cvterm_id(
                cv     => 'sequence',
                cvterm => 'contig'
            ),
            dbxref => {
                accession => $uniquename,
                db_id =>
                    $self->find_or_create_db_id( $self->dicty_db_namespace )
            },
            featureloc_features => [
                {   fmin          => $feat->start - 1,
                    fmax          => $feat->end,
                    srcfeature_id => $self->fake_chr_feature_id
                }
            ],
        };

        if ( $feat->has_tag('ID') ) {
            my $name = [ $feat->get_tag_values('ID') ]->[0];
            $hash->{feature_dbxrefs} = [
                {   dbxref => {
                        accession => $name,
                        db_id     => $self->find_or_create_db_id(
                            $self->feature_source
                        )
                    }
                }
            ];
            $hash->{name} = $name;
        }
        push @$create_array, $hash;
    }

    ## -- persist the contigs
    $self->_create_bulk_features($create_array);
}

sub load_gap {
    my ($self) = @_;

    my $create_array;
    my @gaps = grep { $_->primary_tag() eq 'gap' }
        $self->seqobj->get_SeqFeatures();

    for my $i ( 0 .. $#gaps ) {
        my $feat       = $gaps[$i];
        my $uniquename = $self->generate_uniquename;
        my $hash       = {
            name        => 'Fake_gap_' . $uniquename,
            uniquename  => $uniquename,
            organism_id => $self->organism_id_from_seqobj,
            type_id     => $self->find_or_create_cvterm_id(
                cv     => 'sequence',
                cvterm => 'gap'
            ),
            dbxref => {
                accession => $uniquename,
                db_id =>
                    $self->find_or_create_db_id( $self->dicty_db_namespace )
            },
            featureloc_features => [
                {   fmin          => $feat->start - 1,
                    fmax          => $feat->end,
                    srcfeature_id => $self->fake_chr_feature_id
                }
            ],
            featureprops => [
                {   type_id => $self->find_or_create_cvterm_id(
                        cvterm => 'gap type',
                        cv     => 'autocreated'
                    ),
                    value => 'clone_gap',
                    rank  => $i
                }
            ]
        };

        ## -- dump the data structure to check the arrayref
        push @$create_array, $hash;
    }

    ## -- persist the gaps
    $self->_create_bulk_features($create_array);
}

sub load_transcript {
    my ($self) = @_;
    my @transcripts = grep { $_->primary_tag() =~ m{RNA|pseudogene} }
        $self->seqobj->get_SeqFeatures();

    for my $i ( 0 .. $#transcripts ) {
        my $feat        = $transcripts[$i];
        my $uniquename  = $self->generate_uniquename;
        my $feat_source = [ $feat->get_tag_values('source') ]->[0];
        if ( $self->dicty_db_namespace ne 'dictyBase' ) {
            $feat_source =~ s/dictyBase/$self->dicty_db_namespace/g;
        }

        my $hash = {
            name        => 'Fake_transcript_' . $uniquename,
            uniquename  => $uniquename,
            organism_id => $self->organism_id_from_seqobj,
            type_id     => $self->find_or_create_cvterm_id(
                cv     => 'sequence',
                cvterm => $feat->primary_tag
            ),
            dbxref => {
                accession => $uniquename,
                db_id =>
                    $self->find_or_create_db_id( $self->dicty_db_namespace )
            },
            featureloc_features => [
                {   fmin          => $feat->start - 1,
                    fmax          => $feat->end,
                    strand        => $feat->strand,
                    srcfeature_id => $self->fake_chr_feature_id
                }
            ],
            feature_dbxrefs => [
                {   dbxref => {
                        accession => $feat_source,
                        db_id     => $self->find_or_create_db_id(
                            $self->feature_source
                        )
                    }
                }
            ]
        };

        ## -- few more feature dbxrefs
        $self->_add_transcript_xrefs( $feat, $hash );

        ## -- feature properties
        $self->_add_transcript_props( $feat, $hash );

        ## -- now create the transcript feature
        my $schema     = $self->schema;
        my $trans_feat = $schema->txn_do(
            sub {
                return $schema->resultset('Sequence::Feature')->create($hash);
            }
        );
        $self->_load_gene( $trans_feat, $feat );
        $self->_load_exons( $trans_feat, $feat );
    }
}

sub _add_transcript_xrefs {
    my ( $self, $feat, $hash ) = @_;
    if ( $feat->has_tag('ID') ) {
        my $name = [ $feat->get_tag_values('ID') ]->[0];
        push @{ $hash->{feature_dbxrefs} },
            {
            dbxref => {
                accession => $name,
                db_id => $self->find_or_create_db_id( $self->feature_source )
            }
            };
        $hash->{name} = $name;
    }

    if ( $feat->has_tag('db_xref') ) {
        for my $value ( $feat->get_tag_values('db_xref') ) {
            my ( $db, $id ) = split /:/, $value;
            push @{ $hash->{feature_dbxrefs} },
                {
                dbxref => {
                    accession => $id,
                    db_id     => $self->find_or_create_db_id($db)
                }
                };
        }
    }

}

sub _add_transcript_props {
    my ( $self, $feat, $hash ) = @_;
    my $rank              = 0;
    my $translation_start = 1;
    if ( $feat->has_tag('codon_start') ) {
        $translation_start = [ $feat->get_tag_values('codon_start') ]->[0];

        push @{ $hash->{featureprops} },
            {
            type_id => $self->find_or_create_cvterm_id(
                cvterm => 'translation_start',
                cv     => 'autocreated'
            ),
            value => $translation_start
            };

        push @{ $hash->{featureprops} },
            {
            type_id => $self->find_or_create_cvterm_id(
                cvterm => 'qualifier',
                cv     => 'autocreated'
            ),
            value => "Partial, 5' missing",
            rank  => $rank++
            }
            if $translation_start > 1;
    }

    my $protein_seq
        = $feat->seq->translate( undef, undef, $translation_start - 1 )->seq;

    push @{ $hash->{featureprops} },
        {
        type_id => $self->find_or_create_cvterm_id(
            cvterm => 'qualifier',
            cv     => 'autocreated'
        ),
        value => "Partial, 5' missing",
        rank  => $rank++
        }
        if $protein_seq !~ /^m/i;

    push @{ $hash->{featureprops} },
        {
        type_id => $self->find_or_create_cvterm_id(
            cvterm => 'qualifier',
            cv     => 'autocreated'
        ),
        value => "Partial, 3' missing",
        rank  => $rank++
        }
        if $protein_seq !~ /\*$/;

    push @{ $hash->{featureprops} },
        {
        type_id => $self->find_or_create_cvterm_id(
            cvterm => 'DNA coding sequence',
            cv     => 'autocreated'
        ),
        value => $feat->seq->seq,
        };
}

sub _load_exons {
    my ( $self, $chado_feat, $bio_feat ) = @_;
    my $loc = $bio_feat->location;
    my @subloc
        = $loc->can('sub_Location')
        ? $loc->sub_Location
        : ($loc);

    my $create_array;
    for my $subfeat (@subloc) {
        my $uniquename = $self->generate_uniquename;
        my $hash       = {
            name        => 'Fake_exon_' . $uniquename,
            uniquename  => $uniquename,
            organism_id => $self->organism_id_from_seqobj,
            type_id     => $self->find_or_create_cvterm_id(
                cv     => 'sequence',
                cvterm => 'exon'
            ),
            dbxref => {
                accession => $uniquename,
                db_id =>
                    $self->find_or_create_db_id( $self->dicty_db_namespace )
            },
            featureloc_features => [
                {   fmin          => $subfeat->start - 1,
                    fmax          => $subfeat->end,
                    strand        => $subfeat->strand,
                    srcfeature_id => $self->fake_chr_feature_id
                }
            ],
            feature_dbxrefs => [
                {   dbxref => {
                        accession => $self->feature_source,
                        db_id     => $self->find_or_create_db_id(
                            $self->feature_source
                        )
                    }
                }
            ],
            feature_relationship_subjects => [
                {   object_id => $chado_feat->feature_id,
                    type_id   => $self->find_or_create_cvterm_id(
                        cv     => 'relationship',
                        cvterm => 'part_of'
                    )
                }
            ]
        };
        push @$create_array, $hash;
    }
    $self->_create_bulk_features($create_array);
}

sub _load_gene {
    my ( $self, $chado_feat, $bio_feat ) = @_;

    my $gene_name  = [ $bio_feat->get_tag_values('gene_name') ]->[0];
    my $uniquename = $self->generate_uniquename('DDB_G');

    my $create_hash = {
        name        => $gene_name,
        uniquename  => $uniquename,
        organism_id => $self->organism_id_from_seqobj,
        type_id     => $self->find_or_create_cvterm_id(
            cv     => 'sequence',
            cvterm => 'gene'
        ),
        dbxref => {
            accession => $uniquename,
            db_id => $self->find_or_create_db_id( $self->dicty_db_namespace )
        },
        featureloc_features => [
            {   fmin          => $bio_feat->start - 1,
                fmax          => $bio_feat->end,
                strand        => $bio_feat->strand,
                srcfeature_id => $self->fake_chr_feature_id
            }
        ],
        feature_relationship_objects => [
            {   subject_id => $chado_feat->feature_id,
                type_id    => $self->find_or_create_cvterm_id(
                    cv     => 'relationship',
                    cvterm => 'part_of'
                )
            }
        ]
    };

    my $gene_feat = $self->schema->txn_do(
        sub {
            return $self->schema->resultset('Sequence::Feature')
                ->create($create_hash);
        }
    );

    ## -- gene product
    my $legacy_schema = $self->legacy_schema;
    if ( $bio_feat->has_tag('gene_product') ) {
        for my $prod ( $bio_feat->get_tag_values('gene_product') ) {
            my $row = $legacy_schema->txn_do(
                sub {
                    return $legacy_schema->resultset('GeneProduct')
                        ->create( { gene_product => $prod } );
                }
            );
            $legacy_schema->txn_do(
                sub {
                    $legacy_schema->resultset('LocusGp')->create(
                        {   locus_no        => $gene_feat->feature_id,
                            gene_product_no => $row->gene_product_no
                        }
                    );
                }
            );

        }
    }
}

sub _create_bulk_features {
    my ( $self, $array ) = @_;
    $self->schema->txn_do(
        sub {
            $self->schema->resultset('Sequence::Feature')->populate($array);
        }
    );
}

sub create_homology_group {
    my $self   = shift;
    my $schema = $self->schema;

    my $group_organism_id = $self->find_or_create_organism_id(
        genus   => 'cellular',
        species => 'organisms'
    );

    my $cvterm_rs =
        $schema->resultset('Cv::Cvterm')
        ->search( { 'cv.name' => 'sequence' }, { join => 'cv' } );

    my $group_cvterm = $cvterm_rs->find( { 'name' => 'gene_group' } );
    die '"gene_group" cvterm not found, cannot proceed' if !$group_cvterm;

    my $member_of_cvterm = $cvterm_rs->find( { 'name' => 'member_of' } );
    die '"member_of" cvterm not found, cannot proceed' if !$group_cvterm;

    my $analysis_name = 'test_orthology';
    my $program       = 'Inparanoid';
    my $version       = '7.0';

    my $analysis = $schema->resultset('Companalysis::Analysis')->create(
        {   name           => $analysis_name,
            program        => $program,
            programversion => $version,
        }
    );
    my $grouping_feature = $schema->resultset('Sequence::Feature')->create(
        {   organism_id => $group_organism_id,
            name        => 'test_orthology',
            type_id     => $group_cvterm->cvterm_id,
            is_analysis => 1,
            uniquename  => '_' 
                . $program . '_' 
                . $version . '_'
                . $analysis_name,
            analysisfeatures => [ { analysis_id => $analysis->id } ]
        }
    );

    my @members;
    push @members,
        $schema->resultset('Sequence::Feature')
        ->search( { 'me.name' => 'test_CURATED', 'type.name' => 'gene' },
        { join => 'type' } )->first;
    push @members,
        $schema->resultset('Sequence::Feature')
        ->search( { 'me.name' => 'test_cbpD2', 'type.name' => 'gene' },
        { join => 'type' } )->first;

    foreach my $member (@members) {
        $schema->resultset('Sequence::FeatureRelationship')
            ->find_or_create(
            {   subject_id => $member->feature_id,
                object_id  => $grouping_feature->feature_id,
                type_id    => $member_of_cvterm->cvterm_id
            }
            );
    }
}

1;    # Magic true value required at end of module

