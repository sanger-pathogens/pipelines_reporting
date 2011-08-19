#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 20;
    use DBICx::TestDatabase;
    use PipelinesReporting::Schema;
    use_ok('PipelinesReporting::LaneEmail');
}

# setup test databases with seed data
my $dbh = DBICx::TestDatabase->new('PipelinesReporting::Schema');
$dbh->resultset('LaneEmails')->create({ name => 1, qc_email_sent => 0, mapping_email_sent => 0});
$dbh->resultset('LaneEmails')->create({ name => 2, qc_email_sent => 1, mapping_email_sent => 0});
$dbh->resultset('LaneEmails')->create({ name => 3, qc_email_sent => 1, mapping_email_sent => 1});

# correctly retrieve email sent for each lane
ok my $lane_email_1 = PipelinesReporting::LaneEmails->new(_dbh => $dbh,name => 1), 'initialize 00';
is $lane_email_1->is_qc_email_sent(), 0, 'qc email sent false';
is $lane_email_1->is_mapping_email_sent(), 0, 'mapping email sent false';

ok my $lane_email_2 = PipelinesReporting::LaneEmails->new(_dbh => $dbh,name => 2), 'initialize 10';
is $lane_email_2->is_qc_email_sent(), 1, 'qc email sent true';
is $lane_email_2->is_mapping_email_sent(), 0, 'mapping email sent false';

ok my $lane_email_3 = PipelinesReporting::LaneEmails->new(_dbh => $dbh,name => 3), 'initialize 11';
is $lane_email_3->is_qc_email_sent(), 1, 'qc email sent true';
is $lane_email_3->is_mapping_email_sent(), 1, 'mapping email sent true';

# previously unseen lane
ok my $lane_email_unseen = PipelinesReporting::LaneEmails->new(_dbh => $dbh,name => 9), 'initialize unseen lane';
is $lane_email_unseen->is_qc_email_sent(), 0, 'qc email sent false';
is $lane_email_unseen->is_mapping_email_sent(), 0, 'mapping email sent false';
ok $lane_email_unseen->qc_email_sent(), 'send qc email';
ok $lane_email_unseen->mapping_email_sent(), 'send mapping email';
is $lane_email_unseen->is_qc_email_sent(), 1, 'qc email sent false';
is $lane_email_unseen->is_mapping_email_sent(), 1, 'mapping email sent false';

# look up unseen lane again (because it should now be stored in database
ok $lane_email_unseen = PipelinesReporting::LaneEmails->new(_dbh => $dbh,name => 9), 'initialize unseen lane';
is $lane_email_unseen->is_qc_email_sent(), 1, 'qc email sent false';
is $lane_email_unseen->is_mapping_email_sent(), 1, 'mapping email sent false';
