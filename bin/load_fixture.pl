#!perl
use strict;
use DictyBaseConfig;
use dicty::Tests::Test_setup;
use dicty::DBH;
use dicty::Search::Reference_feature;
eval {

   my ($chromosome) = dicty::Search::Reference_feature->find( -name => 'Fake',  -type =>
   'chromosome'  );
   die "chromosome 'Fake' already exists in database\n" if $chromosome;   
   dicty::Tests::Test_setup->insert_fake_whole_chromosome();
};
if ($@) {
   warn "ERROR ENCOUNTERED: $@";
   my $dbh = new dicty::DBH;
   $dbh->rollback();
}
