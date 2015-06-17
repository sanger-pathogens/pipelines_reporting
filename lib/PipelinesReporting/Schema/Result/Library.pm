package PipelinesReporting::Schema::Result::Library;
use base qw/DBIx::Class::Core/;

# pipeline database

__PACKAGE__->table('latest_library');
__PACKAGE__->add_columns(qw/row_id library_id sample_id/);
__PACKAGE__->set_primary_key('row_id');
__PACKAGE__->has_many(lanes => 'PipelinesReporting::Schema::Result::Lane', { 'foreign.library_id' => 'self.library_id' });
__PACKAGE__->belongs_to(sample => 'PipelinesReporting::Schema::Result::Sample', { 'foreign.sample_id' => 'self.sample_id' });

1;
