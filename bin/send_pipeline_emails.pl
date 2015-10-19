#!/usr/bin/env perl

=head1 NAME

send_pipeline_emails.pl

=head1 SYNOPSIS

send_pipeline_emails.pl -e (test|production) -p my_master_db_password

=head1 DESCRIPTION

This application will send emails to groups of users assocaitated with studies if there are new lanes out of the qc and mapping pipelines.

=head1 CONTACT

path-help@sanger.ac.uk

=head1 METHODS

=cut
package Deploy;

BEGIN { unshift(@INC, '../lib') }
BEGIN { unshift(@INC, './lib') }
use strict;
use warnings;
use Getopt::Long;
use PipelinesReporting::ConfigSettings;
use PipelinesReporting::SendPipelineEmails;

my $ENVIRONMENT;
my $DATABASE_PASSWORD;

GetOptions ('environment|e=s'    => \$ENVIRONMENT,
            'database_password|p:s' => \$DATABASE_PASSWORD
);

$ENVIRONMENT or die <<USAGE;
Usage: $0 [options]
Create a JSON file for crawl.

./send_pipeline_emails.pl -e (test|production)  [-p my_password]

 Options:
     --environment       The configuration settings you wish to use ( test | production )
     --database_password [Optional] Used instead of the password setting in the database.yml file

USAGE
;

# initialise settings
my %config_settings = %{PipelinesReporting::ConfigSettings->new(environment => $ENVIRONMENT, filename => 'config.yml')->settings()};
my %database_settings = %{PipelinesReporting::ConfigSettings->new(environment => $ENVIRONMENT, filename => 'database.yml')->settings()};
my $database_password = $DATABASE_PASSWORD;

my $qc_database_password = $database_settings{qc}{password} || $database_password;
my $qc_dbh = PipelinesReporting::Schema->connect(
  "DBI:mysql:host=$database_settings{qc}{host}:port=$database_settings{qc}{port};database=$database_settings{qc}{database}", 
  $database_settings{qc}{user}, $qc_database_password, {'RaiseError' => 1, 'PrintError'=>0});

PipelinesReporting::SendPipelineEmails->new(
  _qc_dbh => $qc_dbh,
  pipeline_databases => \%database_settings,
  email_from_address => $config_settings{email_from_address},
  email_domain => $config_settings{email_domain},
  qc_grind_url => $config_settings{qc_grind_url}
);
