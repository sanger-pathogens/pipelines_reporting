#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 14;
    use DBICx::TestDatabase;
    use PipelinesReporting::Schema;
    use_ok('PipelinesReporting::Study');
}

# setup test databases with seed data
my $dbh = DBICx::TestDatabase->new('PipelinesReporting::Schema');
$dbh->resultset('UserStudies')->create({ row_id => 1, sequencescape_study_id => 2, username => 'aaa'});
$dbh->resultset('UserStudies')->create({ row_id => 2, sequencescape_study_id => 2, username => 'bbb'});

$dbh->resultset('Project'    )->create({ row_id => 1, project_id => 1, ssid => 2 });
$dbh->resultset('Project'    )->create({ row_id => 2, project_id => 2, ssid => 10 });

$dbh->resultset('Sample'     )->create({ row_id => 1, sample_id  => 3, project_id => 1 });

$dbh->resultset('Library'    )->create({ row_id => 1, library_id => 4, sample_id  => 3 });
$dbh->resultset('Library'    )->create({ row_id => 2, library_id => 7, sample_id  => 3 });

$dbh->resultset('Lane'       )->create({ row_id => 1, lane_id => 5, library_id => 4, processed => 7 });
$dbh->resultset('Lane'       )->create({ row_id => 2, lane_id => 6, library_id => 4, processed => 3 });
$dbh->resultset('Lane'       )->create({ row_id => 3, lane_id => 8, library_id => 7, processed => 3 });


# valid study
ok my $study = PipelinesReporting::Study->new(  
  _pipeline_dbh => $dbh,
  _qc_dbh => $dbh,
  sequencescape_study_id => 2
), 'initialise';

my @user_emails = ('aaa@sanger.ac.uk','bbb@sanger.ac.uk');
is_deeply $study->user_emails, \@user_emails, 'user emails';

my @qc_lane_ids  = (6,8);
is_deeply $study->qc_lane_ids, \@qc_lane_ids, 'qc lane ids';

my @mapped_lane_ids = (5);
is_deeply $study->mapped_lane_ids, \@mapped_lane_ids, 'mapped lane ids';


## error cases
my @empty_array = ();
ok $study = PipelinesReporting::Study->new(  
  _pipeline_dbh => $dbh,
  _qc_dbh => $dbh,
  sequencescape_study_id => 99999
), 'initialise invalid study';
is_deeply $study->user_emails, \@empty_array , 'user emails invalid study';
is_deeply $study->qc_lane_ids, \@empty_array, 'qc lane ids undef if invalid study';
is_deeply $study->mapped_lane_ids, \@empty_array, 'mapped lane ids undef if invalid study';

ok $study = PipelinesReporting::Study->new(  
  _pipeline_dbh => $dbh,
  _qc_dbh => $dbh,
  sequencescape_study_id => 10
), 'initialise study with no users';
is_deeply $study->user_emails, \@empty_array, 'user emails empty';
is_deeply $study->qc_lane_ids, \@empty_array, 'qc lane ids undef if no users';
is_deeply $study->mapped_lane_ids, \@empty_array, 'mapped lane ids undef if no users';

# add a user for the study and lane ids should be empty
$dbh->resultset('UserStudies')->create({ row_id => 3, sequencescape_study_id => 10, username => 'aaa'});
ok $study = PipelinesReporting::Study->new(  
  _pipeline_dbh => $dbh,
  _qc_dbh => $dbh,
  sequencescape_study_id => 10
), 'initialise study with no users';
@user_emails = ('aaa@sanger.ac.uk');
is_deeply $study->user_emails, \@user_emails, 'user emails has 1 user';
is_deeply $study->qc_lane_ids, \@empty_array, 'qc lane ids empty if no lanes';
is_deeply $study->mapped_lane_ids, \@empty_array, 'mapped lane ids empty if no lanes';