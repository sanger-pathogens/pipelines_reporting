CREATE TABLE `user_studies` (
  `row_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sequencescape_study_id` smallint(5) unsigned NOT NULL,
  `username` varchar(40) NOT NULL DEFAULT '',
  PRIMARY KEY (`row_id`),
  KEY `sequencescape_study_id` (`sequencescape_study_id`),
  KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `lane_emails` (
  `lane_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `qc_email_sent` tinyint(1) DEFAULT 0,
  `mapping_email_sent` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`lane_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;