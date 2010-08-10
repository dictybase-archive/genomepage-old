#!/usr/bin/env perl
use strict;
use local::lib '/home/ubuntu/dictyBase/Libs/modern-perl';
use Mojo::Server::FCGI;
use FindBin;
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../../lib";
use lib '/usr/local/dicty/lib';

BEGIN { $ENV{ORACLE_HOME} = '/usr/local/instantclient_10_2';
	$ENV{DATABASE} = 'DICTYBASE';
	$ENV{CHADO_USER} = 'DPUR_CHADO';
	$ENV{CHADO_PW} = 'DPUR_CHADO';
	$ENV{USER} = 'DPUR_DDB';
	$ENV{PASSWORD} = 'DPUR_DDB';
	$ENV{DBUSER} = 'DPUR_DDB';
	$ENV{MOJO_MODE} = 'production';
    $ENV{LD_LIBRARY_PATH} = '/usr/local/instantclient_10_2';
    $ENV{TNS_ADMIN} = '/usr/local/instantclient_10_2';
	$ENV{'ORACLE_SID'} = 'dictybase';
	$ENV{'ORACLE_HOME'} = '/usr/local/instantclient_10_2';
	$ENV{'UID'} = 'DPUR_CGM_DDB/DPUR_CGM_DDB@DICTYBASE';
	$ENV{'CHADO_UID'} = 'DPUR_CHADO/DPUR_CHADO@DICTYBASE';
};


my $fcgi = Mojo::Server::FCGI->new(app_class => 'GenomeREST'); 
$fcgi->run;
