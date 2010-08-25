#!/usr/bin/env perl
use strict;
use local::lib '/home/ubuntu/dictyBase/Libs/modern-perl';
use Mojo::Server::FCGI;
use FindBin;
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../../lib";
use lib '/usr/local/dicty/lib';

BEGIN
{
$ENV{'NLS_LANG'} = 'AMERICAN';
$ENV{'WEB_HOST'} = 'testpurpureum.dictybase.org';
$ENV{'CHADO_PW'} = 'CHADORCTDWAK';
$ENV{'SITE_NAME'} = 'dictyBaseDP';
$ENV{'DICTY_LIB'} = '/usr/local/dicty/lib';
$ENV{'TNS_ADMIN'} = '/usr/local/instantclient_10_2';
$ENV{'LISTSERVE_EMAIL'} = 'siddhartha-basu@northwestern.edu';
$ENV{'CHADO_USER'} = 'DPUR_CHADO';
$ENV{'TIME_STYLE'} = 'locale';
$ENV{'SUPPORT_EMAIL'} = 'dictybase@northwestern.edu';
$ENV{'DATABASE'} = 'DICTYBASEDP';
$ENV{'PASSWORD'} = 'CGM_DDBRCTDWAK';
$ENV{'LD_LIBRARY_PATH'} = '/usr/local/instantclient_10_2';
$ENV{'ORACLE_SID'} = 'dictytst';
$ENV{'BLAST_SERVER'} = 'dicty-blast-test.bioinformatics.northwestern.edu';
$ENV{'PORT'} = '80';
$ENV{'SITE_ADMIN_EMAIL'} = 'siddhartha-basu@northwestern.edu';
$ENV{'DBHOST'} = 'gdev.bioinformatics.northwestern.edu';
$ENV{'DBUSER'} = 'DPUR_CGM_DDB';
$ENV{'DICTY_DIR_ROOT'} = '/usr/local/dicty';
$ENV{'MART_PW'} = 'MARTRCTDWAK';
$ENV{'ORACLE_ROOT'} = '/usr/local/instantclient_10_2';
$ENV{'APACHE_CONFIG_DIR'} = '/etc/apache2';
$ENV{'ORACLE_HOME'} = '/usr/local/instantclient_10_2';
$ENV{'UID'} = 'DPUR_CGM_DDB/CGM_DDBRCTDWAK@DICTYBASEDP';
$ENV{'UNIX_UTILS_PATH'} = '/bin';
$ENV{'LD_LIBRARY_PATH'} = '/usr/local/instantclient_10_2';
$ENV{'CHADO_UID'} = 'DPUR_CHADO/CHADORCTDWAK@DICTYBASEDP';
$ENV{'WEB_LIB_ROOT'} = '/usr/local/dicty/www_dictybase/db/lib';
$ENV{'SWISH_ROOT'} = '/usr/local/dicty/util/SWISH-E';
$ENV{'WEB_DB_ROOT'} = '/usr/local/dicty/www_dictybase/db';
$ENV{'TNS_ADMIN'} = '/usr/local/instantclient_10_2';
$ENV{'USER'} = 'DPUR_CGM_DDB';
$ENV{'WEB_URL_ROOT'} = 'testpurpureum.dictybase.org';
$ENV{'WEB_WWW_ROOT'} = '/usr/local/dicty/www_dictybase';
$ENV{'PATH'} = '/usr/lib/kde4/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/X11R6/bin:/usr/local/instantclient_10_2/bin/';
$ENV{'DATA_DIR'} = '/usr/local/dicty/data';
$ENV{'DBUID'} = 'DPUR_CGM_DDB/CGM_DDBRCTDWAK@DICTYBASEDP';
$ENV{MOJO_MODE} = 'production';
};

my $fcgi = Mojo::Server::FCGI->new(app_class => 'GenomeREST'); 
$fcgi->run;
