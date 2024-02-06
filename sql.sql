CREATE TABLE IF NOT EXISTS `salon` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booksList` longtext DEFAULT '{}',
  `businessData` longtext DEFAULT '{}',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `salon` (id, `booksList` , `businessData`) VALUES (1, '{}', '{}');

INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES ('salon', 'Salon', 0);


INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES (336, 'salon', 1, 'Salon', 'Intern', 20, '{}', '{}');
INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES (337, 'salon', 2, 'Salon', 'Worker', 40, '{}', '{}');
INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES (338, 'salon', 3, 'Salon', 'Manager', 60, '{}', '{}');
INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES (339, 'salon', 4, 'Salon', 'Owner', 80, '{}', '{}');

