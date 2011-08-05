=head1 NAME

SendPipelineEmails.pm   - Go through each pipeline database and send emails to all studies

=head1 SYNOPSIS

use PipelinesReporting::SendPipelineEmails;
PipelinesReporting::SendPipelineEmails->new(
  _qc_dbh => $qc_dbh,
  pipeline_databases => { db1 => { host => 'example.com', port => 3306, database => 'dbname', user => 'dbusername', password => 'mypassword'} },
  database_password => 'my optional default password',
  email_from_address => 'example@example.com',
  email_domain => 'example.com',
  qc_grind_url => 'http://example.com'
);

=cut

package PipelinesReporting::SendPipelineEmails;
use Moose;
use PipelinesReporting::Schema;
use PipelinesReporting::SendStudyEmails;

has 'pipeline_databases'     => ( is => 'rw', isa => 'HashRef', required => 1);
has 'database_password'      => ( is => 'rw', isa => 'Maybe[Str]');
has '_qc_dbh'                => ( is => 'rw', required   => 1 );
has 'email_from_address'     => ( is => 'rw', isa => 'Str', required   => 1 );
has 'email_domain'           => ( is => 'rw', isa => 'Str', required   => 1 );
has 'qc_grind_url'           => ( is => 'rw', isa => 'Str', required   => 1 );

sub BUILD
{
  my ($self) = @_;
  
  for my $pipeline_database_name(keys %{$self->pipeline_databases})
  {
    my %pipeline_database = %{%{$self->pipeline_databases}->{$pipeline_database_name}};
    next if((defined $pipeline_database{disable_emails}) && $pipeline_database{disable_emails} == 1);
    
    my $database_password = $pipeline_database{password} || $self->database_password;
    my $pipeline_dbh = PipelinesReporting::Schema->connect(
      "DBI:mysql:host=$pipeline_database{host}:port=$pipeline_database{port};database=$pipeline_database{database}", 
      $pipeline_database{user}, $database_password, {'RaiseError' => 1, 'PrintError'=>0}
    );
    
    PipelinesReporting::SendStudyEmails->new(  
      _pipeline_dbh => $pipeline_dbh,
      _qc_dbh => $self->_qc_dbh,
      email_from_address => $self->email_from_address,
      email_domain => $self->email_domain,
      qc_grind_url => $self->qc_grind_url,
      database_name => $pipeline_database{database}
    );
    
  }

}


1;
