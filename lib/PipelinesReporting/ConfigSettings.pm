=head1 NAME

ConfigSettings.pm   - Return configuration settings

=head1 SYNOPSIS

use PipelinesReporting::ConfigSettings;
my %config_settings = %{PipelinesReporting::ConfigSettings->new(environment => 'test')->settings()};

=cut

package PipelinesReporting::ConfigSettings;

use Moose;
use File::Slurp;
use YAML::XS;

has 'environment' => (is => 'rw', isa => 'Str', default => 'test');
has 'filename' => ( is => 'rw', isa => 'Str', default => 'config.yml' );
has 'settings' => ( is => 'rw', isa => 'HashRef', lazy_build => 1 );


sub _build_settings 
{
  my $self = shift;
  my $config_base_dir = $ENV{'CONFIG_BASE_DIR'} // '.' ; 
  my %config_settings = %{ Load( scalar read_file($config_base_dir."/config/".$self->environment."/".$self->filename.""))};

  return \%config_settings;
} 

1;
