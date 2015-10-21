CREATE TABLE `user_studies` (
  `sequencescape_study_id` smallint(5) unsigned NOT NULL,
  `username` varchar(40) NOT NULL DEFAULT '',
  PRIMARY KEY (`sequencescape_study_id`,`username`),
  KEY `sequencescape_study_id` (`sequencescape_study_id`),
  KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `lane_emails` (
  `name` varchar(255)  NOT NULL,
  `qc_email_sent` tinyint(1) DEFAULT 0,
  `mapping_email_sent` tinyint(1) DEFAULT 0,
 `assembly_email_sent` tinyint(1) DEFAULT 0,
 `annotation_email_sent` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
