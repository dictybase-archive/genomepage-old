#!/usr/bin/perl -w
use strict;
use warnings;
use lib '.';
use DictyRESTBuilder;

my $builder = DictyRESTBuilder->new(
    module_name  => 'DictyREST',
    license      => 'perl',
    dist_author  => 'Siddhartha Basu <siddhartha-basu@northwestern.edu>',
    dist_version => '1.2.0',
    requires     => {
        'Mojo'          => '',
        'Apache2::Mojo' => '', 
        'Config::Simple' => '', 
        'Try::Tiny' => '', 
        'dicty::Feature' => '', 
        'dicty::Search::Gene' => '', 
        'dicty::UI::Tabview::Config' => '', 
    	'dicty::Tests::Data' => '', 
    },
    build_requires => {
    	 'Archive::Extract' => '',
    	
		},
    add_to_cleanup => ['DictyREST-*'],
    create_readme  => 1,
);

$builder->create_build_script();


1;
