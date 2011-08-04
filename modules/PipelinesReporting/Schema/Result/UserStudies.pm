package PipelinesReporting::Schema::Result::UserStudies;
use base qw/DBIx::Class::Core/;

# QC database

__PACKAGE__->table('user_studies');
__PACKAGE__->add_columns('row_id', 'study_id', 'username');
__PACKAGE__->set_primary_key('row_id');

1;
