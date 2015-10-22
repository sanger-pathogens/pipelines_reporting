package PipelinesReporting::Schema::Result::LaneEmails;
use base qw/DBIx::Class::Core/;

# QC database

__PACKAGE__->table('lane_emails');
__PACKAGE__->add_columns('name' , 'qc_email_sent' , 'mapping_email_sent', 'assembly_email_sent', 'annotation_email_sent' );
__PACKAGE__->set_primary_key('name');

1;
