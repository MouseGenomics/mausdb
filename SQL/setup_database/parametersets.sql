-- 1) an example phenotype data assay measuring body mass and length of a mouse
INSERT
INTO   parametersets
VALUES
(1,'example_set','example parameterset',1,1,1,'1','2010-03-29 16:54:32','y');

INSERT
INTO   parameters
VALUES
(1,'bodymass',  'bodymass',  'f',1,'g', 'body mass of a mouse',  '25', '','','n'),
(2,'bodylength','bodylength','i',0,'mm','body length of a mouse','100','','','n');

INSERT
INTO   parametersets2parameters
VALUES
(1,1,NULL,NULL,4,'mass',  'simple','','','y'),
(1,2,NULL,NULL,3,'length','simple','','','y');

INSERT
INTO   settings
VALUES
(NULL,'upload_column','mouse_id',    '1','integer',1,NULL,NULL,NULL,NULL),
(NULL,'upload_column','measure_date','1','integer',2,NULL,NULL,NULL,NULL);

INSERT
INTO   workflows
VALUES
(1, 'mass-length', 'mass-length','y');

INSERT
INTO   workflows2parametersets
VALUES
(1,1,0);
-- -------------------------------------------------------------------------------------------------
-- 2) an example of a routine task 'mate' that can be scheduled/ordered using the phenotyping system
INSERT
INTO   parametersets
VALUES
(2,'mate','mate',1,4,2,'1','2010-03-29 16:54:32','y');

INSERT
INTO   workflows
VALUES
(2,'Mate', 'Mate','y');

INSERT
INTO   workflows2parametersets
VALUES
(2,2,0);
