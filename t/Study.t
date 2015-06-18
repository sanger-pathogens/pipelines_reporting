#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './lib') }
BEGIN {
    use Test::Most tests => 28;
    use DBICx::TestDatabase;
    use PipelinesReporting::Schema;
    use_ok('PipelinesReporting::Study');
}

# setup test databases with seed data
my $dbh = DBICx::TestDatabase->new('PipelinesReporting::Schema');
$dbh->resultset('UserStudies')->create({  sequencescape_study_id => 2, username => 'aaa'});
$dbh->resultset('UserStudies')->create({  sequencescape_study_id => 2, username => 'bbb'});

$dbh->resultset('Project'    )->create({ row_id => 1, project_id => 1, ssid => 2 , name => 'Study Name'});
$dbh->resultset('Project'    )->create({ row_id => 2, project_id => 2, ssid => 10, name => 'Study Name'});

$dbh->resultset('Sample'     )->create({ row_id => 1, sample_id  => 3, project_id => 1 });

$dbh->resultset('Library'    )->create({ row_id => 1, library_id => 4, sample_id  => 3 });
$dbh->resultset('Library'    )->create({ row_id => 2, library_id => 7, sample_id  => 3 });

$dbh->resultset('Lane'       )->create({ row_id => 1, name => "abc_1", lane_id => 5, library_id => 4, processed => 15 });
$dbh->resultset('Lane'       )->create({ row_id => 2, name => "abc_2", lane_id => 6, library_id => 4, processed => 11 });
$dbh->resultset('Lane'       )->create({ row_id => 3, name => "abc_3", lane_id => 8, library_id => 7, processed => 11 });


# valid study
ok my $study = PipelinesReporting::Study->new(  
  _pipeline_dbh => $dbh,
  _qc_dbh => $dbh,
  sequencescape_study_id => 2,
  qc_grind_url => 'http://example.com',
  database_name => 'test',
  email_from_address => 'example@example.com',
  email_domain => 'example.com'
), 'initialise';


my @user_emails = ('aaa@example.com','bbb@example.com');
is_deeply $study->user_emails, \@user_emails, 'user emails';

my %qc_names  = (abc_2 => 6,
                 abc_3 => 8);
is_deeply $study->qc_names, \%qc_names, 'qc lane ids';

my %mapped_names = (abc_1 => 5);
is_deeply $study->mapped_names, \%mapped_names, 'mapped lane ids';

ok my $lane_email_abc_1 = PipelinesReporting::LaneEmails->new(_dbh => $dbh,name => "abc_1"), 'initialize lane_email 1 ';
ok my $lane_email_abc_2 = PipelinesReporting::LaneEmails->new(_dbh => $dbh,name => "abc_2"), 'initialize lane_email 2';
ok my $lane_email_abc_3 = PipelinesReporting::LaneEmails->new(_dbh => $dbh,name => "abc_3"), 'initialize lane_email 3';

is $lane_email_abc_1->is_qc_email_sent(), 0, 'qc email lane 1 sent false';
is $lane_email_abc_2->is_qc_email_sent(), 1, 'qc email lane 2 sent true';
is $lane_email_abc_3->is_qc_email_sent(), 1, 'qc email lane 3 sent true';

is $lane_email_abc_1->is_mapping_email_sent(), 1, 'mapped email lane 1 sent true';
is $lane_email_abc_2->is_mapping_email_sent(), 0, 'mapped email lane 2 sent false';
is $lane_email_abc_3->is_mapping_email_sent(), 0, 'mapped email lane 3 sent false';

# check body of constructed email
my $expected_email_body = 'The following lanes have finished QC in Study Study Name.

abc_2	http://example.com?mode=0&lane_id=6&db=test
abc_3	http://example.com?mode=0&lane_id=8&db=test

';

is $study->_construct_email_body_for_lane_action('QC', $study->qc_names), $expected_email_body, 'QC email body';


$expected_email_body = 'The following lanes have finished Mapping in Study Study Name.

abc_1	http://example.com?mode=0&lane_id=5&db=test

';
is $study->_construct_email_body_for_lane_action('Mapping', $study->mapped_names), $expected_email_body, 'Mapping email body';



## error cases
my @empty_array = ();
ok $study = PipelinesReporting::Study->new(  
  _pipeline_dbh => $dbh,
  _qc_dbh => $dbh,
  sequencescape_study_id => 99999,
  qc_grind_url => 'http://example.com',
  database_name => 'test',
  email_from_address => 'example@example.com',
  email_domain => 'example.com'
), 'initialise invalid study';
is_deeply $study->user_emails, \@empty_array , 'user emails invalid study';
is_deeply $study->qc_names, undef, 'qc lane ids undef if invalid study';
is_deeply $study->mapped_names, undef, 'mapped lane ids undef if invalid study';

ok $study = PipelinesReporting::Study->new(  
  _pipeline_dbh => $dbh,
  _qc_dbh => $dbh,
  sequencescape_study_id => 10,
  qc_grind_url => 'http://example.com',
  database_name => 'test',
  email_from_address => 'example@example.com',
  email_domain => 'example.com'
), 'initialise study with no users';
is_deeply $study->user_emails, \@empty_array, 'user emails empty';
is_deeply $study->qc_names, undef, 'qc lane ids undef if no users';
is_deeply $study->mapped_names, undef, 'mapped lane ids undef if no users';

# add a user for the study and lane ids should be empty
$dbh->resultset('UserStudies')->create({ sequencescape_study_id => 10, username => 'aaa'});
ok $study = PipelinesReporting::Study->new(  
  _pipeline_dbh => $dbh,
  _qc_dbh => $dbh,
  sequencescape_study_id => 10,
  qc_grind_url => 'http://example.com',
  database_name => 'test',
  email_from_address => 'example@example.com',
  email_domain => 'example.com'
), 'initialise study with no users';
@user_emails = ('aaa@example.com');
my %empty_hash =();
is_deeply $study->user_emails, \@user_emails, 'user emails has 1 user';
is_deeply $study->qc_names, \%empty_hash, 'qc lane ids empty if no lanes';
is_deeply $study->mapped_names, \%empty_hash, 'mapped lane ids empty if no lanes';
