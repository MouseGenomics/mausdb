

INSERT INTO `settings`
VALUES
-- define email addresses of your system administrators
( 1,'admin','admin_mail','1','text',NULL,'admin1@yourinstitution.com; admin2@yourinstitution.com',NULL,NULL,NULL),

-- genotypes to assign
( 2,'menu','genotypes_for_popup', '1','text',NULL,'ukn',          NULL,NULL,NULL),
( 3,'menu','genotypes_for_popup', '2','text',NULL,'wt',           NULL,NULL,NULL),
( 4,'menu','genotypes_for_popup', '3','text',NULL,'+/+',          NULL,NULL,NULL),
( 5,'menu','genotypes_for_popup', '4','text',NULL,'+/-',          NULL,NULL,NULL),
( 6,'menu','genotypes_for_popup', '5','text',NULL,'-/-',          NULL,NULL,NULL),
( 7,'menu','genotypes_for_popup', '6','text',NULL,'+/0'  ,        NULL,NULL,NULL),
( 8,'menu','genotypes_for_popup', '7','text',NULL,'-/0',          NULL,NULL,NULL),
( 9,'menu','genotypes_for_popup', '8','text',NULL,'hom',          NULL,NULL,NULL),
(10,'menu','genotypes_for_popup', '9','text',NULL,'het',          NULL,NULL,NULL),
(11,'menu','genotypes_for_popup','10','text',NULL,'mut',          NULL,NULL,NULL),
(12,'menu','genotypes_for_popup','11','text',NULL,'tg',           NULL,NULL,NULL),
(13,'menu','genotypes_for_popup','12','text',NULL,'tg/+',         NULL,NULL,NULL),
(14,'menu','genotypes_for_popup','15','text',NULL,'tg/tg',        NULL,NULL,NULL),
(15,'menu','genotypes_for_popup','21','text',NULL,'any',          NULL,NULL,NULL),
(16,'menu','genotypes_for_popup','22','text',NULL,'please choose',NULL,NULL,NULL),

-- define cage card bar colors (1)
(17,'menu','cardcolors_for_popup', '1','text',NULL,'yellow',     NULL,NULL,NULL),
(18,'menu','cardcolors_for_popup', '2','text',NULL,'red',        NULL,NULL,NULL),
(19,'menu','cardcolors_for_popup', '3','text',NULL,'blue',       NULL,NULL,NULL),
(20,'menu','cardcolors_for_popup', '4','text',NULL,'green',      NULL,NULL,NULL),
(21,'menu','cardcolors_for_popup', '5','text',NULL,'purple',     NULL,NULL,NULL),
(22,'menu','cardcolors_for_popup', '6','text',NULL,'orange',     NULL,NULL,NULL),
(23,'menu','cardcolors_for_popup', '7','text',NULL,'black',      NULL,NULL,NULL),
(24,'menu','cardcolors_for_popup', '9','text',NULL,'violet',     NULL,NULL,NULL),
(25,'menu','cardcolors_for_popup', '8','text',NULL,'white',      NULL,NULL,NULL),
(26,'menu','cardcolors_for_popup','10','text',NULL,'grey',       NULL,NULL,NULL),
(27,'menu','cardcolors_for_popup','11','text',NULL,'pink',       NULL,NULL,NULL),
(28,'menu','cardcolors_for_popup','12','text',NULL,'lightgreen', NULL,NULL,NULL),
(29,'menu','cardcolors_for_popup','13','text',NULL,'lightblue',  NULL,NULL,NULL),
(30,'menu','cardcolors_for_popup','14','text',NULL,'brown',      NULL,NULL,NULL),

-- define cage card bar colors (2)
(31,'cardcolors_for_popup','yellow',     '1','text',NULL,'#FFFF00',NULL,NULL,NULL),
(32,'cardcolors_for_popup','red',        '2','text',NULL,'#FF0000',NULL,NULL,NULL),
(33,'cardcolors_for_popup','blue',       '3','text',NULL,'#0000FF',NULL,NULL,NULL),
(34,'cardcolors_for_popup','green',      '4','text',NULL,'#008000',NULL,NULL,NULL),
(35,'cardcolors_for_popup','purple',     '5','text',NULL,'#8000FF',NULL,NULL,NULL),
(36,'cardcolors_for_popup','orange',     '6','text',NULL,'#FF8000',NULL,NULL,NULL),
(37,'cardcolors_for_popup','black',      '7','text',NULL,'#000000',NULL,NULL,NULL),
(38,'cardcolors_for_popup','white',      '8','text',NULL,'#FFFFFF',NULL,NULL,NULL),
(39,'cardcolors_for_popup','violet',     '9','text',NULL,'#800080',NULL,NULL,NULL),
(40,'cardcolors_for_popup','grey',      '10','text',NULL,'#C0C0C0',NULL,NULL,NULL),
(41,'cardcolors_for_popup','lightblue', '13','text',NULL,'#8080FF',NULL,NULL,NULL),
(42,'cardcolors_for_popup','pink',      '11','text',NULL,'#FF8080',NULL,NULL,NULL),
(43,'cardcolors_for_popup','brown',     '14','text',NULL,'#808000',NULL,NULL,NULL),
(44,'cardcolors_for_popup','lightgreen','12','text',NULL,'#00FF00',NULL,NULL,NULL),

-- status codes for phenotype records (tells why data is missing)
(45,'menu','mr_status_codes','','text',NULL,'_DIED_',   NULL,NULL,'Mouse died'),
(46,'menu','mr_status_codes','','text',NULL,'_CULLED_', NULL,NULL,'Mouse culled for welfare reasons'),
(47,'menu','mr_status_codes','','text',NULL,'_SL_',     NULL,NULL,'Sample lost'),
(48,'menu','mr_status_codes','','text',NULL,'_PF-EF_',  NULL,NULL,'Procedure failed - Equipment Failed'),

-- cohort purposes and types
(49,'menu','cohort_purpose','','text', NULL,'routine',  NULL,NULL,NULL),
(50,'menu','cohort_purpose','','text', NULL,'special',  NULL,NULL,NULL),
(51,'menu','cohort_type','','text',    NULL,'mutant',   NULL,NULL,NULL),
(52,'menu','cohort_type','','text',    NULL,'control',  NULL,NULL,NULL);

