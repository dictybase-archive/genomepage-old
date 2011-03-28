package MOD::SGD::StockCenter;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("stock_center");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "NUMBER",
    default_value => undef,
    is_nullable => 0,
    size => 126,
  },
  "strain_name",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 0,
    size => 200,
  },
  "strain_description",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 500,
  },
  "species",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 100,
  },
  "strain_type",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 100,
  },
  "phenotype",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 100,
  },
  "genotype",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 500,
  },
  "mutagenesis_method",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 100,
  },
  "plasmid",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 100,
  },
  "parental_strain",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 50,
  },
  "pubmedid",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 50,
  },
  "internal_db_id",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 50,
  },
  "keywords",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 200,
  },
  "obtained_from",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 100,
  },
  "obtained_on",
  { data_type => "DATE", default_value => undef, is_nullable => 1, size => 19 },
  "strain_comments",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 500,
  },
  "other_references",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 200,
  },
  "created_by",
  {
    data_type => "VARCHAR2",
    default_value => "SUBSTR(USER,1,12) ",
    is_nullable => 0,
    size => 20,
  },
  "date_created",
  { data_type => "DATE", default_value => undef, is_nullable => 1, size => 19 },
  "strain_verification",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 250,
  },
  "obtained_as",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 100,
  },
  "is_available",
  { data_type => "CHAR", default_value => undef, is_nullable => 1, size => 1 },
  "date_modified",
  { data_type => "DATE", default_value => undef, is_nullable => 1, size => 19 },
  "genotype_id",
  {
    data_type => "NUMBER",
    default_value => undef,
    is_nullable => 1,
    size => 126,
  },
  "dbxref_id",
  {
    data_type => "NUMBER",
    default_value => undef,
    is_nullable => 1,
    size => 126,
  },
  "systematic_name",
  {
    data_type => "VARCHAR2",
    default_value => undef,
    is_nullable => 1,
    size => 200,
  },
  "mutant_type",
  { data_type => "NUMBER", default_value => undef, is_nullable => 1, size => 10 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-07 10:55:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2O8GVv7Qj/KJk9sfDPJBEQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
