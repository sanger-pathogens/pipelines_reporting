=head1 NAME

Study.pm   - Represents a study.

Get all the lanes in the study that have passed qc and been mapped, 
send emails to the list of assosiated users (if they havent been sent before).

=head1 SYNOPSIS

use PipelinesReporting::Study;
my $study = PipelinesReporting::Study->new(  
  _pipeline_dbh => $pipeline_dbh,
  _qc_dbh => $qc_dbh,
  sequencescape_study_id => 123
  );
$study->send_emails();

=cut

package PipelinesReporting::Study;
use Moose;
use PipelinesReporting::Schema;
use PipelinesReporting::UserStudies;
use PipelinesReporting::LaneEmail;

has '_pipeline_dbh'          => ( is => 'rw',                           required   => 1 );
has '_qc_dbh'                => ( is => 'rw',                           required   => 1 );
has 'sequencescape_study_id' => ( is => 'rw', isa => 'Int',             required   => 1 );

has 'user_emails'     => ( is => 'rw', isa => 'Maybe[ArrayRef]', lazy_build => 1 );
has 'qc_lane_ids'     => ( is => 'rw', isa => 'Maybe[ArrayRef]', lazy_build => 1 );
has 'mapped_lane_ids' => ( is => 'rw', isa => 'Maybe[ArrayRef]', lazy_build => 1 );

my $QC_PROCESSED_FLAG     = 3;
my $MAPPED_PROCESSED_FLAG = 7;

### public methods ###
sub send_emails
{
  my $self = shift;
  return unless(defined $self->user_emails);
  
  $self->_send_qc_emails if(@{$self->qc_lane_ids} > 0);
  $self->_send_mapped_emails if(@{$self->mapped_lane_ids} > 0);
}

### END public methods ###


### builders ###
sub _build_user_emails
{
  my $self = shift;
  my $user_study = PipelinesReporting::UserStudies->new( _dbh => $self->_qc_dbh);
  return $user_study->study_user_emails($self->sequencescape_study_id);
}

sub _build_qc_lane_ids
{
  my $self = shift;
  return undef unless(defined $self->user_emails);
  my @lane_ids_needing_emails ;

  for my $lane_id (@{$self->_lane_ids_filtered_by_processed_flag($QC_PROCESSED_FLAG)})
  {
    my $lane_email = PipelinesReporting::LaneEmails->new(_dbh => $self->_qc_dbh,lane_id => $lane_id);
    push(@lane_ids_needing_emails, $lane_id) unless( $lane_email->is_qc_email_sent() );
  }
  
  return \@lane_ids_needing_emails;
}

sub _build_mapped_lane_ids
{
  my $self = shift;
  return undef unless(defined $self->user_emails);
  my @lane_ids_needing_emails ;

  for my $lane_id (@{$self->_lane_ids_filtered_by_processed_flag($MAPPED_PROCESSED_FLAG)})
  {
    my $lane_email = PipelinesReporting::LaneEmails->new(_dbh => $self->_qc_dbh,lane_id => $lane_id);
    push(@lane_ids_needing_emails, $lane_id) unless( $lane_email->is_mapping_email_sent() );
  }

  return \@lane_ids_needing_emails;
}

### END builders ###

### Result sets ###
sub _samples_result_set
{
  my ($self) = @_;
  # a study is called a project in VRTrack?
  $self->_pipeline_dbh->resultset('Project')->search({ ssid => $self->sequencescape_study_id  })->search_related('samples');
}

sub _libraries_result_set
{
  my ($self) = @_;
  $self->_samples_result_set()->search_related('libraries');
}

sub _lanes_result_set
{
  my ($self, $processed) = @_;
  $self->_libraries_result_set()->search_related('lanes', { processed => $processed });
}

sub _lanes_filtered_by_processed_flag_result_set
{
  my ($self, $processed) = @_;
  $self->_lanes_result_set($processed);
}

### END Result sets ###

sub _lane_ids_filtered_by_processed_flag
{
  my ($self, $processed) = @_;
  my @lane_ids;
  
  my $lanes_result_set = $self->_lanes_filtered_by_processed_flag_result_set($processed);

  while( my $lane = $lanes_result_set->next)
  {
    push(@lane_ids, $lane->lane_id);
  }
  
  return \@lane_ids;
}

sub _send_qc_emails
{
  my ($self) = @_;
  #TODO
}

sub _send_mapped_emails
{
  my ($self) = @_;
  #TODO
}

1;
