#!/usr/bin/env perl

use strict;
use Data::Dumper;
use Pod::Usage;
use Getopt::Long;
use CHI;
use YAML qw/LoadFile/;
use FindBin qw/$Bin/;

my $mode = 'development';
GetOptions( 'h|help' => sub { pod2usage(1); }, 'm|mode:s' => \$mode );
pod2usage('no url is given') if !$ARGV[0];
my $key = $ARGV[0];

my $yaml = "$Bin/../conf/$mode.yaml";
die "no $yaml file found\n" if !-e $yaml;

my $config = LoadFile($yaml);
die "no cache section found\n" if not defined $config->{cache}->{options};
my $opt = $config->{cache}->{options};
$opt->{debug} = 1;

my $cache = CHI->new( %$opt );

if ( $cache->is_valid($key) ) {
    print "key $key exists!!!!\n";
    $cache->remove($key);
    print "deleted cache for key $key\n";
}
else {
    print "key $key not found in cache\n";
}

=head1 NAME

B<empty_cache> - [Removed the cached response of a given url]


=head1 SYNOPSIS
 
  perl empty_cache [-m|--mode <development|staging|..>] <url>

  perl empty_cache 'http://localhost:9850/purpureum'

  perl empty_cache -m staging 'http://localhost:9850/purpureum'


=head1 REQUIRED ARGUMENTS

B<url> - Web url whose cache will be removed.


=head1 OPTIONS

B<[-h|-help]> - display this documentation.

B<[-m|--mode]> - Web application mode,  default is I<development>


=head1 CONFIGURATION AND ENVIRONMENT

=over

=item Needs to run from the root of web application

=back

=head1 DEPENDENCIES

None as long as the dependencies for web application are installed.


=head1 AUTHOR

I<Siddhartha Basu>  B<siddhartha-basu@northwestern.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) B<2010>, Siddhartha Basu C<<siddhartha-basu@northwestern.edu>>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.



