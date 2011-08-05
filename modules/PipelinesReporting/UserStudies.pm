=head1 NAME

UserStudies.pm   - Allows for users to be associated with studies so that emails can be directed and actions can be restricted

=head1 SYNOPSIS

use PipelinesReporting::UserStudies;
my $user_study = PipelinesReporting::UserStudies->new( _dbh => $database_connection);

$user_study->study_usernames(123);
$user_study->study_user_emails(123);
$user_study->is_user_in_study(123, 'johndoe');

=cut

package PipelinesReporting::UserStudies;
use Moose;
use PipelinesReporting::Schema;

has '_dbh'          => ( is => 'rw', required   => 1 );
has 'email_domain'  => ( is => 'rw', isa => 'Str',   default   => 'sanger.ac.uk' );

# given a study id, return an array of associated usernames
sub study_usernames
{
  my $self = shift;
  my $study_id = shift;
  
  my @usernames;
  my $usernames_rs = $self->_study_users_rs($study_id);
  while( my $username = $usernames_rs->next )
  {
    push(@usernames, $username->username);
  }

  return \@usernames;
}

# given a study id, return an array of email addresses for associated users 
sub study_user_emails
{
  my $self = shift;
  my $study_id = shift;
  my @email_addresses;
  
  for my $username (@{$self->study_usernames($study_id)})
  {
    push(@email_addresses, $username.'@'.$self->email_domain);
  }
  
  return \@email_addresses;
}

# is a user associated with a study?
sub is_user_in_study
{
  my ($self, $study_id, $username) = @_;
  if($self->_study_user_count($study_id, $username) == 0)
  {
    return 0;
  }
  
  return 1;  
}

# given a study_id and a username, return a the count e.g. 0 = user not part of study, everything else = user is part of study
sub _study_user_count
{
  my ($self, $study_id, $username) = @_;
  return $self->_study_user_rs($study_id, $username)->count;
}

# given a study id and a username return the result set
sub _study_user_rs
{
  my ($self, $study_id, $username) = @_;
  my $user_studies_rs = $self->_dbh->resultset('UserStudies')->search(
    { sequencescape_study_id =>  $study_id, username => $username }
  );
  
  return $user_studies_rs;
}

# given a study_id, return a result set for the distinct usernames
sub _study_users_rs
{
  my $self = shift;
  my $study_id = shift;

  my $users_rs = $self->_dbh->resultset('UserStudies')->search(
    { sequencescape_study_id =>  $study_id },
    {
      columns => [ qw/username/ ],
      distinct => 1
    }
  );
  return $users_rs;
}


1;
