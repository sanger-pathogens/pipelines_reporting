package PipelinesReporting::Schema::Result::Project;
use base qw/DBIx::Class::Core/;

# pipeline database

__PACKAGE__->table('latest_project');
__PACKAGE__->add_columns(qw/row_id ssid project_id/);
__PACKAGE__->set_primary_key('row_id');
__PACKAGE__->has_many(samples => 'PipelinesReporting::Schema::Result::Sample', 'sample_id');

1;
