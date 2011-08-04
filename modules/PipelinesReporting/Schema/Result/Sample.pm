package PipelinesReporting::Schema::Result::Sample;
use base qw/DBIx::Class::Core/;

# pipeline database

__PACKAGE__->table('latest_sample');
__PACKAGE__->add_columns(qw/row_id sample_id project_id/);
__PACKAGE__->set_primary_key('row_id');
__PACKAGE__->has_many(libraries => 'PipelinesReporting::Schema::Result::Library', 'library_id');
__PACKAGE__->belongs_to(project => 'PipelinesReporting::Schema::Result::Project', { 'foreign.project_id' => 'self.project_id' });

1;
