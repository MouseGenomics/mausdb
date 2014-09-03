INSERT
INTO   addresses
VALUES
(1,'YourInstitute','YourStreet. 1','12345','','YourTown',NULL,'Germany','YourPhone','YourFax',NULL,'');

INSERT
INTO   contacts2addresses
VALUES (1,1);

INSERT
INTO   contacts
VALUES
(1,'y','Dr.','n','scientist','Administrator','','m','mausdbadmin@yourinstitution.com','');

INSERT
INTO   users
VALUES
(1,'admin',1,'05bb2a06bb20a6f5df2a33fdc3f977c8','active','ua','initial admin account');

INSERT
INTO   projects
VALUES (1,'first_project','first_project', 'first_project',NULL,1);

INSERT
INTO   users2projects
VALUES
(1,1,'v');