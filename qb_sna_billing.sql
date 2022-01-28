DROP TABLE `accounting`;

CREATE TABLE `accounting` (
	`id` int NOT NULL AUTO_INCREMENT,
	`reference` varchar(30),
	`type` varchar(3),
	`issuer` varchar(8),
	`job` varchar(20),
	`customer` varchar(8),
	`date` varchar(8),
	`status` varchar(1),
	`amount` int,
	`reason` varchar(2000),
	PRIMARY KEY (`id`)
);
