=head1 NAME

Study.pm   - Represents a study.

Get all the lanes in the study that have passed qc and been mapped, 
send emails to the list of assosiated users (if they havent been sent before).

=head1 SYNOPSIS

use PipelinesReporting::Study;
my $study = PipelinesReporting::Study->new(  
  _pipeline_dbh => $pipeline_dbh,
  _qc_dbh => $qc_dbh,
  sequencescape_study_id => 123,
  email_from_address => 'example@example.com',
  email_domain => 'example.com',
  qc_grind_url => 'http://example.com',
  database_name => 'my_test_database'
  );
$study->send_emails();

=cut

package PipelinesReporting::Study;
use Moose;
use PipelinesReporting::Schema;
use PipelinesReporting::UserStudies;
use PipelinesReporting::LaneEmail;

has '_pipeline_dbh'          => ( is => 'rw',               required   => 1 );
has '_qc_dbh'                => ( is => 'rw',               required   => 1 );
has 'sequencescape_study_id' => ( is => 'rw', isa => 'Int', required   => 1 );
has 'email_from_address'     => ( is => 'rw', isa => 'Str', required   => 1 );
has 'email_domain'           => ( is => 'rw', isa => 'Str', required   => 1 );
has 'qc_grind_url'           => ( is => 'rw', isa => 'Str', required   => 1 );
has 'database_name'          => ( is => 'rw', isa => 'Str', required   => 1 );

has 'user_emails'     => ( is => 'rw', isa => 'Maybe[ArrayRef]', lazy_build => 1 );
has 'qc_lane_ids'     => ( is => 'rw', isa => 'Maybe[ArrayRef]', lazy_build => 1 );
has 'mapped_lane_ids' => ( is => 'rw', isa => 'Maybe[ArrayRef]', lazy_build => 1 );

my $QC_PROCESSED_FLAG     = 3;
my $MAPPED_PROCESSED_FLAG = 7;

### public methods ###
sub send_emails
{
  my ($self) = @_;
  return if( !(defined $self->user_emails) || ( @{$self->user_emails} == 0 ) );
  
  $self->_send_emails() if((@{$self->qc_lane_ids} > 0) || (@{$self->mapped_lane_ids} > 0));

}

### END public methods ###


### builders ###
sub _build_user_emails
{
  my ($self) = @_;
  my $user_study = PipelinesReporting::UserStudies->new( _dbh => $self->_qc_dbh, email_domain => $self->email_domain );
  return $user_study->study_user_emails($self->sequencescape_study_id);
}

sub _build_qc_lane_ids
{
  my ($self) = @_;
  return if( !(defined $self->user_emails) || ( @{$self->user_emails} == 0 ) );
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
  my ($self) = @_;
  return if( !(defined $self->user_emails) || ( @{$self->user_emails} == 0 ) );
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
sub _project
{
  my ($self) = @_;
  $self->_pipeline_dbh->resultset('Project')->search({ 'me.ssid' => $self->sequencescape_study_id  })->first;
}
sub _samples_result_set
{
  my ($self) = @_;
  # in VRTrack a project contains the sequencescape study id
  $self->_pipeline_dbh->resultset('Project')->search({ 'me.ssid' => $self->sequencescape_study_id  })->search_related('samples');
}

sub _libraries_result_set
{
  my ($self) = @_;
  $self->_samples_result_set()->search_related('libraries');
}

sub _lanes_result_set
{
  my ($self, $processed) = @_;
  $self->_libraries_result_set()->search_related('lanes', { 'lanes.processed' => $processed });
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

sub _send_emails
{
  my ($self) = @_;
  my $study_name = $self->_project->name;

  my $qc_body = $self->_construct_email_body_for_lane_action('QC', $self->qc_lane_ids);
  my $mapped_body =  $self->_construct_email_body_for_lane_action('Mapping', $self->mapped_lane_ids);
  
  my $to_email_addresses = join(',',@{$self->user_emails});
  
  sendmail(-from => $self->email_from_address,
	           -to => $to_email_addresses,
	      -subject => "Lanes processed for $study_name",
	         -body => $qc_body."\n".$mapped_body);
}

sub _construct_email_body_for_lane_action
{
  my ($self, $action_name,  $lane_ids) = @_;
  my $study_name = $self->_project->name;

  my $body = '';
  if(@{$lane_ids}> 0)
  {
    my $lane_urls_str = join("\n",@{$self->_construct_lane_urls($lane_ids)});
    $body = <<BODY;
The following lanes have finished $action_name in Study $study_name.

$lane_urls_str

BODY
  }
    
  return $body;
}

sub _construct_lane_urls
{
  my ($self, $lane_ids) = @_;
  my @lane_urls;
  for my $lane_id (@{$lane_ids})
  {
    push(@lane_urls, $self->qc_grind_url.'?mode=0&lane_id='.$lane_id.'&db='.$self->database_name );
  }
  
  return \@lane_urls;
}

# ToDo put into module
sub sendmail {
  my %args = @_;
  my ($from, $to, $subject, $body) = @args{qw(-from -to -subject -body)};

  unless(open (MAIL, "|/usr/sbin/sendmail -t")) {
    warn "Error starting sendmail: $!";
  }
  else{
    print MAIL "From: $from\n";
    print MAIL "To: $to\n";
    print MAIL "Subject: $subject\n\n";
    print MAIL $body;

    if (close(MAIL)) {
    }
    else {
      warn "Failed to send mail: $!";
    }
  }
}

1;
