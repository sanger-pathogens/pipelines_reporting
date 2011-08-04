=head1 NAME

LaneEmails.pm   - Records if an email has been sent for different actions on a lane. Used to limit emails to people.

=head1 SYNOPSIS

use PipelinesReporting::LaneEmails;
my $lane_email = PipelinesReporting::LaneEmails->new(
  _dbh => $dbh,
  lane_id => 1234
  );
$lane_email->is_qc_email_sent();
$lane_email->is_mapping_email_sent();

=cut

package PipelinesReporting::LaneEmails;
use Moose;
use PipelinesReporting::Schema;

has '_dbh'        => ( is => 'rw', required   => 1 );
has 'lane_id'     => ( is => 'rw', isa => 'Int', required   => 1 );
has 'lane_email'  => ( is => 'rw', lazy_build   => 1 );


sub _build_lane_email
{
  my ($self) = @_;
  my $lane_email_rs = $self->_lane_email_rs();
  unless(defined $lane_email_rs)
  {
    $lane_email_rs   = $self->_dbh->resultset('LaneEmails')->create({ lane_id => $self->lane_id, qc_email_sent => 0, mapping_email_sent => 0 });
  }
  return $lane_email_rs;
}

sub _lane_email_rs
{
  my ($self) = @_;
  my $lane_email_rs = $self->_dbh->resultset('LaneEmails')->search(
    { lane_id =>  $self->lane_id }
  )->first;
  
  return $lane_email_rs;
}

sub is_qc_email_sent
{
  my ($self) = @_;
  return $self->lane_email->qc_email_sent;
}

sub is_mapping_email_sent
{
  my ($self) = @_;
  return $self->lane_email->mapping_email_sent;
}

sub qc_email_sent
{
  my ($self) = @_;
  $self->lane_email->qc_email_sent(1);
  $self->lane_email->update;
}

sub mapping_email_sent
{
  my ($self) = @_;
  $self->lane_email->mapping_email_sent(1);
  $self->lane_email->update;
}

1;
