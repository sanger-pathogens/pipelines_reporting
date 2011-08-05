=head1 NAME

SendStudyEmails.pm   - Go through every study and send out emails if nessisary

=head1 SYNOPSIS

use PipelinesReporting::SendStudyEmails;
my $study = PipelinesReporting::SendStudyEmails->new(  
  _pipeline_dbh => $pipeline_dbh,
  _qc_dbh => $qc_dbh,
  email_from_address => 'example@example.com',
  email_domain => 'example.com',
  qc_grind_url => 'http://example.com',
  database_name => 'my_test_database'
);

=cut

package PipelinesReporting::SendStudyEmails;
use Moose;
use PipelinesReporting::Schema;
use PipelinesReporting::Study;

has '_pipeline_dbh'          => ( is => 'rw',  required   => 1 );
has '_qc_dbh'                => ( is => 'rw',  required   => 1 );
has 'email_from_address'     => ( is => 'rw', isa => 'Str', required   => 1 );
has 'email_domain'           => ( is => 'rw', isa => 'Str', required   => 1 );
has 'qc_grind_url'           => ( is => 'rw', isa => 'Str', required   => 1 );
has 'database_name'          => ( is => 'rw', isa => 'Str', required   => 1 );

sub BUILD
{
  my ($self) = @_;
  my $studies_result_set = $self->_studies_result_sets;
  while( my $pipeline_study = $studies_result_set->next )
  {
    my $study = PipelinesReporting::Study->new(
      _pipeline_dbh => $self->_pipeline_dbh,
      _qc_dbh => $self->_qc_dbh,
      sequencescape_study_id => $pipeline_study->ssid,
      email_from_address => $self->email_from_address,
      email_domain => $self->email_domain,
      qc_grind_url => $self->qc_grind_url,
      database_name => $self->database_name
    );
    $study->send_emails();
  }
}

### result sets ###
sub _studies_result_sets
{
  my ($self) = @_;
  $self->_pipeline_dbh->resultset('Project')->search();
}


1;
