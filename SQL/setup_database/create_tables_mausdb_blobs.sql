-- This is to create the only table in mausdb_blobs
--
-- This SQL script will work with MySQL. For use with other DBMSs, some modification may
-- be neccessary (i.e. data types,...)
--
-- Holger Maier, 30. March 2010
--
-- ========================================================================================

DROP TABLE IF EXISTS blob_data;
CREATE TABLE blob_data (
-- every blob has an entry here

-- primary key: serial blob id
  blob_id                                 int                         NOT NULL auto_increment

-- name of blob filename, i.e. excel file name
, blob_name                               varchar(255)                NOT NULL

-- blob type, i.e. "excel", "jpeg", "pdf", "tiff", ...
, blob_content_type                       varchar(255)                default NULL

-- blob mime-type
, blob_mime_type                          varchar(255)                default NULL

-- the blob itself
, blob_itself                             longblob                    default NULL

-- datetime of blob upload
, blob_upload_datetime                    datetime                    default NULL

-- comment to file
, blob_comment                            text                        NULL

-- upload user
, blob_upload_user                        int                         default NULL

-- is the blob public or not?
, blob_is_public                          char(1)                     NOT NULL

, PRIMARY KEY                             (blob_id)
)
ENGINE=MYISAM
;
CREATE INDEX blob_name     ON blob_data (blob_name);

