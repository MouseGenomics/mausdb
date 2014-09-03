-- This file contains the complete set of SQL commands to generate all tables of MausDB.
-- It also contains the documentation and description of tables and columns
--
-- This SQL script will work with MySQL. For use with other DBMSs, some modification may
-- be neccessary (i.e. data types,...)
--
-- Holger Maier, 30. March 2010
-- ========================================================================================
--
-- comments:
-- --------------
-- 1) foreign key - primary key constraints are defined at the end of this script
-- 2) we did not pay any attention to fine tuning of data types so far, since we did not observe performance problems yet
-- --------------


-- optionally drop and re-create the database
-- drop   database mausdb_er;
-- create database mausdb_er;
-- use             mausdb_er;

-- ========================================================================================
-- Database schema change history
-- ========================================================================================
--
-- 05. Juni 2007
-- ===================
-- added new table GTAS_line_info (definition see below)
-- added new table cohorts  (definition see below)
-- added new table mice2cohorts  (definition see below)
-- added new table metadata_definitions  (definition see below)
-- added new table metadata  (definition see below)
--
--
-- 22. Januar 2008
-- ===============
-- table cohorts (new column):
-- alter table  cohorts add column cohort_status varchar(20) default NULL after cohort_description;
-- CREATE INDEX cohort_status ON cohorts (cohort_status);

-- table medical_records (new columns):
-- alter table medical_records add column mr_increment_value varchar(20) default NULL after mr_is_dependent;
-- alter table medical_records add column mr_increment_unit  varchar(20) default NULL after mr_increment_value;
-- alter table medical_records add column mr_status          varchar(20) default NULL after mr_measure_datetime;
-- CREATE INDEX mr_status ON medical_records (mr_status);

-- table parametersets2parameters (new columns):
-- alter table parametersets2parameters add column p2p_parameter_category varchar(20) default 'simple' after p2p_upload_column_name;
-- alter table parametersets2parameters add column p2p_increment_value    varchar(20) default 'simple' after p2p_parameter_category;
-- alter table parametersets2parameters add column p2p_increment_unit     varchar(20) default NULL     after p2p_increment_value;
-- CREATE INDEX p2p_parameter_category ON parametersets2parameters (p2p_parameter_category);

-- table parametersets2parameters (new primary key):
-- alter table parametersets2parameters drop primary key;
-- alter table parametersets2parameters add primary key (p2p_parameterset_id, p2p_parameter_id, p2p_increment_value);

-- table parameters (new column):
-- alter table parameters add column parameter_is_metadata char(1) default 'n' after parameter_normal_range;
--
--
-- 28. April 2008 (new treatment module added)
-- ===============
-- added new table treatments (definition see below)
-- added new table mice2treatments (definition see below)
--
--
-- 30. April 2008
-- ==============
-- added new table mice_cage_rack_placements (definition see below)
--
--
-- 21. Mai 2008
-- ============
-- added new table parent_strains2litter_strain (definition see below)
--
--
-- 05. August 2008
-- ===============
-- table genes (new column):
-- alter table genes add column gene_valid_qualifiers text after gene_description;
--
-- [optional: transfer existing qualifiers from mice2genes table]
-- create temporary table
-- Create TEMPORARY Table valid_genotype_qualifiers (ig_gene_id int, valid_qualifiers text);
--
-- -- fill temporary table with distinct values from mice2genes table
-- insert into valid_genotype_qualifiers (ig_gene_id, valid_qualifiers)
-- select gene_id, concat(group_concat(distinct m2g_genotype SEPARATOR ";"), ";")
-- from   mice2genes
--        join genes on m2g_gene_id = gene_id
-- group  by m2g_gene_id
-- order  by gene_name;
--
-- -- now update table genes with values taken from temporary table
-- update genes g, valid_genotype_qualifiers v
-- set    g.gene_valid_qualifiers = v.valid_qualifiers
-- where  g.gene_id = v.ig_gene_id;
--
-- -- drop temporary table
-- drop table valid_genotype_qualifiers;


-- 24. November 2008
-- =================
-- table parametersets2parameters (new column):
-- ALTER TABLE parametersets2parameters add column p2p_parameter_required char(1) not null default "y" after p2p_increment_unit;
-- CREATE INDEX p2p_parameter_required ON parametersets2parameters (p2p_parameter_required);
--
--
-- 08. Dezember 2008
-- =================
-- table cohorts (new columns):
-- ALTER TABLE cohorts ADD COLUMN cohort_type varchar(255) default NULL after cohort_datetime;
-- ALTER TABLE cohorts ADD COLUMN cohort_reference_cohort int default NULL after cohort_type;
-- CREATE INDEX cohort_type ON cohorts (cohort_type);
--
--
-- 08. Februar 2010
-- =================
-- table metadata_definitions (new column):
-- ALTER TABLE metadata_definitions ADD COLUMN mdd_required varchar(1) default 'n' after mdd_active_yn;
-- CREATE INDEX mdd_required ON metadata_definitions (mdd_required);
--
-- ========================================================================================

DROP TABLE IF EXISTS parent_strains2litter_strain;
CREATE TABLE parent_strains2litter_strain (
-- look-up table: using first two columns as input (mother strain, father strain), litter strain can be determined

-- strain of mother
  ps2ls_mother_strain   int   NOT NULL

-- strain of father
, ps2ls_father_strain   int   NOT NULL

-- resulting strain of litter
, ps2ls_litter_strain   int   NOT NULL

, PRIMARY KEY (ps2ls_mother_strain, ps2ls_father_strain)
)
ENGINE=InnoDB
;



DROP TABLE IF EXISTS treatment_procedures;
CREATE TABLE treatment_procedures (
-- every treatment procedure has an entry here

-- primary key: serial treatment procedure id
   tp_id                                     int                        NOT NULL

-- treatment name
,  tp_treatment_name                         varchar(50)                NOT NULL

-- treatment name
,  tp_treatment_description                  varchar(255)               NULL

-- treatment full protocol
,  tp_treatment_full_protocol                text                       NULL

-- type of treatment ('diet', 'irradiation', 'substance applicaton'),  values defined in "settings" table
,  tp_treatment_type                         varchar(50)                NOT NULL

-- type of application ('i.v.', 'i.p.', 'oral', ...),  values defined in "settings" table
,  tp_application_type                       varchar(50)                NOT NULL

-- applied substance (ENU, glucose, ...)
,  tp_applied_substance                      varchar(255)               default NULL

-- amount of applied substance
,  tp_applied_substance_amount               float                      default NULL

-- unit of applied substance amount
,  tp_applied_substance_amount_unit          varchar(20)                default NULL

-- applied substance concentration
,  tp_applied_substance_concentration        float                      default NULL

-- unit of applied substance concentration
,  tp_applied_substance_concentration_unit   varchar(20)                default NULL

-- applied substance final volume
,  tp_applied_substance_volume               float                      default NULL

-- applied substance final volume unit
,  tp_applied_substance_volume_unit          varchar(20)                default NULL

-- medium, in which substance is applied (food, water, solvent), values defined in "settings" table
,  tp_application_medium                     varchar(20)                default NULL

-- purpose of treatment
,  tp_application_purpose                    varchar(255)               default NULL

-- which project/module is responsible for the treatment?
,  tp_treatment_project                      int                        NOT NULL

-- date of treatment inactivation
,  tp_treatment_deprecated_since             date                       default NULL

, PRIMARY KEY (tp_id)
)
ENGINE=InnoDB
;



DROP TABLE IF EXISTS mice2treatment_procedures;
CREATE TABLE mice2treatment_procedures (
-- cross table: "mice" <-> "treatment_procedures"

-- primary key
   m2tp_id                                   int                        NOT NULL auto_increment

-- foreign key (-> table "mice"): ID of treated mouse
,  m2tp_mouse_id                             int                        NOT NULL

-- foreign key (-> table "treatment_procedures"): ID of treatment procedures
,  m2tp_treatment_procedure_id               int                        NOT NULL

-- datetime of treatment (for unique treatments)
,  m2tp_treatment_datetime                   datetime                   NOT NULL

-- applied amount
,  m2tp_applied_amount                       float                      NOT NULL

-- applied amount unit
,  m2tp_applied_amount_unit                  varchar(20)                NOT NULL

-- datetime of application start (for application series)
,  m2tp_application_start_datetime           datetime                   NOT NULL

-- datetime of application end   (for application series)
,  m2tp_application_end_datetime             datetime                   NOT NULL

-- application / treatment succes [y/n]?
,  m2tp_treatment_success                    char(1)                    NOT NULL

-- if application/treatment cancelled, why?
,  m2tp_application_terminated_why           varchar(255)               NOT NULL

-- foreign key (-> table "users"): ID of user who applied the substance / treated the mouse
,  m2tp_treatment_user_id                    int                        NOT NULL

-- application/treatment comment
,  m2tp_application_comment                  text                       NOT NULL

, PRIMARY KEY (m2tp_id)
)
ENGINE=InnoDB
;
CREATE INDEX m2tp_mouse_id                ON mice2treatment_procedures (m2tp_mouse_id);
CREATE INDEX m2tp_treatment_procedure_id  ON mice2treatment_procedures (m2tp_treatment_procedure_id);
CREATE INDEX m2tp_treatment_user_id       ON mice2treatment_procedures (m2tp_treatment_user_id);




DROP TABLE IF EXISTS mice_cage_rack_placements;
CREATE TABLE mice_cage_rack_placements (
-- placement of mice in cages and racks is stored in tables mice2cages and cages2locations
-- however, as cage_ids are being recycled, the placement of a mouse in a distinct rack at a distinct point in time
-- cannot be queried from these two tables by pure SQL easily
-- This table makes mice/cage/rack-placement unambigous (table is filled by an external skript when needed)
  mcrp_placement_id   int         NOT NULL auto_increment
, mcrp_mouse_id       int         NOT NULL
, mcrp_cage_of_mouse  int
, mcrp_cage_id        int         NOT NULL
, mcrp_cage_from      datetime
, mcrp_cage_to        datetime
, mcrp_rack_id        int
, mcrp_rack_room      varchar(20)
, mcrp_rack_name      varchar(20)
, mcrp_rack_from      datetime
, mcrp_rack_to        datetime
, PRIMARY KEY (mcrp_placement_id)
)
;
CREATE INDEX mcrp_mouse_id   ON mice_cage_rack_placements (mcrp_mouse_id);
CREATE INDEX mcrp_cage_id    ON mice_cage_rack_placements (mcrp_cage_id);
CREATE INDEX mcrp_rack_id    ON mice_cage_rack_placements (mcrp_rack_id);
CREATE INDEX mcrp_rack_room  ON mice_cage_rack_placements (mcrp_rack_room);




DROP TABLE IF EXISTS GTAS_line_info;
CREATE TABLE GTAS_line_info (
-- for every mouse line, there needs to be additional information
-- for the GSF "GTAS" database, that tracks genetically modified organisms

-- primary key: serial GTAS line info ID
   gli_id                            int                 NOT NULL

-- foreign key (-> table "mouse_lines") the id of the mouse line that is referred
,  gli_mouse_line_id                 int                 NOT NULL

-- is mouse line genetically modified [y/n]?
,  gli_mouse_line_is_gvo             char(1)             NOT NULL

-- the following columns correspond to the GTAS specifications and are therefore in German

-- A; Muss-Feld: GTAS-Projektnummer
,  gli_Projektnr                     int                 default 51272

-- B; Muss-Feld: GTAS-Institut
,  gli_Institutscode                 varchar(255)        default 'AVM'

-- C; Kann-Feld
,  gli_Bemerkungen                   varchar(255)        default ''

-- D; Muss-Feld
,  gli_Spenderorganismen             varchar(255)        default ''

-- E; Kann-Feld
,  gli_Nukleinsaeure_Bezeichnung     varchar(255)        default ''

-- F; Kann-Feld
,  gli_Nukleinsaeure_Merkmale        varchar(255)        default ''

-- G; Muss-Feld
,  gli_Vektoren                      varchar(255)        default ''

-- H; Muss-Feld
,  gli_Empfaengerorganismen          varchar(255)        default 'Maus'

-- I; Muss-Feld
,  gli_GVO_Merkmale                  varchar(255)        default ''

-- J; Muss-Feld: Erstimportdatum der Mauslinie bzw. Datum eines Re-Imports, nachdem Bestand zwischenzeitlich auf 0 war
,  gli_GVO_ErzeugtAm                 date                NOT NULL

-- K; Muss-Feld
,  gli_Risikogruppe_Empfaenger       varchar(255)        default 'S1'

-- L; Muss-Feld
,  gli_Risikogruppe_GVO              varchar(255)        default 'S1'

-- M; Muss-Feld
,  gli_Risikogruppe_Spender          varchar(255)        default 'S1'

-- N; Kann-Feld: Lagerung und evtl. Herkunft
,  gli_Lagerung                      varchar(255)        default ''

-- O; Kann-Feld
,  gli_Sonstiges                     varchar(255)        default ''

-- P; Muss-Feld: Tep-Stammname
,  gli_TepID                         varchar(30)         default ''

-- Q; Muss-Feld: UserID
,  gli_SysID                         varchar(255)        default 'GMC'

-- R; Muss-Feld: Mandantencode
,  gli_OrgCode                       varchar(255)        default 'GSF'

-- Flag: definiert, ob Eintrag bei der Generierung des naechsten Reports beruecksichtigt werden soll
,  gli_generate_GTAS_report          char(1)             default 'y'

-- Referenz auf externe CoordDB-Datenbank: ID der Linie in CoordDB
,  gli_line_id_in_coordDB            int                 default NULL

-- Referenz auf externe CoordDB-Datenbank: Name der Linie in CoordDB
,  gli_line_name_in_coordDB          varchar(255)        default NULL

, PRIMARY KEY (gli_id)
)
ENGINE=InnoDB
;
CREATE INDEX gli_mouse_line_id                ON GTAS_line_info (gli_mouse_line_id);
CREATE INDEX gli_mouse_line_is_gvo            ON GTAS_line_info (gli_mouse_line_is_gvo);
CREATE INDEX gli_generate_GTAS_report         ON GTAS_line_info (gli_generate_GTAS_report);




DROP TABLE IF EXISTS matings;
CREATE TABLE matings (
-- every mating has an entry here
-- parents of a mating: -> table "parents2matings"

-- primary key: serial mating id
  mating_id                           int                 NOT NULL

-- arbitrary mating name (set by user)
, mating_name                         varchar(255)        default ''

-- type of mating
, mating_type                         varchar(20)         default NULL

-- start of mating
, mating_matingstart_datetime         datetime            default NULL

-- end of mating (may be defined by separation of parents, death of a parent, ...)
, mating_matingend_datetime           datetime            default NULL

-- foreign key (-> table "mouse_strains"): genetic background, i.e. "Balb/c", "129", "C57BL/6", ...
, mating_strain                       int                 NOT NULL

-- foreign key (-> table "mouse_lines"): line
, mating_line                         int                 NOT NULL

-- mating scheme: "inbred", "outbred", "backcross", ....
-- (options defined in table "settings")
, mating_scheme                       varchar(255)        default ''

-- mating for what purpose ("breed", "test", "embryo production",...)
-- (options defined in table "settings")
, mating_purpose                      varchar(255)        default ''

-- foreign key (-> table "projects"): assigned project
, mating_project                      int                 NOT NULL

-- generation code, set by user (F1, G2, R3, ...)
, mating_generation                   varchar(20)         default ''

-- comment
, mating_comment                      text                default ''

, PRIMARY KEY (mating_id)
) 
ENGINE=InnoDB
;
CREATE INDEX mating_name                   ON matings (mating_name);
CREATE INDEX mating_matingstart_datetime   ON matings (mating_matingstart_datetime);
CREATE INDEX mating_matingend_datetime     ON matings (mating_matingend_datetime);
CREATE INDEX mating_strain                 ON matings (mating_strain);
CREATE INDEX mating_line                   ON matings (mating_line);
CREATE INDEX mating_scheme                 ON matings (mating_scheme);
CREATE INDEX mating_purpose                ON matings (mating_purpose);
CREATE INDEX mating_project                ON matings (mating_project);
CREATE INDEX mating_generation             ON matings (mating_generation);



DROP TABLE IF EXISTS embryo_transfers;
CREATE TABLE embryo_transfers (
-- every embryo transfer (et) has its entry here.
-- an embryo transfer is treated as a special case of a mating.
-- it is joined to matings on et_mating_id = mating_id

-- primary key: serial transfer id
  transfer_id                           int                 NOT NULL

-- join to matings
-- foreign key (-> table "matings"): mating_id
, transfer_mating_id                    int                 default NULL

-- identifier for embryo: any alphanumerical identifier for an embryo
, transfer_embryo_id                    varchar(30)         default ''

-- embryo id context: context in which above transfer_embryo_id to use
, transfer_embryo_id_context            varchar(30)         default ''

-- embryo production: either 'in_vitro' or 'in_vivo'
, transfer_embryo_production            varchar(10)         default ''

-- sperm preservation: either 'fresh' or 'frozen'
, transfer_sperm_preservation           varchar(8)          default ''

-- IVF assistance: 'none', 'Laser', 'ICSI'
, transfer_IVF_assistance               varchar(10)        default ''

-- embryo preservation: either 'fresh' or 'frozen'
, transfer_embryo_preservation          varchar(8)          default ''

-- transgenic manipulation: either 'no manipulation in house', 'knockout (blastocyst injection)', 'transgenic animal (pronucleus injection)'
, transfer_transgenic_manipulation      varchar(50)         default ''

-- background of donor cells: things like 'C57BL/6', '129',....
, transfer_background_donor_cells       varchar(50)         default ''

-- background of ES cells: things like 'C57BL/6', '129',....
, transfer_background_ES_cells          varchar(50)         default ''

-- name of construct used for targeting or transgenic vector
, transfer_name_of_construct            varchar(50)         default ''

-- comment
, transfer_comment                      text                default NULL

, PRIMARY KEY (transfer_id)
) 
ENGINE=InnoDB
;
CREATE INDEX transfer_mating_id          ON embryo_transfers (transfer_mating_id);
CREATE INDEX transfer_embryo_id          ON embryo_transfers (transfer_embryo_id);




DROP TABLE IF EXISTS litters;
CREATE TABLE litters (
-- one mating can have one to many litters

-- primary key: serial litter id
  litter_id                        int                NOT NULL

-- foreign key (-> table "matings"): id of mating, to which litters belong
, litter_mating_id                 int                NOT NULL

-- litter order (i.e: "1st litter of mating 1234", "2nd litter of mating 1234", ...)
, litter_in_mating                 int                NOT NULL

-- date of birth of litter
, litter_born_datetime             datetime           default NULL

-- number of total pups alive 
, litter_alive_total               int                default NULL

-- number of male pups alive  
, litter_alive_male                int                default NULL

-- number of female pups alive 
, litter_alive_female              int                default NULL  

-- number of male pups alive 
, litter_dead_total                int                default NULL

-- number of male pups dead 
, litter_dead_male                 int                default NULL

-- number of male pups dead  
, litter_dead_female               int                default NULL

-- number of male pups reduced (killed) 
, litter_reduced                   int                default NULL

-- why reduction of pups?
-- (options defined in table "settings")
, litter_reduced_reason            varchar(255)       default NULL

-- date of weaning
, litter_weaning_datetime          datetime           default NULL 

-- comment
, litter_comment                   text               default ''

, PRIMARY KEY (litter_id)
) 
ENGINE=InnoDB
;
CREATE INDEX litter_mating_id          ON litters (litter_mating_id);
CREATE INDEX litter_in_mating          on litters (litter_in_mating);
CREATE INDEX litter_born_datetime      ON litters (litter_born_datetime);
CREATE INDEX litter_weaning_datetime   ON litters (litter_weaning_datetime);



DROP TABLE IF EXISTS parents2matings;
CREATE TABLE parents2matings (
-- cross table: "mice" <-> "matings"
--
-- connection between mice (parents) and matings. One mating may contain 1-n females and
-- theoretically even 1-n males. 
--
-- this table contains the potential parents of litter coming from a mating

-- foreign key (-> table "matings"): mating id, in which mouse is parent
  p2m_mating_id                        int                NOT NULL

-- foreign key (-> table "mice"): ID of parent mouse
, p2m_parent_id                        int                NOT NULL
  
-- parentship role (i.e. fa=father, mo=mother, fo=foster mother, od=oocyte donor, ...)
-- (options defined in "settings")
, p2m_parent_type                      varchar(20)        NOT NULL

-- datetime when parent entered the mating
, p2m_parent_start_date                datetime           default NULL

-- datetime when parent left the mating (i.e. by death, separation, ...)
, p2m_parent_end_date                  datetime           default NULL  

, PRIMARY KEY                         (p2m_mating_id, p2m_parent_id)
)
ENGINE=InnoDB
;
CREATE INDEX p2m_parent_id    ON parents2matings (p2m_parent_id);
CREATE INDEX p2m_parent_type  ON parents2matings (p2m_parent_type);



DROP TABLE IF EXISTS litters2parents;
CREATE TABLE litters2parents (
-- cross table: "litters" <-> "mice"
--
-- entries here define the real parents of litter mice. It must always be equal or a subset
-- the accordant entries in table "parents2matings".

-- foreign key (-> table "litters"): litter id
  l2p_litter_id                        int                NOT NULL

-- foreign key (-> table "mice"): ID of parent mouse
, l2p_parent_id                        int                NOT NULL

-- parentship role (fa=father, mo=mother, fo=foster mother, od=oocyte donor, ...)
-- (options defined in "settings")
, l2p_parent_type                      varchar(20)        NOT NULL

-- parentship evidence (z.B. (p)ossible, (s)ure)
-- (options defined in "settings")
, l2p_evidence                         char(1)            NOT NULL

, PRIMARY KEY                         (l2p_litter_id, l2p_parent_id)
) 
ENGINE=InnoDB
;
CREATE INDEX l2p_parent_id    ON litters2parents (l2p_parent_id);
CREATE INDEX l2p_parent_type  ON litters2parents (l2p_parent_type);




DROP TABLE IF EXISTS imports;
CREATE TABLE imports (
-- every import has an entry here

-- primary key: serial import id
  import_id                          int                 NOT NULL

-- different import can be grouped by having identical entry here 
, import_group                       int                 NOT NULL
  
-- arbitrary name of import (set by user)
, import_name                        varchar(255)        NOT NULL

-- import type: 'regular', 'embryotransfer', ...
-- (options defined in table "settings")
, import_type                        varchar(20)         NOT NULL

-- foreign key (-> table "mouse_strains"): genetic background, i.e. "Balb/c", "129", "C57BL/6", ...
, import_strain                      int                 NOT NULL

-- foreign key (-> table "mouse_lines"): line
, import_line                        int                 NOT NULL

-- import datetime
, import_datetime                    datetime            default NULL

-- name of person, who has intellectual property on imported mice (set by user)
, import_owner_name                  varchar(255)        NOT NULL

-- name of person, who sent the mice (set by user via user interface)
, import_provider_name               varchar(255)        NOT NULL

-- same as above, but referenced to table "contacts" (set by admin)
, import_provider_contact            int                 default NULL

-- foreign key (-> table "users"):  responsible person within mouse house, caretaker
, import_coach_user                  int                 default NULL

-- why this import?
-- (options defined in table "settings")
, import_purpose                      varchar(255)       default NULL

-- origin of import: TEP Code (only important for GSF internal regulations and policies)
, import_origin_code                  varchar(20)        default NULL

-- foreign key (-> table "locations"): origin of an import, if it comes from a location listed in table "locations"
, import_origin_location              int                default NULL

-- foreign key (-> table "projects"): assigned project
, import_project                      int                NOT NULL

-- import checkcode used to prevent re-importing mice by accidentally pressing
-- browser reload button
-- it is a simple timestamp "yyyy-mm-dd hh:mm:ss"
, import_checkcode                    varchar(20)        default NULL

-- foreign key (-> table "healthreports"): import health report
, import_healthreport                 int                default NULL

-- comment
, import_comment                      text               default ''

, PRIMARY KEY (import_id)
)
ENGINE=InnoDB
;
CREATE INDEX import_group             ON imports (import_group);
CREATE INDEX import_type              ON imports (import_type);
CREATE INDEX import_strain            ON imports (import_strain);
CREATE INDEX import_line              ON imports (import_line);
CREATE INDEX import_datetime          ON imports (import_datetime);
CREATE INDEX import_provider_contact  ON imports (import_provider_contact);
CREATE INDEX import_coach_user        ON imports (import_coach_user);
CREATE INDEX import_purpose           ON imports (import_purpose);
CREATE INDEX import_origin_code       ON imports (import_origin_code);
CREATE INDEX import_project           ON imports (import_project);
CREATE INDEX import_checkcode         ON imports (import_checkcode);
CREATE INDEX import_healthreport      ON imports (import_healthreport);
CREATE INDEX import_origin_location   ON imports (import_origin_location);



DROP TABLE IF EXISTS imports2contacts;
CREATE TABLE imports2contacts (
-- cross table: "imports" <-> "contacts" 

-- foreign key (-> table "imports"): import ID
  i2c_import_id                       int                         NOT NULL

-- foreign key (-> table "contacts"): contact ID  
, i2c_contact_id                      int                         NOT NULL

, PRIMARY KEY (i2c_import_id, i2c_contact_id)
)
ENGINE=InnoDB
;
CREATE INDEX i2c_contact_id ON imports2contacts (i2c_contact_id);




DROP TABLE IF EXISTS mice;
CREATE TABLE mice (
-- every mouse has an entry here

-- primary key: serial mouse id
  mouse_id                             int                        NOT NULL

-- individual mouse tag or marking, i.e. eartag, toe number, transponder id, ...
, mouse_earmark                        varchar(10)                default ''

-- origin of mouse: i.e. "import", "weaning", "external"
-- (options defined in table "settings")
, mouse_origin_type                    varchar(16)                NOT NULL

-- foreign key (-> table "litters"): if mouse comes from a weaning, litter id; else NULL
, mouse_litter_id                      int                        default 0
   
-- foreign key (-> table "imports"): if mouse comes from an import, import id; else NULL
, mouse_import_id                      int                        default 0
   
-- (currently not used)
, mouse_import_litter_group            int                        default NULL

-- sex: (m)ale, (f)emale, (n)/d      
, mouse_sex                            char(1)                    NOT NULL

-- foreign key (-> table "mouse_strains"): genetic background, i.e. "Balb/c", "129", "C57BL/6", ...
, mouse_strain                         int                        NOT NULL

-- foreign key (-> table "mouse_lines"): line
, mouse_line                           int                        NOT NULL

-- generation code: (F1, G2, R3, ...)
-- at weaning time, this is filled from corresponding field in "mating"
, mouse_generation                     varchar(20)                default NULL

-- (currently not used)
, mouse_batch                          varchar(2)                 default NULL
  
-- foreign key (-> table "mouse_coat_colors"): coat color
, mouse_coat_color                     int                        NOT NULL

-- datetime of birth
-- since an import may contain mice of different age, date of birth is part of table "mice"
, mouse_birth_datetime                datetime                    default NULL

-- datetime of death or export
-- death or export are both considered equal
, mouse_deathorexport_datetime        datetime                    default NULL

-- foreign key (-> table "death_reasons"): how reason (ie. "killed", "found dead", "exported", ...)
, mouse_deathorexport_how             int                         NOT NULL

-- foreign key (-> table "death_reasons"): why reason (ie. "ill", "died in experiment", "excess", ...)
, mouse_deathorexport_why             int                         NOT NULL

-- foreign key (-> table "contacts"): in case of export, who received the mouse?
, mouse_deathorexport_contact         int                         default NULL

-- foreign key (-> table "locations"): in case of export, where is the mouse now?
, mouse_deathorexport_location        int                         default NULL

-- is it a genetically modified organism according to German law?
, mouse_is_gvo                        char(1)                     default NULL

-- is mouse mutant or not?
, mouse_is_mutant                     char(1)                     default NULL

-- comment
, mouse_comment                       text                        default ''

, PRIMARY KEY (mouse_id)
)
ENGINE=InnoDB
;
CREATE INDEX mouse_origin_type             ON mice (mouse_origin_type);
CREATE INDEX mouse_litter_id               ON mice (mouse_litter_id);
CREATE INDEX mouse_import_id               ON mice (mouse_import_id);
CREATE INDEX mouse_sex                     ON mice (mouse_sex);
CREATE INDEX mouse_strain                  ON mice (mouse_strain);
CREATE INDEX mouse_line                    ON mice (mouse_line);
CREATE INDEX mouse_generation              ON mice (mouse_generation);
CREATE INDEX mouse_coat_color              ON mice (mouse_coat_color);
CREATE INDEX mouse_birth_datetime          ON mice (mouse_birth_datetime);
CREATE INDEX mouse_deathorexport_datetime  ON mice (mouse_deathorexport_datetime);
CREATE INDEX mouse_deathorexport_how       ON mice (mouse_deathorexport_how);
CREATE INDEX mouse_deathorexport_why       ON mice (mouse_deathorexport_why);
CREATE INDEX mouse_deathorexport_contact   ON mice (mouse_deathorexport_contact);
CREATE INDEX mouse_deathorexport_location  ON mice (mouse_deathorexport_location);
CREATE INDEX mouse_is_gvo                  ON mice (mouse_is_gvo);




DROP TABLE IF EXISTS mousegroups;
CREATE TABLE mousegroups (
-- mice can be grouped into mouse groups
-- obsolete: same can be done better by storing carts
-- this table is currently not used

-- primary key: serial mousegroup id
  mousegroup_id                        int                         NOT NULL
  
-- arbitrary name of mouse group (set by user)
, mousegroup_name                      varchar(255)                NOT NULL

-- purpose (options may be defined in table "settings")
, mousegroup_purpose                   varchar(15)                 NOT NULL

-- show the group? (y)es, (n)o
, mousegroup_show                      char(1)                     NOT NULL

-- description
, mousegroup_description               text                        default ''

-- foreign key (-> table "users"): who generated the mouse group?
, mousegroup_user                      int                         NOT NULL

-- datetime when group was generated  
, mousegroup_datetime                  datetime                    NOT NULL

, PRIMARY KEY (mousegroup_id)
)
ENGINE=InnoDB
;
CREATE INDEX mousegroup_user    ON mousegroups (mousegroup_user);
CREATE INDEX mousegroup_purpose ON mousegroups (mousegroup_purpose);



DROP TABLE IF EXISTS mice2mousegroups;
CREATE TABLE mice2mousegroups (
-- cross table: "mice" <-> "mousegroups"
-- currently not used

-- foreign key (-> table "mice"): mouse ID
  m2m_mouse_id                        int                        NOT NULL

-- foreign key (-> table "mousegroups"): mousegroup ID  
, m2m_mousegroup_id                   int                        NOT NULL

-- when was this mouse added to the group?
, m2m_added_datetime                  datetime                   default NULL

, PRIMARY KEY (m2m_mouse_id, m2m_mousegroup_id)
)
ENGINE=InnoDB
;
CREATE INDEX m2m_mousegroup_id ON mice2mousegroups (m2m_mousegroup_id);



DROP TABLE IF EXISTS cohorts;
CREATE TABLE cohorts (
-- mice can belong to cohorts, which are defined here

-- primary key: serial cohort id
  cohort_id                        int                         NOT NULL

-- arbitrary name of cohort (set by user)
, cohort_name                      varchar(255)                NOT NULL

-- purpose (options may be defined in table "settings")
, cohort_purpose                   varchar(15)                 NOT NULL

-- cohort pipeline (only relevant for EUMODIC)
, cohort_pipeline                  int                         NOT NULL

-- description
, cohort_description               text                        default ''

-- cohort_status: used to state if a cohort has been processed
, cohort_status                    varchar(20)                 default NULL

-- datetime when group was generated
, cohort_datetime                  datetime                    NOT NULL

-- cohort type: mutant or control
, cohort_type                      varchar(255)                default NULL

-- reference cohort: points to the reference cohort (assigned by user)
, cohort_reference_cohort          int                         default NULL

, PRIMARY KEY (cohort_id)
)
ENGINE=InnoDB
;
CREATE INDEX cohort_pipeline ON cohorts (cohort_pipeline);
CREATE INDEX cohort_type     ON cohorts (cohort_type);



DROP TABLE IF EXISTS mice2cohorts;
CREATE TABLE mice2cohorts (
-- cross table: "mice" <-> "cohorts"

-- foreign key (-> table "mice"): mouse ID
  m2co_mouse_id                       int                     NOT NULL

-- foreign key (-> table "cohorts"): cohort ID
, m2co_cohort_id                   int                        NOT NULL

, PRIMARY KEY (m2co_mouse_id, m2co_cohort_id)
)
ENGINE=InnoDB
;
CREATE INDEX m2co_cohort_id ON mice2cohorts (m2co_cohort_id);



DROP TABLE IF EXISTS genes;
CREATE TABLE genes (
-- every gene or locus has an entry here.
-- non-mapped phenotypes are treated like "genes" for simplicity

-- primary key: serial gene id
  gene_id                          int                         NOT NULL
  
-- gene name, preferrably according to "official" nomenclature
, gene_name                        varchar(255)                NOT NULL

-- short gene name
, gene_shortname                   varchar(25)                  NOT NULL

-- description
, gene_description                 text                        default ''

-- valid genotype qualifiers, separated by semicolon (eg: '+/-;+/+;-/-')
, gene_valid_qualifiers            text                        default ''

, PRIMARY KEY (gene_id)
)
ENGINE=InnoDB
;
CREATE INDEX gene_name ON genes (gene_name);



DROP TABLE IF EXISTS mice2genes;
CREATE TABLE mice2genes (
-- cross table: "mice" <-> "genes"
--
-- one mouse can have one to many genotypes for different "genes"

-- foreign key (-> table "mice"): mouse ID
  m2g_mouse_id                        int                         NOT NULL

-- foreign key (-> table "genes"): gene ID  
, m2g_gene_id                         int                         NOT NULL

-- genotype order: 1=>first genotype, ....
-- overviews only select for m2g_gene_order = 1 (primary genotype)
, m2g_gene_order                      int                         NOT NULL

-- date of genotyping/phenotyping
, m2g_genotype_date                   date                        default NULL

-- the genotype/phenotype itself: i.e. 'ukn', 'wt', '+/+', '+/-', '-/-', '+/0', '-/0'
-- (options defined in table "settings")
, m2g_genotype                        varchar(30)                 default 'unknown'

-- genotyping method: i.e. 'PCR','phenotype'
, m2g_genotype_method                 varchar(20)                 default 'PCR'  

, PRIMARY KEY (m2g_mouse_id, m2g_gene_id, m2g_genotype)
)
ENGINE=InnoDB
;
CREATE INDEX m2g_gene_id  ON mice2genes (m2g_gene_id);
CREATE INDEX m2g_genotype ON mice2genes (m2g_genotype);



DROP TABLE IF EXISTS genes2externalDBs;
CREATE TABLE genes2externalDBs (
-- cross table: "genes" <-> "externalDBs"
--
-- allows linking of entries in table "genes" to external ressources,
-- such as Ensembl, LocusLink, OMIM, ...

-- foreign key (-> table "genes"): gene id
  g2e_gene_id                        int                         NOT NULL

-- foreign key (-> table "externalDBs): ID of external database in table "externalDBs"
, g2e_externalDB_id                  int                         NOT NULL

-- link description, for example "ensembl gene"
, g2e_description                    varchar(255)                default ''

-- foreign key: gene id in external database, i.e. Ensembl-ID, PubMed-ID, OMIM-ID, ...
, g2e_id_in_externalDB               varchar(255)                default ''

-- URL of direct link to specific entry in external database
, g2e_externalDB_URL                 varchar(255)                default NULL

-- URL of a local link, i.e. PDF file
, g2e_local_URL                      varchar(255)                default NULL

, PRIMARY KEY (g2e_gene_id, g2e_externalDB_id, g2e_id_in_externalDB)
)
ENGINE=InnoDB
;
CREATE INDEX g2e_externalDB_id     ON genes2externalDBs (g2e_externalDB_id);
CREATE INDEX g2e_id_in_externalDB  ON genes2externalDBs (g2e_id_in_externalDB);



DROP TABLE IF EXISTS mice2phenotypesDB;
CREATE TABLE mice2phenotypesDB (
-- cross table: "mice" <-> "externalDBs"
--
-- allows linking of mice to external phenotype databases 

-- foreign key (-> table "mice"): mouse_id
  m2p_mouse_id                        int                         NOT NULL

-- foreign key (-> table "externalDBs): ID of external database in table "externalDBs"
, m2p_externalDB_id                   int                         NOT NULL

-- ID of phenotype in external phenotype database
, m2p_phenotypeID_in_externalDB       varchar(30)                 default ''

-- URL of direct link to specific entry in external database
, m2p_externalDB_URL                  varchar(255)                default NULL

-- URL of a local link, i.e. PDF file
, m2p_local_URL                       varchar(255)                default NULL

, PRIMARY KEY (m2p_mouse_id, m2p_externalDB_id, m2p_phenotypeID_in_externalDB)
)
ENGINE=InnoDB
;
CREATE INDEX m2p_phenotypeID_in_externalDB ON mice2phenotypesDB (m2p_phenotypeID_in_externalDB);
CREATE INDEX m2p_externalDB_id             ON mice2phenotypesDB (m2p_externalDB_id);




DROP TABLE IF EXISTS externalDBs;
CREATE TABLE externalDBs (
-- every external database ressource has an entry here
-- i.e. Ensembl, Genebank, OMIM, PubMed, GO, usw.

-- primary key: serial id
  externalDB_id                        int                         NOT NULL
  
-- Name of external database
, externalDB_name                      varchar(50)                 default ''

-- URL of homepage of external database
, externalDB_home_URL                  varchar(255)                default ''

-- URL of query-Link of external database
-- i.e. http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=<ID>,
-- where <ID> will be replaced by real id
, externalDB_query_URL                 varchar(255)                default ''

, PRIMARY KEY                         (externalDB_id)
)
ENGINE=InnoDB
;




DROP TABLE IF EXISTS workflows;
CREATE TABLE workflows (
-- workflows are defined here
-- a workflow is a template for a series of parametersets to be measured 
-- at defined time points refering to a reference date

-- primary key: serial id
  workflow_id                          int                         NOT NULL

-- name of workflow
, workflow_name                        varchar(255)                default ''

-- description of workflow
, workflow_description                 text                        default ''
  
-- is workflow active?
, workflow_is_active                   char(1)                     default 'y'

, PRIMARY KEY                         (workflow_id)
)
ENGINE=InnoDB
;
CREATE INDEX workflow_name      ON workflows (workflow_name);
CREATE INDEX workflow_is_active ON workflows (workflow_is_active);




DROP TABLE IF EXISTS workflows2parametersets;
CREATE TABLE workflows2parametersets (
-- cross table: "workflows" <-> "parametersets"

-- assigns a parameterset to a workflow and defines measure timepoint in relation to reference date

-- foreign key (-> table "workflows"): workflow ID
  w2p_workflow_id                    int                        NOT NULL
  
-- foreign key (-> table "parametersets"): parameterset_id
, w2p_parameterset_id                int                        NOT NULL

-- distance to reference date in days
, w2p_days_from_ref_date             int                        NOT NULL

, PRIMARY KEY                        (w2p_workflow_id, w2p_parameterset_id, w2p_days_from_ref_date)
)
ENGINE=InnoDB
;
CREATE INDEX w2p_parameterset_id ON workflows2parametersets (w2p_parameterset_id);




DROP TABLE IF EXISTS mouse_lines;
CREATE TABLE mouse_lines (
-- every mouse line has an entry here

-- primary key: serial mouse line id
  line_id                          int                         NOT NULL
  
-- short name of mouse line
, line_name                        varchar(50)                 NOT NULL

-- long name of mouse line 
-- (jaja, I know this varchar(50) looks funny ...)
, line_long_name                   varchar(50)                 NOT NULL

-- just a sort field ...
, line_order                       int                         default NULL

-- mouse line visible in popup menus? [y/n]
, line_show                        char(1)                     default 'y'

-- URL to line description
, line_info_URL                    varchar(255)                default ''

-- comment
, line_comment                 text                        default ''

, PRIMARY KEY                      (line_id)
)
ENGINE=InnoDB
;




DROP TABLE IF EXISTS projects;
CREATE TABLE projects (
-- every project has an entry here

-- primary key: serial project id 
  project_id                          int                         NOT NULL

-- project name
, project_name                        varchar(50)                 NOT NULL

-- project short name
, project_shortname                   varchar(10)                 NOT NULL

-- project description
, project_description                 text                        default ''

-- foreign key (-> table "projects"): links to parent project
, project_parent_project              int                         default NULL

-- foreign key (-> table "users"): project owner
, project_owner                       int                         NOT NULL

, PRIMARY KEY (project_id)
)
ENGINE=InnoDB
;
CREATE INDEX project_shortname      ON projects (project_shortname);
CREATE INDEX project_parent_project ON projects (project_parent_project);
CREATE INDEX project_owner          ON projects (project_owner);



DROP TABLE IF EXISTS healthreports;
CREATE TABLE healthreports (
-- every health report has an entry here

-- primary key: serial health report id
  healthreport_id                  int                         NOT NULL

-- path to healthreport document
, healthreport_document_URL        varchar(255)                NOT NULL

-- date of health report
, healthreport_date                date                        NOT NULL 

-- time period to which health report refers (i.e. life span of a sentinel mouse)
, healthreport_valid_from_date     date                        NOT NULL
, healthreport_valid_to_date       date                        NOT NULL  

-- 'ok' or 'not ok'
, healthreport_status              varchar(20)                default NULL

-- comment
, healthreport_comment             text                       default ''

-- number of mice used for health_screening
, healthreport_number_of_mice      int                        default NULL

-- list of mice used for health_screening
,  healthreport_mice               text                       default ''

, PRIMARY KEY                      (healthreport_id)
)
ENGINE=InnoDB
;
CREATE INDEX healthreport_valid_from_date ON healthreports (healthreport_valid_from_date);
CREATE INDEX healthreport_valid_to_date   ON healthreports (healthreport_valid_to_date);
CREATE INDEX healthreport_status          ON healthreports (healthreport_status);



DROP TABLE IF EXISTS healthreports2healthreport_agents;
CREATE TABLE healthreports2healthreport_agents (
-- cross table: "healthreports" <-> "healthreport_agents"

-- foreign key (-> table "healthreports"): healthreport ID
  hr2ha_health_report_id                  int                        NOT NULL

-- foreign key (-> table "healthreport_agents"):  healthreport_agent_id
, hr2ha_healthreport_agent_id             int                        NOT NULL

-- number of animals for which agent was found
, hr2ha_number_of_positive_animals        int                        NOT NULL

, PRIMARY KEY                        (hr2ha_health_report_id, hr2ha_healthreport_agent_id)
)
ENGINE=InnoDB
;
CREATE INDEX hr2ha_healthreport_agent_id ON healthreports2healthreport_agents (hr2ha_healthreport_agent_id);



DROP TABLE IF EXISTS mice2healthreports;
CREATE TABLE mice2healthreports (
-- cross table: "mice" <-> "healthreports"

-- foreign key (-> table "mice"): mouse ID
  m2h_mouse_id                        int                        NOT NULL

-- foreign key (-> table "healthreports"):  healthreport_id 
, m2h_healthreport_id                 int                        NOT NULL

-- evidence of health report to the current mouse
-- "original":  mouse examined
-- "batchmate": mouse cagemate of examined mouse
-- "derived":   mouse candidate for infection
-- (options defined in table "settings")
, m2h_evidence_type                   varchar(10)                NOT NULL

, PRIMARY KEY                        (m2h_mouse_id, m2h_healthreport_id)
)
ENGINE=InnoDB
;
CREATE INDEX m2h_healthreport_id ON mice2healthreports (m2h_healthreport_id);
CREATE INDEX m2h_evidence_type   ON mice2healthreports (m2h_evidence_type);


DROP TABLE IF EXISTS locations2healthreports;
CREATE TABLE locations2healthreports (
-- cross table: "locations" <-> "healthreports"

-- foreign key (-> table "locations"): location ID
  l2h_location_id                     int                        NOT NULL

-- foreign key (-> table "healthreports"):  healthreport_id 
, l2h_healthreport_id                 int                        NOT NULL

, PRIMARY KEY                        (l2h_location_id, l2h_healthreport_id)
)
ENGINE=InnoDB
;
CREATE INDEX l2h_healthreport_id ON locations2healthreports (l2h_healthreport_id);


DROP TABLE IF EXISTS healthreport_agents;
CREATE TABLE healthreport_agents (
-- every healthreport_agent (virus, bacterium, parasit) has an entry here

-- primary key: serial agent id
  agent_id                          int                         NOT NULL

-- agent type (virus, bacterium, parasit)
, agent_type                        varchar(20)                 NOT NULL

-- agent name, i.e.: "mouse hepatitis virus"
, agent_name                        varchar(50)                 NOT NULL

-- display order
, agent_display_order               int                         default NULL
-- agent short name, i.e.: "MHV"
, agent_shortname                   varchar(20)                 NOT NULL

-- agent comment
, agent_comment                     text                        default ''

, PRIMARY KEY (agent_id)
)
ENGINE=InnoDB
;
CREATE INDEX agent_type       ON healthreport_agents (agent_type);
CREATE INDEX agent_name       ON healthreport_agents (agent_name);
CREATE INDEX agent_shortname  ON healthreport_agents (agent_shortname);


DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts (
-- contacts are natural persons or institutions

-- primary key: serial contact id
  contact_id                         int                            NOT NULL
  
-- internal contact (y)es/(n)o ?
, contact_is_internal                char(1)                        NOT NULL

-- academic title
-- (options defined in table "settings")
, contact_title                      varchar(20)                    default NULL

-- contact type: (n)atural person oder (j) institution
, contact_type                       char(1)                        default 'n'

-- function: "scientist", "caretaker", ...
-- (options defined in table "settings")
, contact_function                   varchar(100)                   default NULL

-- self-explanatory
, contact_first_name                 varchar(255)                   NOT NULL
, contact_last_name                  varchar(255)                   NOT NULL

-- sex: (m)ale, (f)emale, (u)nknown
, contact_sex                        char(1)                        default NULL

-- e-mail - addresse(n)
, contact_emails                     varchar(255)                   default ''

-- comment
, contact_comment                    text                           default ''

, PRIMARY KEY                        (contact_id)
)
ENGINE=InnoDB
;
CREATE INDEX contact_is_internal ON contacts (contact_is_internal);




DROP TABLE IF EXISTS users;
CREATE TABLE users (
-- every user has an entry here, that is a MausDB account
-- a contact can be linked to many users, a user can be linked to only one contact

-- primary key: serial user id
  user_id                          int                         NOT NULL

-- user name (Unix-like, no special characters)
, user_name                        varchar(20)                 NOT NULL

-- foreign key (-> table "contacts"): which contact (person)
, user_contact                     int                         NOT NULL

-- password, stored as MD5 hash
, user_password                    varchar(255)                default 'password'

-- state of user account: 'active', 'inactive'
, user_status                      varchar(10)                 default NULL

-- user roles: 'u' = normal user, 'a' = admin
, user_roles                       char(5)                     default 'u'

-- comment
, user_comment                     text                        default ''

, PRIMARY KEY (user_id)
)
ENGINE=InnoDB
;
CREATE INDEX user_name     ON users (user_name);
CREATE INDEX user_password ON users (user_password);
CREATE INDEX user_contact  ON users (user_contact);
CREATE INDEX user_status   ON users (user_status);



DROP TABLE IF EXISTS medical_records;
CREATE TABLE medical_records (
-- medical records: phenotyping data
-- every single phenotyping record has an entry here

-- primary key: serial medical record id
  mr_id                                        int                                NOT NULL
  
-- group id: medical records can be grouped by having the same group id
-- rule: all medical records of a group (criteria: one mouse, one parameterset, one upload timepoint) have the same group id
, mr_parent_mr_group                           int                                NOT NULL

-- tupel id: all n-tupel pairs of medical records having the same tupel id build a (x,y) - tupel or even an (x,y,z)-tupel,...
-- using this feature, it is possible to store for example concentration vs time - value pairs
-- (currently not used)
, mr_tupel_id                                  int                                NOT NULL

-- for tupel-values: is current record dependent ('y'/'n')?
-- (currently not used)
, mr_is_dependent                              char(1)                            NOT NULL

-- for serial parameters: value of increment -> "10", "20" or "stimulated", "non-stimulated"
, mr_increment_value                           varchar(20)                        default NULL

-- for serial parameters: unit of increment -> "min"
, mr_increment_unit                            varchar(20)                        default NULL

-- for a series of measurements: order of vales
-- (currently not used)
, mr_serial_order                              int                                NOT NULL

-- for paired values: category "infected"<-> "non-infected"
-- (currently not used)
, mr_category                                  varchar(255)                       default NULL

-- foreign key (-> table "projects"): project assignment
-- this key is used to determine viewing right together with column "mr_is_public"
, mr_project_id                                int                                NOT NULL

-- foreign key (-> table "orderlists"): record based on which orderlist
-- NULL: "spontaneously measured", not based on a phenotyping order   
, mr_orderlist_id                              int                                NULL

-- foreign key (-> table "parametersets"): to which parameterset does the record belong
-- this is important in cases where a general parameter (ie. weight) is part of different parametersets
-- and in case no orderlist is defined (not practised)
, mr_parameterset_id                           int                                NULL

-- foreign key (-> table "parameters"): which parameter?
, mr_parameter                                 int                                NOT NULL

-- -------------------------------------
-- the actual values
-- integers
, mr_integer                                   int                                default NULL

-- float
, mr_float                                     float                              default NULL

-- boolean values: 'y'/'n'
, mr_bool                                      char(1)                            default NULL

-- test
, mr_text                                      longtext                           default ''

-- foreign key (-> table "blob-data"): refers to blob in separate table containg raw file
-- ie. Excel-files, images, ...
, mr_source_id                                 int                                default NULL

-- foreign key (-> table "blob-data"): refers to blob in separate table
-- (difference to above mr_source_id is not well defined currently)
, mr_blob_id                                   int                                default NULL
-- -------------------------------------

-- foreign key (-> table "users"): who was responsible for the experiment?
, mr_responsible_user                          int                                NOT NULL

-- foreign key (-> table "users"): who performed the experiment?
, mr_measure_user                              int                                NOT NULL

-- is this medical record public? (See comment on above mr_project_id)
, mr_is_public                                 char(1)                            NOT NULL

-- quality information of medical records: ie. 'ok', 'invalid', ...
-- (options defined in "settings")
, mr_quality                                    varchar(20)                       default 'ok'

-- is the value outside the normal/expected range?(y)es/(n)o (flag set by user)
, mr_is_outside_normal_range                   char(1)                            default NULL

-- datetime of probe taking (important for example for blood samples)
, mr_probetaken_datetime                       datetime                           default NULL

-- datetime of measurement
, mr_measure_datetime                          datetime                           default NULL

-- status of medical_record: "new", "uploaded", "validated"...
, mr_status                                    varchar(20)                        default NULL

-- comment
, mr_comment                                   varchar(255)                       default NULL

, PRIMARY KEY (mr_id)
)
ENGINE=InnoDB
;
CREATE INDEX mr_parent_mr_group         ON medical_records (mr_parent_mr_group);
CREATE INDEX mr_tupel_id                ON medical_records (mr_tupel_id);
CREATE INDEX mr_is_dependent            ON medical_records (mr_is_dependent);
CREATE INDEX mr_serial_order            ON medical_records (mr_serial_order);
CREATE INDEX mr_category                ON medical_records (mr_category);
CREATE INDEX mr_project_id              ON medical_records (mr_project_id);
CREATE INDEX mr_orderlist_id            ON medical_records (mr_orderlist_id);
CREATE INDEX mr_parameterset_id         ON medical_records (mr_parameterset_id);
CREATE INDEX mr_parameter               ON medical_records (mr_parameter);
CREATE INDEX mr_integer                 ON medical_records (mr_integer);
CREATE INDEX mr_float                   ON medical_records (mr_float);
CREATE INDEX mr_bool                    ON medical_records (mr_bool);
CREATE INDEX mr_text                    ON medical_records (mr_text(30));
CREATE INDEX mr_source_id               ON medical_records (mr_source_id);
CREATE INDEX mr_blob_id                 ON medical_records (mr_blob_id);
CREATE INDEX mr_responsible_user        ON medical_records (mr_responsible_user);
CREATE INDEX mr_measure_user            ON medical_records (mr_measure_user);
CREATE INDEX mr_is_public               ON medical_records (mr_is_public);
CREATE INDEX mr_quality                 ON medical_records (mr_quality);
CREATE INDEX mr_is_outside_normal_range ON medical_records (mr_is_outside_normal_range);
CREATE INDEX mr_comment                 ON medical_records (mr_comment);
CREATE INDEX mr_status                  ON medical_records (mr_status);


DROP TABLE IF EXISTS medical_records2sops;
CREATE TABLE medical_records2sops (
-- cross table: "medical_records" <-> "sops"
--
-- one medical record can be linked to several sops

-- foreign key (-> table "medical_records")
  mr2s_mr_id                                 int                        NOT NULL

-- foreign key (-> table "sops")
, mr2s_sop_id                                int                        NOT NULL

, PRIMARY KEY (mr2s_mr_id, mr2s_sop_id)
)
ENGINE=InnoDB
;
CREATE INDEX mr2s_sop_id ON medical_records2sops (mr2s_sop_id);




DROP TABLE IF EXISTS sops;
CREATE TABLE sops (
-- every sop has an entry here

-- primary key: serial sop id
  sop_id                                  int                         NOT NULL

-- name of sop
, sop_name                                varchar(255)                NOT NULL

-- version of SOP
, sop_version                             varchar(255)                default NULL

-- datetime of last update
, sop_last_modified                       datetime                    default NULL

-- URL path to electronic version of sop, i.e. PDF-file
-- (will be replaced by link to "blob-data" table)
, sop_URL                                 varchar(255)                default ''

-- text version of sop
, sop_text                                longtext                    default ''

, PRIMARY KEY                             (sop_id)
)
ENGINE=InnoDB
;
CREATE INDEX sop_name     ON sops (sop_name);
CREATE INDEX sop_version  ON sops (sop_version);




DROP TABLE IF EXISTS experiments;
CREATE TABLE experiments (
-- every experiment (= "Tierversuchsantrag" according to German law) has an entry here

--primary key: serial experiment id
  experiment_id                                int                         NOT NULL
  
-- name/identifier of the experiment/Tierversuchsantrags
, experiment_name                              varchar(255)                NOT NULL

-- file/record number of the experiment/Tierversuchsantrag 
, experiment_recordname                        varchar(255)                default ''

-- URL path to PDF-Version of Tierversuchsantrag
-- (may be replace by link to "blob-data") 
, experiment_URL                               varchar(255)                default ''

-- foreign key (-> table "contacts"): who is responsible in terms of law?
, experiment_granted_to_contact                int                         default NULL

-- period for which licence is granted
, experiment_licence_valid_from                date                        default NULL
, experiment_licence_valid_to                  date                        default NULL

-- how many mice can be "used" in this experiment?
, experiment_animalnumber                      int                         default NULL

-- show this experiment in menu?
, experiment_is_active                         char(1)                     default 'n'

, PRIMARY KEY                                 (experiment_id)
)
ENGINE=InnoDB
;              
CREATE INDEX experiment_granted_to_contact  ON experiments (experiment_granted_to_contact);
CREATE INDEX experiment_licence_valid_from  ON experiments (experiment_licence_valid_from);
CREATE INDEX experiment_licence_valid_to    ON experiments (experiment_licence_valid_to);




DROP TABLE IF EXISTS mice2experiments;
CREATE TABLE mice2experiments (
-- cross table: "mice" <-> "experiments"

-- foreign key (-> table "experiments"): id of experiment/Tierversuchsantrag
  m2e_experiment_id                           int                        NOT NULL

-- foreign key (-> table "mice"): mouse ID
, m2e_mouse_id                                int                        NOT NULL

-- when did the mouse start into experiment?
, m2e_datetime_from                           datetime                   default NULL

-- when did the mouse leave the experiment?
, m2e_datetime_to                             datetime                   default NULL

-- foreign key (-> table 'users'): who made this entry?
, m2e_inserted_by                             int                        default 0

-- timestamp
, m2e_inserted_at                             timestamp

, PRIMARY KEY                                 (m2e_experiment_id, m2e_mouse_id, m2e_datetime_from)
)
ENGINE=InnoDB
;
CREATE INDEX m2e_mouse_id       ON mice2experiments (m2e_mouse_id);
CREATE INDEX m2e_datetime_from  ON mice2experiments (m2e_datetime_from);
CREATE INDEX m2e_datetime_to    ON mice2experiments (m2e_datetime_to);



DROP TABLE IF EXISTS mouse_lines2genes;
CREATE TABLE mouse_lines2genes (
-- cross table: "mouse_lines" <--> "genes"
--
-- every mouse lines may have one or many linked gene loci
-- for example: for a p53-knockout line, p53 may be the locus of interest, which is defined here

-- foreign key (-> table "mouse_lines")
  ml2g_mouse_line_id                      int                         NOT NULL

-- foreign key (-> table "genes")
, ml2g_gene_id                            int                         NOT NULL

-- the order of genes, if more than one gene is assigned to a line
-- 1 is the gene considered most important
-- 2 is next important...
, ml2g_gene_order                         int                         NOT NULL

, PRIMARY KEY                             (ml2g_mouse_line_id, ml2g_gene_id)
)
ENGINE=InnoDB
;
CREATE INDEX ml2g_gene_id    ON mouse_lines2genes (ml2g_gene_id);
CREATE INDEX ml2g_gene_order ON mouse_lines2genes (ml2g_gene_order);



DROP TABLE IF EXISTS mice2projects;
CREATE TABLE mice2projects (
-- cross table: "mice" <--> "projects"
--
-- mice may be assigned to a project for a period of time. 
-- (this table is not used at the moment)

-- foreign key (-> table "mice")
  m2p_mouse_id                            int                         NOT NULL

-- foreign key (-> table "projects")
, m2p_project_id                          int                         NOT NULL

-- period of project assignment
, m2p_date_from                           date                        default NULL
, m2p_date_to                             date                        default NULL

, PRIMARY KEY                             (m2p_mouse_id, m2p_project_id)
)
ENGINE=InnoDB
;
CREATE INDEX m2p_project_id ON mice2projects (m2p_project_id);




DROP TABLE IF EXISTS parametersets;
CREATE TABLE parametersets (
-- every parameterset has an entry here
-- a parameterset is a collection of single parameters to be measured together
-- for example: SHIRPA 

-- primary key: serial parameterset id
  parameterset_id                          int                         NOT NULL auto_increment

-- name of parameterset
, parameterset_name                        varchar(255)                NOT NULL

-- description of parameterset
, parameterset_description                 text                        default ''

-- foreign key (-> table "projects"): project assignment
, parameterset_project_id                  int                         NOT NULL

-- category: primary screen, secondary screen, ...
, parameterset_class                       int                         NOT NULL

-- just a sort field for display
, parameterset_display_order               int                         NOT NULL

-- parametersets version
, parameterset_version                     varchar(255)                NOT NULL

-- datetime of parametersets creation
, parameterset_version_datetime            datetime                    NOT NULL

-- do not display outdated parametersets
, parameterset_is_active                   char(1)                     default 'y'

, PRIMARY KEY                              (parameterset_id)
)
ENGINE=InnoDB
;
CREATE INDEX parameterset_name          ON parametersets (parameterset_name);
CREATE INDEX parameterset_project_id    ON parametersets (parameterset_project_id);
CREATE INDEX parameterset_class         ON parametersets (parameterset_class);
CREATE INDEX parameterset_display_order ON parametersets (parameterset_display_order);
CREATE INDEX parameterset_is_active     ON parametersets (parameterset_is_active);


DROP TABLE IF EXISTS parametersets2parameters;
CREATE TABLE parametersets2parameters (
-- cross table: "parametersets" <--> "parameters"
--
-- group single parameters into parametersets

-- foreign key (-> table "parametersets")
  p2p_parameterset_id                     int                        NOT NULL
  
-- foreign key (-> table "parameters")
, p2p_parameter_id                        int                        NOT NULL

-- display row of the parameter within the current parameterset
-- (be able to place input field for parameter at a certain position for interactive entry in web form)
, p2p_display_row                         int                        default 0

-- display column of the parameter within the current parameterset
-- (be able to place input field for parameter at a certain position for interactive entry in web form)
, p2p_display_column                      int                        default 0

-- upload column: determines the Excel column, from which data is read upon upload
, p2p_upload_column                       int                        not null

-- p2p_upload_column_name: name of the Excel column, from which data is read upon upload
, p2p_upload_column_name                  varchar(100)               default NULL

-- states if parameter is "simple" or "series"
, p2p_parameter_category                  varchar(20)                default 'simple'

-- used to map the increment value contained in this column to the according column in medical_records
, p2p_increment_value                     varchar(20)                default 'simple'

-- used to map the increment unit contained in this column to the according column in medical_records (stored multiple times here for simplicity)
, p2p_increment_unit                      varchar(20)                default NULL

-- is the parameter strictly required in this parameterset?
, p2p_parameter_required                  char(1)                    default 'y'

, PRIMARY KEY (p2p_parameterset_id, p2p_parameter_id, p2p_increment_value)
)
ENGINE=InnoDB
;
CREATE INDEX p2p_parameter_id       ON parametersets2parameters (p2p_parameter_id);
CREATE INDEX p2p_display_row        ON parametersets2parameters (p2p_display_row);
CREATE INDEX p2p_display_column     ON parametersets2parameters (p2p_display_column);
CREATE INDEX p2p_parameter_category ON parametersets2parameters (p2p_parameter_category);
CREATE INDEX p2p_parameter_required ON parametersets2parameters (p2p_parameter_required);


DROP TABLE IF EXISTS parameters;
CREATE TABLE parameters (
-- every single parameter has an entry here

-- primary key: serial parameter id
  parameter_id                          int                         NOT NULL

-- parameter name
, parameter_name                        varchar(255)                NOT NULL

-- parameter short name
, parameter_shortname                   varchar(20)                 NOT NULL

-- parameter type -> (i)nt, (f)loat, (b)ool, (t)ext, (m)edia
, parameter_type                        char(1)                     NOT NULL

-- decimals
, parameter_decimals                    int                         default NULL

-- physical unit (i.e. N/mm^2)
, parameter_unit                        varchar(255)                default NULL

-- description
, parameter_description                 text                        default ''

-- default value
, parameter_default                     varchar(255)                default NULL

-- comma-separated list of values for popup-menus
, parameter_choose_list                 text                        default ''

-- parameter normal value or range: comma-separated
, parameter_normal_range                varchar(255)                default ''

-- flags if a parameter is considered as metadata
, parameter_is_metadata                 char(1)                     default 'n'

, PRIMARY KEY                          (parameter_id)
)
ENGINE=InnoDB
;
CREATE INDEX parameter_name      ON parameters (parameter_name);
CREATE INDEX parameter_shortname ON parameters (parameter_shortname);
CREATE INDEX parameter_type      ON parameters (parameter_type);



DROP TABLE IF EXISTS settings;
CREATE TABLE settings (
-- general settings table to store any key-value pairs

-- primary key: serial setting id
  setting_id                                 int                         NOT NULL

-- category, i.e. "menu" for key-value pairs of popup menus
, setting_category                           varchar(100)                NOT NULL

-- sub-category
, setting_item                               varchar(100)                NOT NULL

-- key, i.e. "foreign ID"
, setting_key                                varchar(255)                NOT NULL

-- data type -> (i)nt, (f)loat, (b)ool, (t)ext
, setting_value_type                         varchar(10)                 NOT NULL

-- actual value
, setting_value_int                          int                         default NULL
, setting_value_text                         text                        default NULL
, setting_value_bool                         char(1)                     default NULL
, setting_value_float                        float                       default NULL

-- description
, setting_description                        varchar(255)                default NULL

, PRIMARY KEY                                (setting_id)
)
ENGINE=InnoDB
;
CREATE INDEX setting_key       ON settings (setting_key);
CREATE INDEX setting_category  ON settings (setting_category);
CREATE INDEX setting_item      ON settings (setting_item);



DROP TABLE IF EXISTS locations;
CREATE TABLE locations (
-- every location has an entry here
-- 
-- in MausDB, a "location" alway represents a cage rack
-- in general, it could also describe another kind of unit

-- primary key: serial location ID
  location_id                                  int                         NOT NULL
 
-- name of location
, location_name                                varchar(255)                default ''
  
-- location code within GSF-TEP-System (only makes sense in GSF)
, location_code                                varchar(20)                 default ''

-- is it an internal location? (related to the mouse house in which MausDB is used)
, location_is_internal                         char(1)                     NOT NULL

-- foreign key (-> table "addresses"): location address
, location_address                             int                         default NULL

-- building
, location_building                            varchar(255)                default NULL

-- sub-building part
, location_subbuilding                         varchar(255)                default NULL

-- room
, location_room                                varchar(255)                default NULL

-- rack
, location_rack                                varchar(255)                default NULL

-- sub-rack: could be used to allow more granulated location of cages
-- i.e. rack-coordinates: "F7", "left", "front", ...
, location_subrack                             varchar(255)                default NULL

-- max. cage capacity  
, location_capacity                            int                         default NULL

-- is location active?
, location_is_active                           char(1)                     default NULL

-- foreign key (-> table "projects"): project assignment
, location_project                             int                         NOT NULL

-- just a sort field used to influence display order
, location_display_order                       int                         NOT NULL

-- comment
, location_comment                             text                        default ''

, PRIMARY KEY (location_id)
)
ENGINE=InnoDB
;
CREATE INDEX location_name          ON locations (location_name);
CREATE INDEX location_code          ON locations (location_code);
CREATE INDEX location_is_internal   ON locations (location_is_internal);
CREATE INDEX location_address       ON locations (location_address);
CREATE INDEX location_building      ON locations (location_building);
CREATE INDEX location_subbuilding   ON locations (location_subbuilding);
CREATE INDEX location_room          ON locations (location_room);
CREATE INDEX location_rack          ON locations (location_rack);
CREATE INDEX location_subrack       ON locations (location_subrack);
CREATE INDEX location_is_active     ON locations (location_is_active);
CREATE INDEX location_project       ON locations (location_project);
CREATE INDEX location_display_order ON locations (location_display_order);




DROP TABLE IF EXISTS cages;
CREATE TABLE cages (
-- every physical cage has an entry here, so the cage pool is defined here
-- there is also an additional virtual cage (contains all dead mice)

-- primary key: serial cage id
  cage_id                                  int                         NOT NULL

-- name of the cage (not used)
, cage_name                                varchar(255)                default ''

-- is the cage currently occupied?
-- important: the occupancy information stored here is redundant with entries in the "mice2cages" table
-- for reasons of performance and simplicity, it is also stored here
, cage_occupied                            char(1)                     default NULL

-- max. cage capacity
, cage_capacity                            int                         default 5

-- is cage active?
, cage_active                              char(1)                     default NULL

-- cage purpose (not used)
, cage_purpose                             varchar(255)                default NULL
 
-- color for bar on cage card (for custom color codes of users)
, cage_cardcolor                           varchar(10)                 default ''

-- foreign key (-> table "users"): contact person (not used)
, cage_user                                int                         default NULL

-- foreign key (-> table "projects"): project assignment
, cage_project                             int                         default NULL

, PRIMARY KEY                             (cage_id)
)
ENGINE=InnoDB
;
CREATE INDEX cage_occupied ON cages (cage_occupied);
CREATE INDEX cage_active   ON cages (cage_active);
CREATE INDEX cage_purpose  ON cages (cage_purpose);
CREATE INDEX cage_user     ON cages (cage_user);
CREATE INDEX cage_project  ON cages (cage_project);




DROP TABLE IF EXISTS contacts2addresses;
CREATE TABLE contacts2addresses (
-- cross table: "contacts" <-> "addresses"
--
-- contacts may have one to many addresses

-- foreign key (-> table "contacts"): contact ID
  c2a_contact_id                        int                        NOT NULL
  
-- foreign key (-> table "addresses"): address ID
, c2a_address_id                        int                        NOT NULL

, PRIMARY KEY (c2a_contact_id, c2a_address_id)
)
ENGINE=InnoDB
;
CREATE INDEX c2a_address_id ON contacts2addresses (c2a_address_id);




DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses (
-- every address has an entry here

-- primary key: serial address id
  address_id                                int                         NOT NULL
  
-- self-explaining, isn't it?  
, address_institution                       varchar(255)                default NULL
, address_street                            varchar(255)                default NULL
, address_postal_code                       varchar(255)                default NULL
, address_other_info                        varchar(255)                default NULL
, address_city                              varchar(255)                default NULL
, address_state                             varchar(255)                default NULL
, address_country                           varchar(255)                default NULL
, address_telephone                         varchar(255)                default NULL
, address_fax                               varchar(255)                default NULL
, address_unit                              varchar(255)                default NULL
, address_comment                           text                        default NULL
, PRIMARY KEY                               (address_id)
)
ENGINE=InnoDB
;




DROP TABLE IF EXISTS users2projects;
CREATE TABLE users2projects (
-- cross table: "users" <-> "projects"
--
-- users are assigned to projects here

-- foreign key (-> table "users")
  u2p_user_id                                int                        NOT NULL

-- foreign key (-> table "projects")
, u2p_project_id                             int                        NOT NULL

-- user rights: (not used)
, u2p_rights                                 varchar(10)                default 'v'

, PRIMARY KEY (u2p_user_id, u2p_project_id)
)
ENGINE=InnoDB
;
CREATE INDEX u2p_project_id ON users2projects (u2p_project_id);




DROP TABLE IF EXISTS mice2cages;
CREATE TABLE mice2cages (
-- cross table: "mice" <-> "cages"  (mouse->cage history of mice)
-- 
-- historical cage placements have a defined m2c_datetime_to entry
-- current placements have m2c_datetime_to = NULL

-- foreign key (-> table "mice")
  m2c_mouse_id                                int                        NOT NULL

-- foreign key (-> table "cages")
, m2c_cage_id                                 int                        NOT NULL

-- if a mouse has been in four cages so far and now is moved into its fifth cage, this field will be "5"
-- (this is somehow redundant, since there is also the m2c_datetime_from column, but this has historical reasons...)
, m2c_cage_of_this_mouse                      int                        NOT NULL

-- datetime of mouse entering this cage
, m2c_datetime_from                           datetime                   default NULL

-- datetime of mouse leaving this cage
, m2c_datetime_to                             datetime                   default NULL

-- foreign key (-> table "users"): who moved the mouse?
, m2c_move_user_id                            int                        default NULL

-- datetime of move transaction (not of move itself)?
-- there is difference between "when was the mouse transferred into a new cage" and "when did a user tell this to the database"
, m2c_move_datetime                           datetime                   default NULL

, PRIMARY KEY (m2c_mouse_id, m2c_cage_id, m2c_datetime_from)
)
ENGINE=InnoDB
;
CREATE INDEX m2c_cage_id            ON mice2cages (m2c_cage_id);
CREATE INDEX m2c_cage_of_this_mouse ON mice2cages (m2c_cage_of_this_mouse);
CREATE INDEX m2c_datetime_to        ON mice2cages (m2c_datetime_to);
CREATE INDEX m2c_move_user_id       ON mice2cages (m2c_move_user_id);




DROP TABLE IF EXISTS mice2orderlists;
CREATE TABLE mice2orderlists (
-- cross table: "mice" <-> "orderlists"

-- foreign key (-> table "mice")
  m2o_mouse_id                            int                        NOT NULL

-- foreign key (-> table "orderlists")  
, m2o_orderlist_id                        int                        NOT NULL

-- position of mouse on the orderlist
, m2o_listposition                        int                        default 0

-- orderlist state: 'ordered', 'done', 'cancelled', ...
, m2o_status                              varchar(20)                default 'waiting'

-- datetime of mouse added to the orderlist
, m2o_added_datetime                      datetime                   default NULL

, PRIMARY KEY (m2o_mouse_id, m2o_orderlist_id)
)
ENGINE=InnoDB
;
CREATE INDEX m2o_orderlist_id      ON mice2orderlists (m2o_orderlist_id);
CREATE INDEX m2o_listposition      ON mice2orderlists (m2o_listposition);
CREATE INDEX m2o_status            ON mice2orderlists (m2o_status);



DROP TABLE IF EXISTS orderlists;
CREATE TABLE orderlists (
-- every orderlist has an entry here
-- an orderlist contains all mice to be phenotyped for a certain parameterset on the same date

-- primary key: serial orderlist id
  orderlist_id                                int                        NOT NULL

-- custom name of orderlist: may be a combination of parameterset, date, strain, line, sex, ...
, orderlist_name                        varchar(255)                     NOT NULL

-- foreign key (-> table "users"): who created the orderlist?
, orderlist_created_by                        int                        NOT NULL

-- datetime of orderlist creation
, orderlist_date_created                      datetime                   NOT NULL

-- job to be done, mostly: "measure", in the future: "kill", 'mate', ....
-- (defined in table "settings")
, orderlist_job                               varchar(255)               NOT NULL

-- sample type, i.e. 'none', 'blood', 'urine',...
-- (defined in "settings")
, orderlist_sampletype                        varchar(20)                default NULL

-- sample amount
, orderlist_sample_amount                     varchar(20)                default NULL

-- scheduled date
, orderlist_date_scheduled                    date                       NOT NULL

-- foreign key (-> table "users"): who is in charge to measure?
, orderlist_assigned_user                     int                        NOT NULL

-- foreign key (-> table "parametersets"): which parameterset?
, orderlist_parameterset                      int                        NOT NULL

-- state of the orderlist: 'ordered', 'done', 'cancelled', ...  
, orderlist_status                            varchar(20)                default 'waiting'

-- comment
, orderlist_comment                           text                       default ''

, PRIMARY KEY (orderlist_id)
)
ENGINE=InnoDB
;               
CREATE INDEX orderlist_created_by      ON orderlists (orderlist_created_by);
CREATE INDEX orderlist_date_scheduled  ON orderlists (orderlist_date_scheduled);
CREATE INDEX orderlist_parameterset    ON orderlists (orderlist_parameterset);
CREATE INDEX orderlist_job             ON orderlists (orderlist_job);
CREATE INDEX orderlist_status          ON orderlists (orderlist_status);
CREATE INDEX orderlist_assigned_user   ON orderlists (orderlist_assigned_user);



DROP TABLE IF EXISTS cages2locations;
CREATE TABLE cages2locations (
-- cross table: "cages" <-> "locations" (cage->rack history)
--
-- historical placements have a defined c2l_datetime_to entry
-- current placements have c2l_datetime_to = NULL

-- foreign key (-> table "cages")
  c2l_cage_id                            int                        NOT NULL

-- foreign key (-> table "locations")  
, c2l_location_id                        int                        NOT NULL

-- datetime of cage put into rack
, c2l_datetime_from                      datetime                   default NULL

-- datetime of cage taken out from rack
, c2l_datetime_to                        datetime                   default NULL

-- foreign key (-> table "users"): who moved the cage into rack
, c2l_move_user_id                       int                        default NULL

-- datetime of move transaction (not of move itself)?
-- there is difference between "when was the cage transferred into a new rack" and "when did a user tell this to the database"
, c2l_move_datetime                      datetime                   default NULL

, PRIMARY KEY (c2l_cage_id, c2l_location_id, c2l_datetime_from)
)
ENGINE=InnoDB
;              
CREATE INDEX c2l_location_id    ON cages2locations (c2l_location_id);
CREATE INDEX c2l_datetime_from  ON cages2locations (c2l_datetime_from);
CREATE INDEX c2l_move_user_id   ON cages2locations (c2l_move_user_id);



DROP TABLE IF EXISTS days;
CREATE TABLE days (
-- master data table: every calendar day has an entry here
-- pre-computed properties of a day (i.e. calendar week) may be looked up here
-- Excel was used to generate this table

-- primary key: serial day id
  day_number                     int                        NOT NULL
  
-- date
, day_date                       date                       NOT NULL

-- combination of calendar week and year: i.e. "12/2006"
, day_week_and_year              varchar(7)                 NOT NULL

-- epoch week: start with first week, does not fall back to 0 in a new year
, day_epoch_week                 int                        NOT NULL

-- calendar week: important: week starts with monday (not US-like with sunday!)
, day_week_in_year               int                        NOT NULL

-- year
, day_year	                 int                        NOT NULL	

-- week day as number: monday = 1, tuesday = 2, ...
, day_week_day_number            int                        NOT NULL

-- week day: german/long ("Montag", "Dienstag", ...)
, day_week_day_name_gl           varchar(10)                default ''
	
-- week day : german/short ("Mo", "Di", ...)
, day_week_day_name_gs           char(2)                    default ''

-- week day: englisch/long ("monday", "tuesday", ...)
, day_week_day_name_el           varchar(10)                default ''
	
-- week day: englisch/short ("mo", "tu", ...)
, day_week_day_name_es           char(2)                    default ''
	
-- is it public holiday?
, day_is_holiday                 varchar(255)               default ''

, PRIMARY KEY (day_number)
)
ENGINE=InnoDB
;
CREATE INDEX day_date            ON days (day_date);
CREATE INDEX day_epoch_week      ON days (day_epoch_week);
CREATE INDEX day_week_in_year    ON days (day_week_in_year);
CREATE INDEX day_year            ON days (day_year);
CREATE INDEX day_week_day_number ON days (day_week_day_number);
CREATE INDEX day_is_holiday      ON days (day_is_holiday);



DROP TABLE IF EXISTS mouse_coat_colors;
CREATE TABLE mouse_coat_colors (
-- master data table for coat colors

-- primary key: serial coat color ID
  coat_color_id                          int                         NOT NULL
  
-- name of coat colors
, coat_color_name                        varchar(255)                NOT NULL

-- description
, coat_color_description                 text                        default ''

, PRIMARY KEY (coat_color_id)
)
ENGINE=InnoDB
;
CREATE INDEX coat_color_name ON mouse_coat_colors (coat_color_name);




DROP TABLE IF EXISTS death_reasons;
CREATE TABLE death_reasons (
-- master data table with reasons for death and export

-- primary key: serial id
  death_reason_id                        int                         NOT NULL
  
-- category: there is a "how" and a "why"
, death_reason_category                  varchar(3)                  NOT NULL

-- name of death reasons
-- how: "found dead", "killed", "exported"
-- why: "died in experiment", "ill", ...
, death_reason_name                      varchar(255)                NOT NULL

-- description
, death_reason_description               text                        default ''

, PRIMARY KEY (death_reason_id)
)
ENGINE=InnoDB
;
CREATE INDEX death_reason_name      ON death_reasons (death_reason_name);
CREATE INDEX death_reason_category  ON death_reasons (death_reason_category);




DROP TABLE IF EXISTS mouse_strains;
CREATE TABLE mouse_strains (
-- master data table for mouse strains (genetic background)

-- primary key: serial strain id
  strain_id                                int                         NOT NULL

-- strain name: i.e. "C57BL/6", "Balb/c", "CD1", "129Sv", ...
, strain_name                              varchar(255)                NOT NULL

-- just a sort field
, strain_order                             int                         default NULL

-- strain to be displayed [y/n]?
, strain_show                              char(1)                     default 'y'

-- description
, strain_description                       text                        default ''

, PRIMARY KEY (strain_id)
)
ENGINE=InnoDB
;
CREATE INDEX strain_name ON mouse_strains (strain_name);




DROP TABLE IF EXISTS log_uploads;
CREATE TABLE log_uploads (
-- every upload is logged here

-- primary key: serial id
  log_id                                     int                        NOT NULL AUTO_INCREMENT

-- foreign key (-> table "users"): who uploaded?
, log_user_id                                int                        default '0'

-- is redundant with above, just for better readability
, log_user_name                              varchar(50)                default ''

-- datetime of uploads
, log_datetime                               timestamp(14)              NOT NULL

-- name of uploaded file
, log_upload_filename                        varchar(50)                NOT NULL

-- local name of uploaded file (added username)
, log_local_filename                         varchar(50)                NOT NULL

-- IP address of computer from which upload was done
, log_remote_IP                              varchar(16)                default ''

, PRIMARY KEY (log_id)
)
ENGINE=InnoDB
AUTO_INCREMENT=1
;
CREATE INDEX log_upload_user_id    ON log_uploads (log_user_id);
CREATE INDEX log_upload_datetime   ON log_uploads (log_datetime);
CREATE INDEX log_upload_remote_IP  ON log_uploads (log_remote_IP);




DROP TABLE IF EXISTS log_access;
CREATE TABLE log_access (
-- logins and logouts are logged here
-- used also to determine who is currently logged in

-- primary key: serial id
  log_id                                int                        NOT NULL AUTO_INCREMENT

-- foreign key (-> table "users"): who logged in/out?
, log_user_id                           int                        NOT NULL

-- is redundant with above, just for better readabilitys
, log_user_name                         varchar(50)                NOT NULL

-- datetime of login/logout
, log_datetime                          timestamp(14)              NOT NULL

-- name of remote machinee
, log_remote_host                       varchar(50)                NOT NULL

-- IP address of remote machine
, log_remote_IP                         varchar(16)                NOT NULL

-- what: "login"/"logout"
, log_choice                            text                       NOT NULL

-- additional URL parameters
, log_parameters                        text                       NOT NULL

, PRIMARY KEY (log_id)
)
ENGINE=InnoDB
;
CREATE INDEX log_access_user_id ON log_access (log_user_id);




DROP TABLE IF EXISTS properties;
CREATE TABLE properties (
-- general purpose table to add custum properties to a mouse without having to create a table for each property
-- examples:      foreign_id:         foreign id of imported mice 
--                marking_system:     if not the "99" ear marking system, what instead?
--                other_mark:         andere Markierung

-- primary key: serial id
  property_id                                int                        NOT NULL auto_increment
  
-- category: "mouse"
, property_category                          varchar(20)                NOT NULL

-- key: "earmark_type", "info", "health", ...
, property_key                               varchar(255)               NOT NULL

-- actual value : "int", "bool", "float", text"
, property_type                              varchar(10)                NOT NULL
, property_value_integer                     int                        default NULL
, property_value_bool                        char(1)                    default NULL
, property_value_float                       float                      default NULL
, property_value_text                        text                       default NULL            

, PRIMARY KEY (property_id)
)
ENGINE=InnoDB
;
CREATE INDEX property_key       ON properties (property_key);
CREATE INDEX property_type      ON properties (property_type);
CREATE INDEX property_category  ON properties (property_category);


DROP TABLE IF EXISTS carts;
CREATE TABLE carts (
-- every stored cart has an entry here

-- primary key: serial cart id
  cart_id                                int                        NOT NULL

-- unique cart name
, cart_name                              varchar(50)                NOT NULL

-- cart content (comma-separated list of mouse ids)
, cart_content                           text                       NOT NULL

-- datetime of cart creation
, cart_creation_datetime                 datetime                   default NULL

-- "valid until" datetime of cart
, cart_end_datetime                      datetime                   default NULL

-- foreign key (-> table "users"): who stored the cart?
, cart_user                              int                        NOT NULL

-- cart public to all?
, cart_is_public                         char(1)                    default 'n'

, PRIMARY KEY (cart_id)
)
ENGINE=InnoDB
;
CREATE INDEX cart_name              ON carts (cart_name);
CREATE INDEX cart_user              ON carts (cart_user);
CREATE INDEX cart_creation_datetime ON carts (cart_creation_datetime);
CREATE INDEX cart_end_datetime      ON carts (cart_end_datetime);




DROP TABLE IF EXISTS mice2properties;
CREATE TABLE mice2properties (
-- cross table: "mice" <-> "properties"

-- foreign key (-> table "mice")
  m2pr_mouse_id                                int                        NOT NULL

-- foreign key (-> table "properties")  
, m2pr_property_id                             int                        NOT NULL

-- datetime of adding the property to a mouse
, m2pr_datetime                                datetime                   default NULL

-- foreign key (-> table "users"): who added the property?
, m2pr_user                                    int                        NOT NULL
  
, PRIMARY KEY (m2pr_mouse_id, m2pr_property_id, m2pr_datetime, m2pr_user)
)
ENGINE=InnoDB
;
CREATE INDEX m2pr_property_id  ON mice2properties (m2pr_property_id);
CREATE INDEX m2pr_user         ON mice2properties (m2pr_user);



DROP TABLE IF EXISTS mylocks;
CREATE TABLE mylocks (
-- for simple locking mechanism
-- (yes, we know there are better ways to do this ...)

  mylock_id                                 int                    NOT NULL
, mylock_value                              char(8)                NOT NULL
, mylock_session                            char(32)               NOT NULL
, mylock_user_id                            int                    NOT NULL
, mylock_datetime                           datetime               NOT NULL
, PRIMARY KEY (mylock_id)
)
ENGINE=InnoDB
;



DROP TABLE IF EXISTS mice2medical_records;
CREATE TABLE mice2medical_records (
-- cross table: "mice" <-> "medical_records"
-- one medical record may be assigned to one or many mice

-- foreign key (-> table "mice"): mouse ID
  m2mr_mouse_id                    int                        NOT NULL
  
-- foreign key (-> table "medical_records"): mr_id
, m2mr_mr_id                       int                        NOT NULL

-- role of mouse in medical record assignment: z.B. 'measured', 'representative', 'is_control'
, m2mr_mouse_role                  varchar(20)                NOT NULL

, PRIMARY KEY  (m2mr_mouse_id, m2mr_mr_id)

)
ENGINE=InnoDB
;
CREATE INDEX m2mr_mr_id ON mice2medical_records (m2mr_mr_id);



DROP TABLE IF EXISTS mice2blob_data;
CREATE TABLE mice2blob_data (
-- cross table: "mice" <-> "blob_data"
-- one blob may be assigned to one or many mice, one mouse may have many blobs

-- foreign key (-> table "mice"): mouse ID
  m2b_mouse_id                    int                        NOT NULL
  
-- foreign key (-> table "blob_data"): blob_id
, m2b_blob_id                     int                        NOT NULL

-- role of mouse in blob assignment: z.B. 'experiment', 'control'
, m2b_mouse_role                  varchar(20)                NOT NULL

, PRIMARY KEY  (m2b_mouse_id, m2b_blob_id)

)
ENGINE=InnoDB
;
CREATE INDEX m2b_blob_id ON mice2blob_data (m2b_blob_id);


DROP TABLE IF EXISTS line2blob_data;
CREATE TABLE line2blob_data (
-- cross table: "mouse_lines" <-> "blob_data"
-- one blob may be assigned to one or many mouse lines, one mouse line may have many blobs

-- foreign key (-> table "mouse_lines"): line ID
  l2b_line_id                     int                        NOT NULL
  
-- foreign key (-> table "blob_data"): blob_id
, l2b_blob_id                     int                        NOT NULL

, PRIMARY KEY  (l2b_line_id, l2b_blob_id)

)
ENGINE=InnoDB
;
CREATE INDEX l2b_blob_id ON line2blob_data (l2b_blob_id);


DROP TABLE IF EXISTS cost_accounts;
CREATE TABLE cost_accounts (
-- every cost account has an entry here

-- primary key: serial id
  cost_account_id                            int                        NOT NULL

-- name of cost_account
, cost_account_name                          varchar(20)                NOT NULL

-- number of cost_account
, cost_account_number                        varchar(10)                NOT NULL

-- comment to cost_account
, cost_account_comment                       text                       NOT NULL

, PRIMARY KEY (cost_account_id)
)
ENGINE=InnoDB
;
CREATE INDEX cost_account_number ON cost_accounts (cost_account_number);



DROP TABLE IF EXISTS mice2cost_accounts;
CREATE TABLE mice2cost_accounts (
-- cross table: "mice" <-> "cost_accounts"
-- one cost accounts may be assigned to one or many mice

-- foreign key (-> table "mice"): mouse ID
  m2ca_mouse_id                    int                        NOT NULL
  
-- foreign key (-> table "cost_accounts"): cost_account_id
, m2ca_cost_account_id             int                        NOT NULL

-- datetime of mouse entering this cost-account
, m2ca_datetime_from               datetime                   default NULL

-- datetime of mouse leaving this cost-account
, m2ca_datetime_to                 datetime                   default NULL

, PRIMARY KEY (m2ca_mouse_id, m2ca_cost_account_id, m2ca_datetime_from)
)
ENGINE=InnoDB
;
CREATE INDEX m2ca_cost_account_id ON mice2cost_accounts (m2ca_cost_account_id);
CREATE INDEX m2ca_datetime_to     ON mice2cost_accounts (m2ca_datetime_to);



DROP TABLE IF EXISTS metadata_definitions;
CREATE TABLE metadata_definitions (
-- every metadata definition has an entry here

-- primary key: serial id
   mdd_id                            int                        NOT NULL

-- name of metadata entity
,  mdd_name                          varchar(255)               NOT NULL

-- short name of metadata entity
,  mdd_shortname                     varchar(20)                NOT NULL

-- type of metadata entity -> (i)nt, (f)loat, (b)ool, (t)ext, (m)edia
,  mdd_type                          char(1)                    NOT NULL

-- decimals
,  mdd_decimals                      int                        default NULL

-- mdd physical unit (i.e. N/mm^2)
,  mdd_unit                          varchar(255)               default NULL

-- default value
,  mdd_default                       varchar(255)               default NULL

-- value list
,  mdd_possible_values               text                       default NULL

-- mdd global: is this metadata definition global? [y/n]
,  mdd_global_yn                     char(1)                    NOT NULL

-- mdd global: is this metadata definition active? [y/n]
,  mdd_active_yn                     char(1)                    NOT NULL

-- mdd required: is this metadata definition required? [y/n]
,  mdd_required                      char(1)                    default 'n'

-- foreign key (-> table "parametersets"): parameterset_ID
,  mdd_parameterset_id               int                        default NULL

-- [currently not used] foreign key (-> table "parameters"):    parameter_ID
,  mdd_parameter_id                  int                        default NULL

-- description
,  mdd_description                   text                       default ''

, PRIMARY KEY (mdd_id)
)
ENGINE=InnoDB
;
CREATE INDEX mdd_global_yn       ON metadata_definitions (mdd_global_yn);
CREATE INDEX mdd_active_yn       ON metadata_definitions (mdd_active_yn);
CREATE INDEX mdd_required        ON metadata_definitions (mdd_required);
CREATE INDEX mdd_parameterset_id ON metadata_definitions (mdd_parameterset_id);
CREATE INDEX mdd_parameter_id    ON metadata_definitions (mdd_parameter_id);



DROP TABLE IF EXISTS metadata;
CREATE TABLE metadata (
-- every metadata data point has an entry here

-- primary key: serial id
   metadata_id                       int                        NOT NULL

-- foreign key (-> table "metadata_definitions"):    mdd_id
,  metadata_mdd_id                   int                        NOT NULL

-- actual metadata value
,  metadata_value                    text                       NOT NULL

-- foreign key (-> table "orderlists"):      orderlist ID
,  metadata_orderlist_id             int                        default NULL

-- [currently not used] foreign key (-> table "medical_records"): mr ID
,  metadata_medical_record_id        int                        default NULL

-- [currently not used] foreign key (-> table "mice"):            mouse ID
,  metadata_mouse_id                 int                        default NULL

-- foreign key (-> table "parametersets"):   parameterset ID
,  metadata_parameterset_id          int                        default NULL

-- valid from
,  metadata_valid_datetime_from      datetime                   default NULL

-- valid to
,  metadata_valid_datetime_to        datetime                   default NULL

, PRIMARY KEY (metadata_id)
)
ENGINE=InnoDB
;
CREATE INDEX metadata_mdd_id              ON metadata (metadata_mdd_id);
CREATE INDEX metadata_value               ON metadata (metadata_value(50));
CREATE INDEX metadata_orderlist_id        ON metadata (metadata_orderlist_id);
CREATE INDEX metadata_medical_record_id   ON metadata (metadata_medical_record_id);
CREATE INDEX metadata_mouse_id            ON metadata (metadata_mouse_id);
CREATE INDEX metadata_parameterset_id     ON metadata (metadata_parameterset_id);
CREATE INDEX metadata_valid_datetime_from ON metadata (metadata_valid_datetime_from);
CREATE INDEX metadata_valid_datetime_to   ON metadata (metadata_valid_datetime_to);



-- ---------------------------------------------------------------------------------
-- I N  S E P A R A T E   D A T A B A S E !!!
-- DROP TABLE IF EXISTS blob_data;
-- CREATE TABLE blob_data (
-- -- every blob has an entry here
--
-- -- primary key: serial blob id
--   blob_id                                 int                         NOT NULL auto_increment
--
-- -- name of blob filename, i.e. excel file name
-- , blob_name                               varchar(255)                NOT NULL
--
-- -- blob type, i.e. "excel", "jpeg", "pdf", "tiff", ...
-- , blob_content_type                       varchar(255)                default NULL
--
-- -- blob mime-type
-- , blob_mime_type                          varchar(255)                default NULL
--
-- -- the blob itself
-- , blob_itself                             longblob                    default NULL
--
-- -- datetime of blob upload
-- , blob_upload_datetime                    datetime                    default NULL
--
-- -- comment to file
-- , blob_comment                            text                        default ''
--
-- -- upload user
-- , blob_upload_user                        int                         default NULL
--
-- -- is the blob public or not?
-- , blob_is_public                          char(1)                     NOT NULL
--
-- , PRIMARY KEY                             (blob_id)
-- )
-- ENGINE=MYISAM
-- -- ENGINE=InnoDB
-- ;
-- CREATE INDEX blob_name         ON blob_data (blob_name);
-- CREATE INDEX blob_upload_user  ON blob_data (blob_upload_user);
-- -- ---------------------------------------------------------------------------------




-- -- -----------------------------------------------------
-- -- DEFINITION OF FOREIGN KEY - PRIMARY KEY RELATIONS
--
-- -- ONLY FOR GENERATION OF ENTITY RELATTIONSHIP DIAGRAM
-- -- -----------------------------------------------------

-- ALTER TABLE locations		 ADD CONSTRAINT has_address_location	 FOREIGN KEY (location_address) 	     REFERENCES addresses	   (address_id);
-- ALTER TABLE contacts2addresses     ADD CONSTRAINT has_address_c2a	 FOREIGN KEY (c2a_address_id)		     REFERENCES addresses	   (address_id);
-- ALTER TABLE cages2locations	 ADD CONSTRAINT has_cage_c2l		 FOREIGN KEY (c2l_cage_id)		     REFERENCES cages		   (cage_id);
-- ALTER TABLE mice2cages  	 ADD CONSTRAINT has_cage		 FOREIGN KEY (m2c_cage_id)		     REFERENCES cages		   (cage_id);
-- ALTER TABLE contacts2addresses     ADD CONSTRAINT has_contact_c2a	   FOREIGN KEY (c2a_contact_id) 	     REFERENCES contacts	   (contact_id);
-- ALTER TABLE experiments 	 ADD CONSTRAINT is_granted_to		 FOREIGN KEY (experiment_granted_to_contact) REFERENCES contacts	   (contact_id);
-- ALTER TABLE imports		 ADD CONSTRAINT has_provider_import	 FOREIGN KEY (import_provider_contact)       REFERENCES contacts	   (contact_id);
-- ALTER TABLE mice		 ADD CONSTRAINT has_export_contact	 FOREIGN KEY (mouse_deathorexport_contact)   REFERENCES contacts	   (contact_id);
-- 
-- ALTER TABLE users		 ADD CONSTRAINT has_contact_user	 FOREIGN KEY (user_contact)		     REFERENCES contacts	   (contact_id);
-- ALTER TABLE mice		 ADD CONSTRAINT has_death_reason_how	 FOREIGN KEY (mouse_deathorexport_how)       REFERENCES death_reasons	   (death_reason_id);
-- ALTER TABLE mice		 ADD CONSTRAINT has_death_reason_why	 FOREIGN KEY (mouse_deathorexport_why)       REFERENCES death_reasons	   (death_reason_id);
-- ALTER TABLE imports2contacts	 ADD CONSTRAINT has_import_i2c  	 FOREIGN KEY (i2c_import_id)		     REFERENCES imports 	   (import_id);
-- ALTER TABLE imports2contacts	 ADD CONSTRAINT has_contact_i2c 	 FOREIGN KEY (i2c_contact_id)		     REFERENCES contacts	   (contact_id);
-- ALTER TABLE mice2experiments	 ADD CONSTRAINT has_experiment_m2e	 FOREIGN KEY (m2e_experiment_id)	     REFERENCES experiments	   (experiment_id);
-- ALTER TABLE genes2externalDBs	 ADD CONSTRAINT has_link_e2e		 FOREIGN KEY (g2e_externalDB_id)	     REFERENCES externalDBs	   (externalDB_id);
-- ALTER TABLE mice2phenotypesDB	 ADD CONSTRAINT has_link_m2ph		 FOREIGN KEY (m2p_externalDB_id)	     REFERENCES externalDBs	   (externalDB_id);
-- ALTER TABLE mice2genes  	 ADD CONSTRAINT has_gene_m2g		 FOREIGN KEY (m2g_gene_id)		     REFERENCES genes		   (gene_id);
-- 
-- ALTER TABLE genes2externalDBs	 ADD CONSTRAINT has_gene_e2e		 FOREIGN KEY (g2e_gene_id)		     REFERENCES genes		   (gene_id);
-- ALTER TABLE mouse_lines2genes	 ADD CONSTRAINT has_gene_ml2g		 FOREIGN KEY (ml2g_gene_id)		     REFERENCES genes		   (gene_id);
-- ALTER TABLE mice2healthreports         ADD CONSTRAINT has_report	 FOREIGN KEY (m2h_healthreport_id)	     REFERENCES healthreports	   (healthreport_id);
-- ALTER TABLE locations2healthreports         ADD CONSTRAINT has_location_report	 FOREIGN KEY (l2h_healthreport_id)	     REFERENCES healthreports	   (healthreport_id);
-- ALTER TABLE imports		 ADD CONSTRAINT has_report_import	 FOREIGN KEY (import_healthreport)	     REFERENCES healthreports	   (healthreport_id);
-- ALTER TABLE mice		 ADD CONSTRAINT is_from_import  	 FOREIGN KEY (mouse_import_id)  	     REFERENCES imports 	   (import_id);
-- ALTER TABLE litters2parents	 ADD CONSTRAINT has_litter_l2p  	 FOREIGN KEY (l2p_litter_id)		     REFERENCES litters 	   (litter_id);
-- ALTER TABLE mice		 ADD CONSTRAINT is_from_litter  	 FOREIGN KEY (mouse_litter_id)  	     REFERENCES litters 	   (litter_id);
-- ALTER TABLE mice		 ADD CONSTRAINT has_export_location	 FOREIGN KEY (mouse_deathorexport_location)  REFERENCES locations	   (location_id);
-- 
-- ALTER TABLE cages2locations	 ADD CONSTRAINT has_location_c2l	 FOREIGN KEY (c2l_location_id)  	     REFERENCES locations	   (location_id);
-- ALTER TABLE imports		 ADD CONSTRAINT has_location_import	 FOREIGN KEY (import_origin_location)	     REFERENCES locations	   (location_id);
-- ALTER TABLE parents2matings	 ADD CONSTRAINT has_mating_p2m  	 FOREIGN KEY (p2m_mating_id)		     REFERENCES matings 	   (mating_id);
-- ALTER TABLE litters		 ADD CONSTRAINT has_mating		 FOREIGN KEY (litter_mating_id) 	     REFERENCES matings 	   (mating_id);
-- ALTER TABLE mice2genes  	 ADD CONSTRAINT has_mouse_m2g		 FOREIGN KEY (m2g_mouse_id)		     REFERENCES mice		   (mouse_id);
-- ALTER TABLE mice2healthreports         ADD CONSTRAINT has_mouse_m2h	 FOREIGN KEY (m2h_mouse_id)		     REFERENCES mice		   (mouse_id);
-- ALTER TABLE locations2healthreports         ADD CONSTRAINT has_mouse_l2h	 FOREIGN KEY (l2h_location_id)		     REFERENCES locations		   (location_id);
-- ALTER TABLE mice2phenotypesDB	 ADD CONSTRAINT has_mouse_m2ph  	 FOREIGN KEY (m2p_mouse_id)		     REFERENCES mice		   (mouse_id);
-- ALTER TABLE mice2experiments	 ADD CONSTRAINT has_mouse_m2e		 FOREIGN KEY (m2e_mouse_id)		     REFERENCES mice		   (mouse_id);
-- ALTER TABLE mice2mousegroups	 ADD CONSTRAINT has_mouse_m2m		 FOREIGN KEY (m2m_mouse_id)		     REFERENCES mice		   (mouse_id);
-- ALTER TABLE parents2matings	 ADD CONSTRAINT has_parent_p2m  	 FOREIGN KEY (p2m_parent_id)		     REFERENCES mice		   (mouse_id);
-- 
-- ALTER TABLE mice2projects	 ADD CONSTRAINT has_mouse_m2proj	 FOREIGN KEY (m2p_mouse_id)		     REFERENCES mice		   (mouse_id);
-- ALTER TABLE mice2properties	 ADD CONSTRAINT has_mouse_m2p		 FOREIGN KEY (m2pr_mouse_id)		     REFERENCES mice		   (mouse_id);
-- ALTER TABLE litters2parents	 ADD CONSTRAINT has_parent_l2p  	 FOREIGN KEY (l2p_parent_id)		     REFERENCES mice		   (mouse_id);
-- ALTER TABLE mice2cages  	 ADD CONSTRAINT has_mouse_m2c		 FOREIGN KEY (m2c_mouse_id)		     REFERENCES mice		   (mouse_id);
-- ALTER TABLE mice2mousegroups	 ADD CONSTRAINT has_mousegroup_m2m	 FOREIGN KEY (m2m_mousegroup_id)	     REFERENCES mousegroups	   (mousegroup_id);
-- ALTER TABLE mice		 ADD CONSTRAINT has_coat_color  	 FOREIGN KEY (mouse_coat_color) 	     REFERENCES mouse_coat_colors  (coat_color_id);
-- ALTER TABLE mice		 ADD CONSTRAINT has_line		 FOREIGN KEY (mouse_line)		     REFERENCES mouse_lines	   (line_id);
-- ALTER TABLE imports		 ADD CONSTRAINT has_line_import 	 FOREIGN KEY (import_line)		     REFERENCES mouse_lines	   (line_id);
-- ALTER TABLE matings		 ADD CONSTRAINT has_line_mating 	 FOREIGN KEY (mating_line)		     REFERENCES mouse_lines	   (line_id);
-- ALTER TABLE mouse_lines2genes	 ADD CONSTRAINT has_line_ml2g		 FOREIGN KEY (ml2g_mouse_line_id)	     REFERENCES mouse_lines	   (line_id);
-- ALTER TABLE mice		 ADD CONSTRAINT has_strain		 FOREIGN KEY (mouse_strain)		     REFERENCES mouse_strains	   (strain_id);
-- ALTER TABLE imports		 ADD CONSTRAINT has_strain_import	 FOREIGN KEY (import_strain)		     REFERENCES mouse_strains	   (strain_id);
-- 
-- ALTER TABLE matings		 ADD CONSTRAINT has_strain_mating	 FOREIGN KEY (mating_strain)		     REFERENCES mouse_strains	   (strain_id);
-- ALTER TABLE mice2orderlists ADD CONSTRAINT has_mouse_m2o FOREIGN KEY (m2o_mouse_id) REFERENCES mice (mouse_id);
-- ALTER TABLE mice2orderlists ADD CONSTRAINT has_orderlist_m2o FOREIGN KEY (m2o_orderlist_id) REFERENCES orderlists (orderlist_id);
-- ALTER TABLE parametersets2parameters ADD CONSTRAINT has_parameter FOREIGN KEY (p2p_parameter_id) REFERENCES parameters (parameter_id);
-- ALTER TABLE parametersets2parameters ADD CONSTRAINT has_parameterset_p2p FOREIGN KEY (p2p_parameterset_id) REFERENCES parametersets (parameterset_id);
-- ALTER TABLE workflows2parametersets ADD CONSTRAINT has_parameterset_w2p FOREIGN KEY (w2p_parameterset_id) REFERENCES parametersets (parameterset_id);
-- ALTER TABLE cages		 ADD CONSTRAINT has_project_cage	 FOREIGN KEY (cage_project)		     REFERENCES projects	   (project_id);
-- ALTER TABLE locations		 ADD CONSTRAINT has_project_location	 FOREIGN KEY (location_project) 	     REFERENCES projects	   (project_id);
-- ALTER TABLE mice2projects	 ADD CONSTRAINT has_project_m2proj	 FOREIGN KEY (m2p_project_id)		     REFERENCES projects	   (project_id);
-- ALTER TABLE parametersets ADD CONSTRAINT has_project_psets FOREIGN KEY (parameterset_project_id) REFERENCES projects (project_id);
-- ALTER TABLE projects		 ADD CONSTRAINT has_parent_project	 FOREIGN KEY (project_parent_project)	     REFERENCES projects	   (project_id);
-- 
-- ALTER TABLE users2projects	 ADD CONSTRAINT has_project_u2p 	 FOREIGN KEY (u2p_project_id)		     REFERENCES projects	   (project_id);
-- ALTER TABLE matings		 ADD CONSTRAINT has_project_matings	 FOREIGN KEY (mating_project)		     REFERENCES projects	   (project_id);
-- ALTER TABLE imports		 ADD CONSTRAINT has_project_imports	 FOREIGN KEY (import_project)		     REFERENCES projects	   (project_id);
-- ALTER TABLE mice2properties	 ADD CONSTRAINT has_property_m2p	 FOREIGN KEY (m2pr_property_id) 	     REFERENCES properties	   (property_id);
-- ALTER TABLE cages	       ADD CONSTRAINT has_user_cages	       FOREIGN KEY (cage_user)  		   REFERENCES users		 (user_id);
-- ALTER TABLE log_access         ADD CONSTRAINT has_user_access	       FOREIGN KEY (log_user_id)		   REFERENCES users		 (user_id);
-- ALTER TABLE mice2cages         ADD CONSTRAINT has_user_mouse_move      FOREIGN KEY (m2c_move_user_id)		   REFERENCES users		 (user_id);
-- ALTER TABLE cages2locations    ADD CONSTRAINT has_user_cage_move       FOREIGN KEY (c2l_move_user_id)		   REFERENCES users		 (user_id);
-- ALTER TABLE log_uploads        ADD CONSTRAINT has_user_uploads         FOREIGN KEY (log_user_id)		   REFERENCES users		 (user_id);
-- ALTER TABLE mice2properties    ADD CONSTRAINT has_user_m2p	       FOREIGN KEY (m2pr_user)  		   REFERENCES users		 (user_id);
-- ALTER TABLE mousegroups        ADD CONSTRAINT has_user_mousegroups     FOREIGN KEY (mousegroup_user)		   REFERENCES users		 (user_id);
-- ALTER TABLE carts	       ADD CONSTRAINT has_cart_user	       FOREIGN KEY (cart_user)  		   REFERENCES users		 (user_id);
-- ALTER TABLE projects		 ADD CONSTRAINT has_owner_project	 FOREIGN KEY (project_owner)		     REFERENCES users		   (user_id);
-- 
-- ALTER TABLE orderlists ADD CONSTRAINT has_parameterset FOREIGN KEY (orderlist_parameterset) REFERENCES parametersets (parameterset_id);
-- ALTER TABLE orderlists ADD CONSTRAINT has_creation_user FOREIGN KEY (orderlist_created_by) REFERENCES users (user_id);
-- ALTER TABLE orderlists ADD CONSTRAINT has_assigned_user FOREIGN KEY (orderlist_assigned_user) REFERENCES users (user_id);
-- ALTER TABLE users2projects	 ADD CONSTRAINT has_user_u2p		 FOREIGN KEY (u2p_user_id)		     REFERENCES users		   (user_id);
-- ALTER TABLE imports		 ADD CONSTRAINT has_coach_import	 FOREIGN KEY (import_coach_user)	     REFERENCES users		   (user_id);
-- ALTER TABLE workflows2parametersets ADD CONSTRAINT has_workflow_w2p FOREIGN KEY (w2p_workflow_id) REFERENCES workflows (workflow_id);
-- ALTER TABLE medical_records2sops ADD CONSTRAINT has_sop FOREIGN KEY (mr2s_sop_id) REFERENCES sops (sop_id);
-- ALTER TABLE medical_records2sops ADD CONSTRAINT has_medical_record FOREIGN KEY (mr2s_mr_id) REFERENCES medical_records (mr_id);
-- ALTER TABLE medical_records ADD CONSTRAINT has_orderlist_mr FOREIGN KEY (mr_orderlist_id) REFERENCES orderlists (orderlist_id);
-- ALTER TABLE medical_records ADD CONSTRAINT has_parameter_mr FOREIGN KEY (mr_parameter) REFERENCES parameters (parameter_id);
-- ALTER TABLE medical_records ADD CONSTRAINT has_measure_user_mr FOREIGN KEY (mr_measure_user) REFERENCES users (user_id);
-- ALTER TABLE medical_records ADD CONSTRAINT has_responsible_user_mr FOREIGN KEY (mr_responsible_user) REFERENCES users (user_id);
-- ALTER TABLE medical_records ADD CONSTRAINT has_project_mr FOREIGN KEY (mr_project_id) REFERENCES projects (project_id);
-- ALTER TABLE medical_records ADD CONSTRAINT has_parameterset_id FOREIGN KEY (mr_parameterset_id) REFERENCES parametersets (parameterset_id);
-- 
-- ALTER TABLE mice2medical_records ADD CONSTRAINT has_mouse FOREIGN KEY (m2mr_mouse_id) REFERENCES mice (mouse_id);
-- ALTER TABLE mice2medical_records ADD CONSTRAINT has_mr_m2mr FOREIGN KEY (m2mr_mr_id) REFERENCES medical_records (mr_id);
-- ALTER TABLE mice2cost_accounts ADD CONSTRAINT has_mouse_ca FOREIGN KEY (m2ca_mouse_id) REFERENCES mice (mouse_id);
-- ALTER TABLE mice2cost_accounts ADD CONSTRAINT has_ca_mouse FOREIGN KEY (m2ca_cost_account_id) REFERENCES cost_accounts (cost_account_id);
-- ALTER TABLE embryo_transfers ADD CONSTRAINT has_transfer_mating FOREIGN KEY (transfer_mating_id) REFERENCES matings (mating_id);
-- ALTER TABLE healthreports2healthreport_agents ADD CONSTRAINT has_healthreport FOREIGN KEY (hr2ha_health_report_id) REFERENCES healthreports (healthreport_id);
-- ALTER TABLE healthreports2healthreport_agents ADD CONSTRAINT has_healthreport_agent FOREIGN KEY (hr2ha_healthreport_agent_id) REFERENCES healthreport_agents (agent_id);
-- ALTER TABLE metadata   ADD CONSTRAINT has_metadata_definition   FOREIGN KEY (metadata_mdd_id)              REFERENCES metadata_definitions (mdd_id);
-- ALTER TABLE metadata   ADD CONSTRAINT has_orderlist_metadata    FOREIGN KEY (metadata_orderlist_id)        REFERENCES orderlists (orderlist_id);
-- ALTER TABLE metadata   ADD CONSTRAINT has_mr_metadata           FOREIGN KEY (metadata_medical_record_id)   REFERENCES medical_records (mr_id);
-- ALTER TABLE metadata   ADD CONSTRAINT has_mouse_metadata        FOREIGN KEY (metadata_mouse_id)            REFERENCES mice (mouse_id);
-- ALTER TABLE metadata   ADD CONSTRAINT has_parameterset_metadata FOREIGN KEY (metadata_parameterset_id)     REFERENCES parametersets (parameterset_id);
-- 
-- ALTER TABLE metadata_definitions   ADD CONSTRAINT has_parameterset_mdd FOREIGN KEY (mdd_parameterset_id)   REFERENCES parametersets (parameterset_id);
-- ALTER TABLE metadata_definitions   ADD CONSTRAINT has_parameter_mdd    FOREIGN KEY (mdd_parameter_id)      REFERENCES parameters    (parameter_id);
-- ALTER TABLE GTAS_line_info   ADD CONSTRAINT has_gli_mouse_line    FOREIGN KEY (gli_mouse_line_id)      REFERENCES mouse_lines    (line_id);
-- ALTER TABLE mice2treatment_procedures ADD CONSTRAINT has_treatment_id    FOREIGN KEY (m2tp_treatment_procedure_id) REFERENCES treatment_procedures (tp_id);
-- ALTER TABLE mice2treatment_procedures ADD CONSTRAINT has_treatment_mouse FOREIGN KEY (m2tp_mouse_id) REFERENCES mice (mouse_id);
-- ALTER TABLE parent_strains2litter_strain ADD CONSTRAINT has_mother_strain FOREIGN KEY (ps2ls_mother_strain) REFERENCES mouse_strains (strain_id);
-- ALTER TABLE parent_strains2litter_strain ADD CONSTRAINT has_father_strain FOREIGN KEY (ps2ls_father_strain) REFERENCES mouse_strains (strain_id);
-- ALTER TABLE parent_strains2litter_strain ADD CONSTRAINT has_litter_strain FOREIGN KEY (ps2ls_litter_strain) REFERENCES mouse_strains (strain_id);
-- ALTER TABLE mice2treatment_procedures ADD CONSTRAINT has_treatment_user FOREIGN KEY (m2tp_treatment_user_id) REFERENCES users (user_id);
-- ALTER TABLE mylocks ADD CONSTRAINT has_lock_user FOREIGN KEY (mylock_user_id) REFERENCES users (user_id);
-- ALTER TABLE mice2cohorts ADD CONSTRAINT has_cohort_id    FOREIGN KEY (m2co_cohort_id) REFERENCES cohorts (cohort_id);
-- ALTER TABLE mice2cohorts ADD CONSTRAINT has_cohort_mouse FOREIGN KEY (m2co_mouse_id)  REFERENCES mice (mouse_id);
-- ALTER TABLE treatment_procedures ADD CONSTRAINT has_treatment_project FOREIGN KEY (tp_treatment_project)  REFERENCES projects (project_id);


-- -- REFERENCES TO BLOB DATABASE (to create ER table blob_data needs to be InnoDB!!!)
-- -- --------------------------------------------------------------------------------
-- ALTER TABLE mice2blob_data ADD CONSTRAINT has_blob_id    FOREIGN KEY (m2b_blob_id)  REFERENCES blob_data (blob_id);
-- ALTER TABLE mice2blob_data ADD CONSTRAINT has_blob_mouse FOREIGN KEY (m2b_mouse_id) REFERENCES mice (mouse_id);
-- ALTER TABLE line2blob_data ADD CONSTRAINT has_line_blob_id FOREIGN KEY (l2b_blob_id) REFERENCES blob_data (blob_id);
-- ALTER TABLE line2blob_data ADD CONSTRAINT has_blob_line    FOREIGN KEY (l2b_line_id) REFERENCES mouse_lines (line_id);
-- ALTER TABLE blob_data ADD CONSTRAINT has_blob_user FOREIGN KEY (blob_upload_user) REFERENCES users (user_id);

