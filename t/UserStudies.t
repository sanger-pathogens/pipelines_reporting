#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most tests => 9;
    use DBICx::TestDatabase;
    use PipelinesReporting::Schema;
    use_ok('PipelinesReporting::UserStudies');
}

# setup test databases with seed data
my $dbh = DBICx::TestDatabase->new('PipelinesReporting::Schema');
$dbh->resultset('UserStudies')->create({ row_id => 1, study_id => 2, username => 'aaa'});
$dbh->resultset('UserStudies')->create({ row_id => 2, study_id => 2, username => 'bbb'});
$dbh->resultset('UserStudies')->create({ row_id => 3, study_id => 3, username => 'ccc'});
$dbh->resultset('UserStudies')->create({ row_id => 4, study_id => 3, username => 'aaa'});

ok my $user_study = PipelinesReporting::UserStudies->new( _dbh => $dbh),'initialise';

my @usernames_in_study = ('aaa','bbb');
is_deeply $user_study->study_usernames(2), \@usernames_in_study, 'usernames in study';

my @user_emails = ('aaa@sanger.ac.uk','bbb@sanger.ac.uk');
is_deeply $user_study->study_user_emails(2), \@user_emails, 'user emails in study';

my @usernames_different_study = ('aaa','ccc');
is_deeply $user_study->study_usernames(3), \@usernames_different_study, 'usernames in different study';

is $user_study->is_user_in_study(2, 'aaa'), 1, 'user in study';
is $user_study->is_user_in_study(3, 'aaa'), 1, 'user in study';
is $user_study->is_user_in_study(2, 'ccc'), 0, 'user not in study';
is $user_study->is_user_in_study(1, 'aaa'), 0, 'invalid study';
