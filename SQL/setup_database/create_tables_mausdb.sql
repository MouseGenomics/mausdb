-- MySQL dump 10.11
--
-- Host: localhost    Database: mausdb
-- ------------------------------------------------------
-- Server version	5.0.51a-3ubuntu5.5

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `GTAS_line_info`
--

DROP TABLE IF EXISTS `GTAS_line_info`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `GTAS_line_info` (
  `gli_id` int(11) NOT NULL,
  `gli_mouse_line_id` int(11) NOT NULL,
  `gli_mouse_line_is_gvo` char(1) NOT NULL,
  `gli_Projektnr` int(11) default '51272',
  `gli_Institutscode` varchar(255) default 'AVM',
  `gli_Bemerkungen` varchar(255) default '',
  `gli_Spenderorganismen` varchar(255) default '',
  `gli_Nukleinsaeure_Bezeichnung` varchar(255) default '',
  `gli_Nukleinsaeure_Merkmale` varchar(255) default '',
  `gli_Vektoren` varchar(255) default '',
  `gli_Empfaengerorganismen` varchar(255) default 'Maus',
  `gli_GVO_Merkmale` varchar(255) default '',
  `gli_GVO_ErzeugtAm` date NOT NULL,
  `gli_Risikogruppe_Empfaenger` varchar(255) default 'S1',
  `gli_Risikogruppe_GVO` varchar(255) default 'S1',
  `gli_Risikogruppe_Spender` varchar(255) default 'S1',
  `gli_Lagerung` varchar(255) default '',
  `gli_Sonstiges` varchar(255) default '',
  `gli_TepID` varchar(30) default '',
  `gli_SysID` varchar(255) default 'GMC',
  `gli_OrgCode` varchar(255) default 'GSF',
  `gli_generate_GTAS_report` char(1) default 'y',
  `gli_line_id_in_coordDB` int(11) default NULL,
  `gli_line_name_in_coordDB` varchar(255) default NULL,
  PRIMARY KEY  (`gli_id`),
  KEY `gli_mouse_line_id` (`gli_mouse_line_id`),
  KEY `gli_mouse_line_is_gvo` (`gli_mouse_line_is_gvo`),
  KEY `gli_generate_GTAS_report` (`gli_generate_GTAS_report`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `addresses` (
  `address_id` int(11) NOT NULL default '0',
  `address_institution` varchar(255) collate utf8_unicode_ci default NULL,
  `address_street` varchar(255) collate utf8_unicode_ci default NULL,
  `address_postal_code` varchar(255) collate utf8_unicode_ci default NULL,
  `address_other_info` varchar(255) collate utf8_unicode_ci default NULL,
  `address_city` varchar(255) collate utf8_unicode_ci default NULL,
  `address_state` varchar(255) collate utf8_unicode_ci default NULL,
  `address_country` varchar(255) collate utf8_unicode_ci default NULL,
  `address_telephone` varchar(255) collate utf8_unicode_ci default NULL,
  `address_fax` varchar(255) collate utf8_unicode_ci default NULL,
  `address_unit` varchar(255) collate utf8_unicode_ci default NULL,
  `address_comment` text collate utf8_unicode_ci,
  PRIMARY KEY  (`address_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cages`
--

DROP TABLE IF EXISTS `cages`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cages` (
  `cage_id` int(11) NOT NULL default '0',
  `cage_name` varchar(255) collate utf8_unicode_ci default '',
  `cage_occupied` char(1) collate utf8_unicode_ci default NULL,
  `cage_capacity` int(11) default '5',
  `cage_active` char(1) collate utf8_unicode_ci default NULL,
  `cage_purpose` varchar(255) collate utf8_unicode_ci default NULL,
  `cage_cardcolor` varchar(10) collate utf8_unicode_ci default 'white',
  `cage_user` int(11) default NULL,
  `cage_project` int(11) default NULL,
  PRIMARY KEY  (`cage_id`),
  KEY `cage_occupied` (`cage_occupied`),
  KEY `cage_active` (`cage_active`),
  KEY `cage_purpose` (`cage_purpose`),
  KEY `cage_user` (`cage_user`),
  KEY `cage_project` (`cage_project`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cages2locations`
--

DROP TABLE IF EXISTS `cages2locations`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cages2locations` (
  `c2l_cage_id` int(11) NOT NULL default '0',
  `c2l_location_id` int(11) NOT NULL default '0',
  `c2l_datetime_from` datetime NOT NULL default '0000-00-00 00:00:00',
  `c2l_datetime_to` datetime default NULL,
  `c2l_move_user_id` int(11) default NULL,
  `c2l_move_datetime` datetime default NULL,
  PRIMARY KEY  (`c2l_cage_id`,`c2l_location_id`,`c2l_datetime_from`),
  KEY `c2l_location_id` (`c2l_location_id`),
  KEY `c2l_datetime_from` (`c2l_datetime_from`),
  KEY `c2l_move_user_id` (`c2l_move_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `carts`
--

DROP TABLE IF EXISTS `carts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `carts` (
  `cart_id` int(11) NOT NULL default '0',
  `cart_name` varchar(50) collate utf8_unicode_ci NOT NULL default '',
  `cart_content` text collate utf8_unicode_ci NOT NULL,
  `cart_creation_datetime` datetime default NULL,
  `cart_end_datetime` datetime default NULL,
  `cart_user` int(11) NOT NULL default '0',
  `cart_is_public` char(1) collate utf8_unicode_ci default 'n',
  PRIMARY KEY  (`cart_id`),
  KEY `cart_name` (`cart_name`),
  KEY `cart_user` (`cart_user`),
  KEY `cart_creation_datetime` (`cart_creation_datetime`),
  KEY `cart_end_datetime` (`cart_end_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cohorts`
--

DROP TABLE IF EXISTS `cohorts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cohorts` (
  `cohort_id` int(11) NOT NULL,
  `cohort_name` varchar(255) NOT NULL,
  `cohort_purpose` varchar(15) NOT NULL,
  `cohort_pipeline` int(11) NOT NULL,
  `cohort_description` text,
  `cohort_status` varchar(20) default NULL,
  `cohort_datetime` datetime NOT NULL,
  `cohort_type` varchar(255) default NULL,
  `cohort_reference_cohort` int(11) default NULL,
  PRIMARY KEY  (`cohort_id`),
  KEY `cohort_pipeline` (`cohort_pipeline`),
  KEY `cohort_status` (`cohort_status`),
  KEY `cohort_type` (`cohort_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `contacts`
--

DROP TABLE IF EXISTS `contacts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `contacts` (
  `contact_id` int(11) NOT NULL default '0',
  `contact_is_internal` char(1) collate utf8_unicode_ci NOT NULL default '',
  `contact_title` varchar(20) collate utf8_unicode_ci default NULL,
  `contact_type` char(1) collate utf8_unicode_ci default 'n',
  `contact_function` varchar(100) collate utf8_unicode_ci default NULL,
  `contact_first_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `contact_last_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `contact_sex` char(1) collate utf8_unicode_ci default NULL,
  `contact_emails` varchar(255) collate utf8_unicode_ci default '',
  `contact_comment` text collate utf8_unicode_ci,
  PRIMARY KEY  (`contact_id`),
  KEY `contact_is_internal` (`contact_is_internal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `contacts2addresses`
--

DROP TABLE IF EXISTS `contacts2addresses`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `contacts2addresses` (
  `c2a_contact_id` int(11) NOT NULL default '0',
  `c2a_address_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`c2a_contact_id`,`c2a_address_id`),
  KEY `c2a_address_id` (`c2a_address_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cost_accounts`
--

DROP TABLE IF EXISTS `cost_accounts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cost_accounts` (
  `cost_account_id` int(11) NOT NULL,
  `cost_account_name` varchar(20) NOT NULL,
  `cost_account_number` varchar(10) NOT NULL,
  `cost_account_comment` text NOT NULL,
  PRIMARY KEY  (`cost_account_id`),
  KEY `cost_account_number` (`cost_account_number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `days`
--

DROP TABLE IF EXISTS `days`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `days` (
  `day_number` int(11) NOT NULL default '0',
  `day_date` date NOT NULL default '0000-00-00',
  `day_week_and_year` varchar(7) collate utf8_unicode_ci NOT NULL default '',
  `day_epoch_week` int(11) NOT NULL default '0',
  `day_week_in_year` int(11) NOT NULL default '0',
  `day_year` int(11) NOT NULL default '0',
  `day_week_day_number` int(11) NOT NULL default '0',
  `day_week_day_name_gl` varchar(10) collate utf8_unicode_ci default '',
  `day_week_day_name_gs` varchar(2) collate utf8_unicode_ci default '',
  `day_week_day_name_el` varchar(10) collate utf8_unicode_ci default '',
  `day_week_day_name_es` varchar(2) collate utf8_unicode_ci default '',
  `day_is_holiday` varchar(255) collate utf8_unicode_ci default '',
  PRIMARY KEY  (`day_number`),
  KEY `day_date` (`day_date`),
  KEY `day_epoch_week` (`day_epoch_week`),
  KEY `day_week_in_year` (`day_week_in_year`),
  KEY `day_year` (`day_year`),
  KEY `day_week_day_number` (`day_week_day_number`),
  KEY `day_is_holiday` (`day_is_holiday`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `death_reasons`
--

DROP TABLE IF EXISTS `death_reasons`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `death_reasons` (
  `death_reason_id` int(11) NOT NULL default '0',
  `death_reason_category` varchar(3) collate utf8_unicode_ci NOT NULL default '',
  `death_reason_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `death_reason_description` text collate utf8_unicode_ci,
  PRIMARY KEY  (`death_reason_id`),
  KEY `death_reason_name` (`death_reason_name`),
  KEY `death_reason_category` (`death_reason_category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `embryo_transfers`
--

DROP TABLE IF EXISTS `embryo_transfers`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `embryo_transfers` (
  `transfer_id` int(11) NOT NULL,
  `transfer_mating_id` int(11) default NULL,
  `transfer_embryo_id` varchar(30) default '',
  `transfer_embryo_id_context` varchar(30) default '',
  `transfer_embryo_production` varchar(10) default '',
  `transfer_sperm_preservation` varchar(8) default '',
  `transfer_IVF_assistance` varchar(10) default '',
  `transfer_embryo_preservation` varchar(8) default '',
  `transfer_transgenic_manipulation` varchar(50) default '',
  `transfer_background_donor_cells` varchar(50) default '',
  `transfer_background_ES_cells` varchar(50) default '',
  `transfer_name_of_construct` varchar(50) default '',
  `transfer_comment` text,
  PRIMARY KEY  (`transfer_id`),
  KEY `transfer_mating_id` (`transfer_mating_id`),
  KEY `transfer_embryo_id` (`transfer_embryo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `experiments`
--

DROP TABLE IF EXISTS `experiments`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `experiments` (
  `experiment_id` int(11) NOT NULL default '0',
  `experiment_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `experiment_recordname` varchar(255) collate utf8_unicode_ci default '',
  `experiment_URL` varchar(255) collate utf8_unicode_ci default '',
  `experiment_granted_to_contact` int(11) default NULL,
  `experiment_licence_valid_from` date default NULL,
  `experiment_licence_valid_to` date default NULL,
  `experiment_animalnumber` int(11) default NULL,
  `experiment_is_active` char(1) collate utf8_unicode_ci default 'y',
  PRIMARY KEY  (`experiment_id`),
  KEY `experiment_granted_to_contact` (`experiment_granted_to_contact`),
  KEY `experiment_licence_valid_from` (`experiment_licence_valid_from`),
  KEY `experiment_licence_valid_to` (`experiment_licence_valid_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `externalDBs`
--

DROP TABLE IF EXISTS `externalDBs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `externalDBs` (
  `externalDB_id` int(11) NOT NULL default '0',
  `externalDB_name` varchar(50) collate utf8_unicode_ci default '',
  `externalDB_home_URL` varchar(255) collate utf8_unicode_ci default '',
  `externalDB_query_URL` varchar(255) collate utf8_unicode_ci default '',
  PRIMARY KEY  (`externalDB_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genes`
--

DROP TABLE IF EXISTS `genes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genes` (
  `gene_id` int(11) NOT NULL default '0',
  `gene_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `gene_shortname` varchar(25) collate utf8_unicode_ci NOT NULL default '',
  `gene_description` text collate utf8_unicode_ci,
  `gene_valid_qualifiers` text collate utf8_unicode_ci,
  PRIMARY KEY  (`gene_id`),
  KEY `gene_name` (`gene_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genes2externalDBs`
--

DROP TABLE IF EXISTS `genes2externalDBs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genes2externalDBs` (
  `g2e_gene_id` int(11) NOT NULL default '0',
  `g2e_externalDB_id` int(11) NOT NULL default '0',
  `g2e_description` varchar(255) collate utf8_unicode_ci default '',
  `g2e_id_in_externalDB` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `g2e_externalDB_URL` varchar(255) collate utf8_unicode_ci default NULL,
  `g2e_local_URL` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`g2e_gene_id`,`g2e_externalDB_id`,`g2e_id_in_externalDB`),
  KEY `g2e_externalDB_id` (`g2e_externalDB_id`),
  KEY `g2e_id_in_externalDB` (`g2e_id_in_externalDB`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `healthreport_agents`
--

DROP TABLE IF EXISTS `healthreport_agents`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `healthreport_agents` (
  `agent_id` int(11) NOT NULL,
  `agent_type` varchar(20) NOT NULL,
  `agent_name` varchar(50) NOT NULL,
  `agent_display_order` int(11) default NULL,
  `agent_shortname` varchar(20) NOT NULL,
  `agent_comment` text,
  PRIMARY KEY  (`agent_id`),
  KEY `agent_type` (`agent_type`),
  KEY `agent_name` (`agent_name`),
  KEY `agent_shortname` (`agent_shortname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `healthreports`
--

DROP TABLE IF EXISTS `healthreports`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `healthreports` (
  `healthreport_id` int(11) NOT NULL default '0',
  `healthreport_document_URL` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `healthreport_date` date NOT NULL default '0000-00-00',
  `healthreport_valid_from_date` date NOT NULL default '0000-00-00',
  `healthreport_valid_to_date` date NOT NULL default '0000-00-00',
  `healthreport_status` varchar(20) collate utf8_unicode_ci default NULL,
  `healthreport_comment` text collate utf8_unicode_ci,
  `healthreport_number_of_mice` int(11) default NULL,
  `healthreport_mice` text collate utf8_unicode_ci,
  PRIMARY KEY  (`healthreport_id`),
  KEY `healthreport_valid_from_date` (`healthreport_valid_from_date`),
  KEY `healthreport_valid_to_date` (`healthreport_valid_to_date`),
  KEY `healthreport_status` (`healthreport_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `healthreports2healthreport_agents`
--

DROP TABLE IF EXISTS `healthreports2healthreport_agents`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `healthreports2healthreport_agents` (
  `hr2ha_health_report_id` int(11) NOT NULL,
  `hr2ha_healthreport_agent_id` int(11) NOT NULL,
  `hr2ha_number_of_positive_animals` int(11) NOT NULL,
  PRIMARY KEY  (`hr2ha_health_report_id`,`hr2ha_healthreport_agent_id`),
  KEY `hr2ha_healthreport_agent_id` (`hr2ha_healthreport_agent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `imports`
--

DROP TABLE IF EXISTS `imports`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `imports` (
  `import_id` int(11) NOT NULL default '0',
  `import_group` int(11) NOT NULL default '0',
  `import_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `import_type` varchar(20) collate utf8_unicode_ci NOT NULL default '',
  `import_strain` int(11) NOT NULL default '0',
  `import_line` int(11) NOT NULL default '0',
  `import_datetime` datetime default NULL,
  `import_owner_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `import_provider_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `import_provider_contact` int(11) default NULL,
  `import_coach_user` int(11) default NULL,
  `import_purpose` varchar(255) collate utf8_unicode_ci default NULL,
  `import_origin_code` varchar(20) collate utf8_unicode_ci default NULL,
  `import_origin_location` int(11) default NULL,
  `import_project` int(11) NOT NULL default '0',
  `import_checkcode` varchar(20) collate utf8_unicode_ci default NULL,
  `import_healthreport` int(11) default NULL,
  `import_comment` text collate utf8_unicode_ci,
  PRIMARY KEY  (`import_id`),
  KEY `import_group` (`import_group`),
  KEY `import_type` (`import_type`),
  KEY `import_strain` (`import_strain`),
  KEY `import_line` (`import_line`),
  KEY `import_datetime` (`import_datetime`),
  KEY `import_provider_contact` (`import_provider_contact`),
  KEY `import_coach_user` (`import_coach_user`),
  KEY `import_purpose` (`import_purpose`),
  KEY `import_origin_code` (`import_origin_code`),
  KEY `import_project` (`import_project`),
  KEY `import_checkcode` (`import_checkcode`),
  KEY `import_healthreport` (`import_healthreport`),
  KEY `import_origin_location` (`import_origin_location`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `imports2contacts`
--

DROP TABLE IF EXISTS `imports2contacts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `imports2contacts` (
  `i2c_import_id` int(11) NOT NULL default '0',
  `i2c_contact_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`i2c_import_id`,`i2c_contact_id`),
  KEY `i2c_contact_id` (`i2c_contact_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `line2blob_data`
--

DROP TABLE IF EXISTS `line2blob_data`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `line2blob_data` (
  `l2b_line_id` int(11) NOT NULL,
  `l2b_blob_id` int(11) NOT NULL,
  PRIMARY KEY  (`l2b_line_id`,`l2b_blob_id`),
  KEY `l2b_blob_id` (`l2b_blob_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `litters`
--

DROP TABLE IF EXISTS `litters`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `litters` (
  `litter_id` int(11) NOT NULL default '0',
  `litter_mating_id` int(11) NOT NULL default '0',
  `litter_in_mating` int(11) NOT NULL default '0',
  `litter_born_datetime` datetime default NULL,
  `litter_alive_total` int(11) default NULL,
  `litter_alive_male` int(11) default NULL,
  `litter_alive_female` int(11) default NULL,
  `litter_dead_total` int(11) default NULL,
  `litter_dead_male` int(11) default NULL,
  `litter_dead_female` int(11) default NULL,
  `litter_reduced` int(11) default NULL,
  `litter_reduced_reason` varchar(255) collate utf8_unicode_ci default NULL,
  `litter_weaning_datetime` datetime default NULL,
  `litter_comment` text collate utf8_unicode_ci,
  PRIMARY KEY  (`litter_id`),
  KEY `litter_mating_id` (`litter_mating_id`),
  KEY `litter_in_mating` (`litter_in_mating`),
  KEY `litter_born_datetime` (`litter_born_datetime`),
  KEY `litter_weaning_datetime` (`litter_weaning_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `litters2parents`
--

DROP TABLE IF EXISTS `litters2parents`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `litters2parents` (
  `l2p_litter_id` int(11) NOT NULL default '0',
  `l2p_parent_id` int(11) NOT NULL default '0',
  `l2p_parent_type` varchar(20) collate utf8_unicode_ci NOT NULL default '',
  `l2p_evidence` char(1) collate utf8_unicode_ci NOT NULL default '',
  PRIMARY KEY  (`l2p_litter_id`,`l2p_parent_id`),
  KEY `l2p_parent_id` (`l2p_parent_id`),
  KEY `l2p_parent_type` (`l2p_parent_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `locations` (
  `location_id` int(11) NOT NULL default '0',
  `location_name` varchar(255) collate utf8_unicode_ci default '',
  `location_code` varchar(20) collate utf8_unicode_ci default '',
  `location_is_internal` char(1) collate utf8_unicode_ci NOT NULL default '',
  `location_address` int(11) default NULL,
  `location_building` varchar(255) collate utf8_unicode_ci default NULL,
  `location_subbuilding` varchar(255) collate utf8_unicode_ci default NULL,
  `location_room` varchar(255) collate utf8_unicode_ci default NULL,
  `location_rack` varchar(255) collate utf8_unicode_ci default NULL,
  `location_subrack` varchar(255) collate utf8_unicode_ci default NULL,
  `location_capacity` int(11) default NULL,
  `location_is_active` char(1) collate utf8_unicode_ci default NULL,
  `location_project` int(11) NOT NULL default '0',
  `location_display_order` int(11) NOT NULL default '0',
  `location_comment` text collate utf8_unicode_ci,
  PRIMARY KEY  (`location_id`),
  KEY `location_name` (`location_name`),
  KEY `location_code` (`location_code`),
  KEY `location_is_internal` (`location_is_internal`),
  KEY `location_address` (`location_address`),
  KEY `location_building` (`location_building`),
  KEY `location_subbuilding` (`location_subbuilding`),
  KEY `location_room` (`location_room`),
  KEY `location_rack` (`location_rack`),
  KEY `location_subrack` (`location_subrack`),
  KEY `location_is_active` (`location_is_active`),
  KEY `location_project` (`location_project`),
  KEY `location_display_order` (`location_display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `locations2healthreports`
--

DROP TABLE IF EXISTS `locations2healthreports`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `locations2healthreports` (
  `l2h_location_id` int(11) NOT NULL,
  `l2h_healthreport_id` int(11) NOT NULL,
  PRIMARY KEY  (`l2h_location_id`,`l2h_healthreport_id`),
  KEY `l2h_healthreport_id` (`l2h_healthreport_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `log_access`
--

DROP TABLE IF EXISTS `log_access`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `log_access` (
  `log_id` int(11) NOT NULL auto_increment,
  `log_user_id` int(11) NOT NULL default '0',
  `log_user_name` varchar(50) collate utf8_unicode_ci NOT NULL default '',
  `log_datetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `log_remote_host` varchar(50) collate utf8_unicode_ci NOT NULL default '',
  `log_remote_IP` varchar(16) collate utf8_unicode_ci NOT NULL default '',
  `log_choice` text collate utf8_unicode_ci NOT NULL,
  `log_parameters` text collate utf8_unicode_ci NOT NULL,
  PRIMARY KEY  (`log_id`),
  KEY `log_access_user_id` (`log_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=346321 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `log_uploads`
--

DROP TABLE IF EXISTS `log_uploads`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `log_uploads` (
  `log_id` int(11) NOT NULL auto_increment,
  `log_user_id` int(11) default '0',
  `log_user_name` varchar(50) collate utf8_unicode_ci default '',
  `log_datetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `log_upload_filename` varchar(50) collate utf8_unicode_ci NOT NULL default '',
  `log_local_filename` varchar(50) collate utf8_unicode_ci NOT NULL default '',
  `log_remote_IP` varchar(16) collate utf8_unicode_ci default '',
  PRIMARY KEY  (`log_id`),
  KEY `log_upload_user_id` (`log_user_id`),
  KEY `log_upload_datetime` (`log_datetime`),
  KEY `log_upload_remote_IP` (`log_remote_IP`)
) ENGINE=InnoDB AUTO_INCREMENT=9320 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `matings`
--

DROP TABLE IF EXISTS `matings`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `matings` (
  `mating_id` int(11) NOT NULL default '0',
  `mating_name` varchar(255) collate utf8_unicode_ci default '',
  `mating_type` varchar(20) collate utf8_unicode_ci default NULL,
  `mating_matingstart_datetime` datetime default NULL,
  `mating_matingend_datetime` datetime default NULL,
  `mating_strain` int(11) NOT NULL default '0',
  `mating_line` int(11) NOT NULL default '0',
  `mating_scheme` varchar(255) collate utf8_unicode_ci default '',
  `mating_purpose` varchar(255) collate utf8_unicode_ci default '',
  `mating_project` int(11) NOT NULL default '0',
  `mating_generation` varchar(20) collate utf8_unicode_ci default '',
  `mating_comment` text collate utf8_unicode_ci,
  PRIMARY KEY  (`mating_id`),
  KEY `mating_name` (`mating_name`),
  KEY `mating_matingstart_datetime` (`mating_matingstart_datetime`),
  KEY `mating_matingend_datetime` (`mating_matingend_datetime`),
  KEY `mating_strain` (`mating_strain`),
  KEY `mating_line` (`mating_line`),
  KEY `mating_scheme` (`mating_scheme`),
  KEY `mating_purpose` (`mating_purpose`),
  KEY `mating_project` (`mating_project`),
  KEY `mating_generation` (`mating_generation`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `medical_records`
--

DROP TABLE IF EXISTS `medical_records`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `medical_records` (
  `mr_id` int(11) NOT NULL default '0',
  `mr_parent_mr_group` int(11) NOT NULL default '0',
  `mr_tupel_id` int(11) NOT NULL default '0',
  `mr_is_dependent` char(1) collate utf8_unicode_ci NOT NULL default '',
  `mr_increment_value` varchar(20) collate utf8_unicode_ci default NULL,
  `mr_increment_unit` varchar(20) collate utf8_unicode_ci default NULL,
  `mr_serial_order` int(11) NOT NULL default '0',
  `mr_category` varchar(255) collate utf8_unicode_ci default NULL,
  `mr_project_id` int(11) NOT NULL default '0',
  `mr_orderlist_id` int(11) default NULL,
  `mr_parameterset_id` int(11) default NULL,
  `mr_parameter` int(11) NOT NULL default '0',
  `mr_integer` int(11) default NULL,
  `mr_float` float default NULL,
  `mr_bool` char(1) collate utf8_unicode_ci default NULL,
  `mr_text` longtext collate utf8_unicode_ci,
  `mr_source_id` int(11) default '0',
  `mr_blob_id` int(11) default NULL,
  `mr_responsible_user` int(11) NOT NULL default '0',
  `mr_measure_user` int(11) NOT NULL default '0',
  `mr_is_public` char(1) collate utf8_unicode_ci NOT NULL default '',
  `mr_quality` varchar(20) collate utf8_unicode_ci default 'ok',
  `mr_is_outside_normal_range` char(1) collate utf8_unicode_ci default NULL,
  `mr_probetaken_datetime` datetime default NULL,
  `mr_measure_datetime` datetime default NULL,
  `mr_status` varchar(20) collate utf8_unicode_ci default NULL,
  `mr_comment` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`mr_id`),
  KEY `mr_parent_mr_group` (`mr_parent_mr_group`),
  KEY `mr_tupel_id` (`mr_tupel_id`),
  KEY `mr_is_dependent` (`mr_is_dependent`),
  KEY `mr_serial_order` (`mr_serial_order`),
  KEY `mr_category` (`mr_category`),
  KEY `mr_project_id` (`mr_project_id`),
  KEY `mr_orderlist_id` (`mr_orderlist_id`),
  KEY `mr_parameterset_id` (`mr_parameterset_id`),
  KEY `mr_parameter` (`mr_parameter`),
  KEY `mr_integer` (`mr_integer`),
  KEY `mr_float` (`mr_float`),
  KEY `mr_bool` (`mr_bool`),
  KEY `mr_text` (`mr_text`(30)),
  KEY `mr_source_id` (`mr_source_id`),
  KEY `mr_blob_id` (`mr_blob_id`),
  KEY `mr_responsible_user` (`mr_responsible_user`),
  KEY `mr_measure_user` (`mr_measure_user`),
  KEY `mr_is_public` (`mr_is_public`),
  KEY `mr_quality` (`mr_quality`),
  KEY `mr_is_outside_normal_range` (`mr_is_outside_normal_range`),
  KEY `mr_comment` (`mr_comment`),
  KEY `mr_status` (`mr_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `medical_records2sops`
--

DROP TABLE IF EXISTS `medical_records2sops`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `medical_records2sops` (
  `mr2s_mr_id` int(11) NOT NULL default '0',
  `mr2s_sop_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`mr2s_mr_id`,`mr2s_sop_id`),
  KEY `mr2s_sop_id` (`mr2s_sop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `metadata`
--

DROP TABLE IF EXISTS `metadata`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `metadata` (
  `metadata_id` int(11) NOT NULL,
  `metadata_mdd_id` int(11) NOT NULL,
  `metadata_value` text NOT NULL,
  `metadata_orderlist_id` int(11) default NULL,
  `metadata_medical_record_id` int(11) default NULL,
  `metadata_mouse_id` int(11) default NULL,
  `metadata_parameterset_id` int(11) default NULL,
  `metadata_valid_datetime_from` datetime default NULL,
  `metadata_valid_datetime_to` datetime default NULL,
  PRIMARY KEY  (`metadata_id`),
  KEY `metadata_mdd_id` (`metadata_mdd_id`),
  KEY `metadata_orderlist_id` (`metadata_orderlist_id`),
  KEY `metadata_medical_record_id` (`metadata_medical_record_id`),
  KEY `metadata_parameterset_id` (`metadata_parameterset_id`),
  KEY `metadata_valid_datetime_from` (`metadata_valid_datetime_from`),
  KEY `metadata_valid_datetime_to` (`metadata_valid_datetime_to`),
  KEY `metadata_mouse_id` (`metadata_mouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `metadata_definitions`
--

DROP TABLE IF EXISTS `metadata_definitions`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `metadata_definitions` (
  `mdd_id` int(11) NOT NULL,
  `mdd_name` varchar(255) NOT NULL,
  `mdd_shortname` varchar(20) NOT NULL,
  `mdd_type` char(1) NOT NULL,
  `mdd_decimals` int(11) default NULL,
  `mdd_unit` varchar(255) default NULL,
  `mdd_default` varchar(255) default NULL,
  `mdd_possible_values` text,
  `mdd_global_yn` char(1) NOT NULL,
  `mdd_active_yn` char(1) NOT NULL,
  `mdd_required` varchar(1) default 'n',
  `mdd_parameterset_id` int(11) default NULL,
  `mdd_parameter_id` int(11) default NULL,
  `mdd_description` text,
  PRIMARY KEY  (`mdd_id`),
  KEY `mdd_global_yn` (`mdd_global_yn`),
  KEY `mdd_active_yn` (`mdd_active_yn`),
  KEY `mdd_parameterset_id` (`mdd_parameterset_id`),
  KEY `mdd_parameter_id` (`mdd_parameter_id`),
  KEY `mdd_required` (`mdd_required`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice`
--

DROP TABLE IF EXISTS `mice`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice` (
  `mouse_id` int(11) NOT NULL default '0',
  `mouse_earmark` varchar(10) collate utf8_unicode_ci default '',
  `mouse_origin_type` varchar(16) collate utf8_unicode_ci NOT NULL default '',
  `mouse_litter_id` int(11) default '0',
  `mouse_import_id` int(11) default '0',
  `mouse_import_litter_group` int(11) default NULL,
  `mouse_sex` char(1) collate utf8_unicode_ci NOT NULL default '',
  `mouse_strain` int(11) NOT NULL default '0',
  `mouse_line` int(11) NOT NULL default '0',
  `mouse_generation` varchar(20) collate utf8_unicode_ci default NULL,
  `mouse_batch` varchar(2) collate utf8_unicode_ci default NULL,
  `mouse_coat_color` int(11) default NULL,
  `mouse_birth_datetime` datetime default NULL,
  `mouse_deathorexport_datetime` datetime default NULL,
  `mouse_deathorexport_how` int(11) NOT NULL default '0',
  `mouse_deathorexport_why` int(11) NOT NULL default '0',
  `mouse_deathorexport_contact` int(11) default NULL,
  `mouse_deathorexport_location` int(11) default NULL,
  `mouse_is_gvo` char(1) collate utf8_unicode_ci default NULL,
  `mouse_is_mutant` char(1) collate utf8_unicode_ci default NULL,
  `mouse_comment` text collate utf8_unicode_ci,
  PRIMARY KEY  (`mouse_id`),
  KEY `mouse_origin_type` (`mouse_origin_type`),
  KEY `mouse_litter_id` (`mouse_litter_id`),
  KEY `mouse_import_id` (`mouse_import_id`),
  KEY `mouse_sex` (`mouse_sex`),
  KEY `mouse_strain` (`mouse_strain`),
  KEY `mouse_line` (`mouse_line`),
  KEY `mouse_generation` (`mouse_generation`),
  KEY `mouse_coat_color` (`mouse_coat_color`),
  KEY `mouse_birth_datetime` (`mouse_birth_datetime`),
  KEY `mouse_deathorexport_datetime` (`mouse_deathorexport_datetime`),
  KEY `mouse_deathorexport_how` (`mouse_deathorexport_how`),
  KEY `mouse_deathorexport_why` (`mouse_deathorexport_why`),
  KEY `mouse_deathorexport_contact` (`mouse_deathorexport_contact`),
  KEY `mouse_deathorexport_location` (`mouse_deathorexport_location`),
  KEY `mouse_is_gvo` (`mouse_is_gvo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2blob_data`
--

DROP TABLE IF EXISTS `mice2blob_data`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2blob_data` (
  `m2b_mouse_id` int(11) NOT NULL,
  `m2b_blob_id` int(11) NOT NULL,
  `m2b_mouse_role` varchar(20) NOT NULL,
  PRIMARY KEY  (`m2b_mouse_id`,`m2b_blob_id`),
  KEY `m2b_blob_id` (`m2b_blob_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2cages`
--

DROP TABLE IF EXISTS `mice2cages`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2cages` (
  `m2c_mouse_id` int(11) NOT NULL default '0',
  `m2c_cage_id` int(11) NOT NULL default '0',
  `m2c_cage_of_this_mouse` int(11) NOT NULL default '0',
  `m2c_datetime_from` datetime NOT NULL default '0000-00-00 00:00:00',
  `m2c_datetime_to` datetime default NULL,
  `m2c_move_user_id` int(11) default NULL,
  `m2c_move_datetime` datetime default NULL,
  PRIMARY KEY  (`m2c_mouse_id`,`m2c_cage_id`,`m2c_datetime_from`),
  KEY `m2c_cage_id` (`m2c_cage_id`),
  KEY `m2c_cage_of_this_mouse` (`m2c_cage_of_this_mouse`),
  KEY `m2c_datetime_to` (`m2c_datetime_to`),
  KEY `m2c_move_user_id` (`m2c_move_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2cohorts`
--

DROP TABLE IF EXISTS `mice2cohorts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2cohorts` (
  `m2co_mouse_id` int(11) NOT NULL,
  `m2co_cohort_id` int(11) NOT NULL,
  PRIMARY KEY  (`m2co_mouse_id`,`m2co_cohort_id`),
  KEY `m2co_cohort_id` (`m2co_cohort_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2cost_accounts`
--

DROP TABLE IF EXISTS `mice2cost_accounts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2cost_accounts` (
  `m2ca_mouse_id` int(11) NOT NULL,
  `m2ca_cost_account_id` int(11) NOT NULL,
  `m2ca_datetime_from` datetime NOT NULL default '0000-00-00 00:00:00',
  `m2ca_datetime_to` datetime default NULL,
  PRIMARY KEY  (`m2ca_mouse_id`,`m2ca_cost_account_id`,`m2ca_datetime_from`),
  KEY `m2ca_cost_account_id` (`m2ca_cost_account_id`),
  KEY `m2ca_datetime_to` (`m2ca_datetime_to`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2experiments`
--

DROP TABLE IF EXISTS `mice2experiments`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2experiments` (
  `m2e_experiment_id` int(11) NOT NULL default '0',
  `m2e_mouse_id` int(11) NOT NULL default '0',
  `m2e_datetime_from` datetime NOT NULL default '0000-00-00 00:00:00',
  `m2e_datetime_to` datetime default NULL,
  `m2e_inserted_by` int(11) default '0',
  `m2e_inserted_at` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`m2e_experiment_id`,`m2e_mouse_id`,`m2e_datetime_from`),
  KEY `m2e_mouse_id` (`m2e_mouse_id`),
  KEY `m2e_datetime_from` (`m2e_datetime_from`),
  KEY `m2e_datetime_to` (`m2e_datetime_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2genes`
--

DROP TABLE IF EXISTS `mice2genes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2genes` (
  `m2g_mouse_id` int(11) NOT NULL default '0',
  `m2g_gene_id` int(11) NOT NULL default '0',
  `m2g_gene_order` int(11) NOT NULL default '0',
  `m2g_genotype_date` date default NULL,
  `m2g_genotype` varchar(30) collate utf8_unicode_ci NOT NULL default 'unknown',
  `m2g_genotype_method` varchar(20) collate utf8_unicode_ci default 'PCR',
  PRIMARY KEY  (`m2g_mouse_id`,`m2g_gene_id`,`m2g_genotype`),
  KEY `m2g_gene_id` (`m2g_gene_id`),
  KEY `m2g_genotype` (`m2g_genotype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2healthreports`
--

DROP TABLE IF EXISTS `mice2healthreports`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2healthreports` (
  `m2h_mouse_id` int(11) NOT NULL default '0',
  `m2h_healthreport_id` int(11) NOT NULL default '0',
  `m2h_evidence_type` varchar(10) collate utf8_unicode_ci NOT NULL default '',
  PRIMARY KEY  (`m2h_mouse_id`,`m2h_healthreport_id`),
  KEY `m2h_healthreport_id` (`m2h_healthreport_id`),
  KEY `m2h_evidence_type` (`m2h_evidence_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2medical_records`
--

DROP TABLE IF EXISTS `mice2medical_records`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2medical_records` (
  `m2mr_mouse_id` int(11) NOT NULL default '0',
  `m2mr_mr_id` int(11) NOT NULL default '0',
  `m2mr_mouse_role` varchar(20) collate utf8_unicode_ci NOT NULL default '',
  PRIMARY KEY  (`m2mr_mouse_id`,`m2mr_mr_id`),
  KEY `m2mr_mr_id` (`m2mr_mr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2mousegroups`
--

DROP TABLE IF EXISTS `mice2mousegroups`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2mousegroups` (
  `m2m_mouse_id` int(11) NOT NULL default '0',
  `m2m_mousegroup_id` int(11) NOT NULL default '0',
  `m2m_added_datetime` datetime default NULL,
  PRIMARY KEY  (`m2m_mouse_id`,`m2m_mousegroup_id`),
  KEY `m2m_mousegroup_id` (`m2m_mousegroup_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2orderlists`
--

DROP TABLE IF EXISTS `mice2orderlists`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2orderlists` (
  `m2o_mouse_id` int(11) NOT NULL default '0',
  `m2o_orderlist_id` int(11) NOT NULL default '0',
  `m2o_listposition` int(11) default '0',
  `m2o_status` varchar(20) collate utf8_unicode_ci default 'waiting',
  `m2o_added_datetime` datetime default NULL,
  PRIMARY KEY  (`m2o_mouse_id`,`m2o_orderlist_id`),
  KEY `m2o_orderlist_id` (`m2o_orderlist_id`),
  KEY `m2o_listposition` (`m2o_listposition`),
  KEY `m2o_status` (`m2o_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2phenotypesDB`
--

DROP TABLE IF EXISTS `mice2phenotypesDB`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2phenotypesDB` (
  `m2p_mouse_id` int(11) NOT NULL default '0',
  `m2p_externalDB_id` int(11) NOT NULL default '0',
  `m2p_phenotypeID_in_externalDB` varchar(30) collate utf8_unicode_ci NOT NULL default '',
  `m2p_externalDB_URL` varchar(255) collate utf8_unicode_ci default NULL,
  `m2p_local_URL` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`m2p_mouse_id`,`m2p_externalDB_id`,`m2p_phenotypeID_in_externalDB`),
  KEY `m2p_phenotypeID_in_externalDB` (`m2p_phenotypeID_in_externalDB`),
  KEY `m2p_externalDB_id` (`m2p_externalDB_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2projects`
--

DROP TABLE IF EXISTS `mice2projects`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2projects` (
  `m2p_mouse_id` int(11) NOT NULL default '0',
  `m2p_project_id` int(11) NOT NULL default '0',
  `m2p_date_from` date default NULL,
  `m2p_date_to` date default NULL,
  PRIMARY KEY  (`m2p_mouse_id`,`m2p_project_id`),
  KEY `m2p_project_id` (`m2p_project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2properties`
--

DROP TABLE IF EXISTS `mice2properties`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2properties` (
  `m2pr_mouse_id` int(11) NOT NULL default '0',
  `m2pr_property_id` int(11) NOT NULL default '0',
  `m2pr_datetime` datetime NOT NULL default '0000-00-00 00:00:00',
  `m2pr_user` int(11) NOT NULL default '0',
  PRIMARY KEY  (`m2pr_mouse_id`,`m2pr_property_id`,`m2pr_datetime`,`m2pr_user`),
  KEY `m2pr_property_id` (`m2pr_property_id`),
  KEY `m2pr_user` (`m2pr_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice2treatment_procedures`
--

DROP TABLE IF EXISTS `mice2treatment_procedures`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice2treatment_procedures` (
  `m2tp_id` int(11) NOT NULL auto_increment,
  `m2tp_mouse_id` int(11) NOT NULL,
  `m2tp_treatment_procedure_id` int(11) NOT NULL,
  `m2tp_treatment_datetime` datetime NOT NULL,
  `m2tp_applied_amount` float NOT NULL,
  `m2tp_applied_amount_unit` varchar(20) NOT NULL,
  `m2tp_application_start_datetime` datetime NOT NULL,
  `m2tp_application_end_datetime` datetime NOT NULL,
  `m2tp_treatment_success` char(1) NOT NULL,
  `m2tp_application_terminated_why` varchar(255) NOT NULL,
  `m2tp_treatment_user_id` int(11) NOT NULL,
  `m2tp_application_comment` text NOT NULL,
  PRIMARY KEY  (`m2tp_id`),
  KEY `m2tp_mouse_id` (`m2tp_mouse_id`),
  KEY `m2tp_treatment_procedure_id` (`m2tp_treatment_procedure_id`),
  KEY `m2tp_treatment_user_id` (`m2tp_treatment_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mice_cage_rack_placements`
--

DROP TABLE IF EXISTS `mice_cage_rack_placements`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mice_cage_rack_placements` (
  `mcrp_placement_id` int(11) NOT NULL auto_increment,
  `mcrp_mouse_id` int(11) NOT NULL,
  `mcrp_cage_of_mouse` int(11) default NULL,
  `mcrp_cage_id` int(11) NOT NULL,
  `mcrp_cage_from` datetime default NULL,
  `mcrp_cage_to` datetime default NULL,
  `mcrp_rack_id` int(11) default NULL,
  `mcrp_rack_room` varchar(20) default NULL,
  `mcrp_rack_name` varchar(20) default NULL,
  `mcrp_rack_from` datetime default NULL,
  `mcrp_rack_to` datetime default NULL,
  PRIMARY KEY  (`mcrp_placement_id`),
  KEY `mcrp_mouse_id` (`mcrp_mouse_id`),
  KEY `mcrp_cage_id` (`mcrp_cage_id`),
  KEY `mcrp_rack_id` (`mcrp_rack_id`),
  KEY `mcrp_rack_room` (`mcrp_rack_room`)
) ENGINE=MyISAM AUTO_INCREMENT=346456 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mouse_coat_colors`
--

DROP TABLE IF EXISTS `mouse_coat_colors`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mouse_coat_colors` (
  `coat_color_id` int(11) NOT NULL default '0',
  `coat_color_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `coat_color_description` text collate utf8_unicode_ci,
  PRIMARY KEY  (`coat_color_id`),
  KEY `coat_color_name` (`coat_color_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mouse_lines`
--

DROP TABLE IF EXISTS `mouse_lines`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mouse_lines` (
  `line_id` int(11) NOT NULL default '0',
  `line_name` varchar(50) collate utf8_unicode_ci NOT NULL default '',
  `line_long_name` varchar(50) collate utf8_unicode_ci NOT NULL default '',
  `line_order` int(11) default NULL,
  `line_show` char(1) collate utf8_unicode_ci default 'y',
  `line_info_URL` varchar(255) collate utf8_unicode_ci default '',
  `line_comment` text collate utf8_unicode_ci,
  PRIMARY KEY  (`line_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mouse_lines2genes`
--

DROP TABLE IF EXISTS `mouse_lines2genes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mouse_lines2genes` (
  `ml2g_mouse_line_id` int(11) NOT NULL default '0',
  `ml2g_gene_id` int(11) NOT NULL default '0',
  `ml2g_gene_order` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ml2g_mouse_line_id`,`ml2g_gene_id`),
  KEY `ml2g_gene_id` (`ml2g_gene_id`),
  KEY `ml2g_gene_order` (`ml2g_gene_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mouse_strains`
--

DROP TABLE IF EXISTS `mouse_strains`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mouse_strains` (
  `strain_id` int(11) NOT NULL default '0',
  `strain_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `strain_order` int(11) default NULL,
  `strain_show` char(1) collate utf8_unicode_ci default 'y',
  `strain_description` text collate utf8_unicode_ci,
  PRIMARY KEY  (`strain_id`),
  KEY `strain_name` (`strain_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mousegroups`
--

DROP TABLE IF EXISTS `mousegroups`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mousegroups` (
  `mousegroup_id` int(11) NOT NULL default '0',
  `mousegroup_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `mousegroup_purpose` varchar(15) collate utf8_unicode_ci NOT NULL default '',
  `mousegroup_show` char(1) collate utf8_unicode_ci NOT NULL default '',
  `mousegroup_description` text collate utf8_unicode_ci,
  `mousegroup_user` int(11) NOT NULL default '0',
  `mousegroup_datetime` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`mousegroup_id`),
  KEY `mousegroup_user` (`mousegroup_user`),
  KEY `mousegroup_purpose` (`mousegroup_purpose`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mylocks`
--

DROP TABLE IF EXISTS `mylocks`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mylocks` (
  `mylock_id` int(11) NOT NULL default '0',
  `mylock_value` char(8) collate utf8_unicode_ci NOT NULL default '',
  `mylock_session` char(32) collate utf8_unicode_ci NOT NULL default '',
  `mylock_user_id` int(11) NOT NULL default '0',
  `mylock_datetime` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`mylock_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `orderlists`
--

DROP TABLE IF EXISTS `orderlists`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `orderlists` (
  `orderlist_id` int(11) NOT NULL default '0',
  `orderlist_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `orderlist_created_by` int(11) NOT NULL default '0',
  `orderlist_date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `orderlist_job` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `orderlist_sampletype` varchar(20) collate utf8_unicode_ci default NULL,
  `orderlist_sample_amount` varchar(20) collate utf8_unicode_ci default NULL,
  `orderlist_date_scheduled` date NOT NULL default '0000-00-00',
  `orderlist_assigned_user` int(11) NOT NULL default '0',
  `orderlist_parameterset` int(11) NOT NULL default '0',
  `orderlist_status` varchar(20) collate utf8_unicode_ci default 'waiting',
  `orderlist_comment` text collate utf8_unicode_ci,
  PRIMARY KEY  (`orderlist_id`),
  KEY `orderlist_created_by` (`orderlist_created_by`),
  KEY `orderlist_date_scheduled` (`orderlist_date_scheduled`),
  KEY `orderlist_parameterset` (`orderlist_parameterset`),
  KEY `orderlist_job` (`orderlist_job`),
  KEY `orderlist_status` (`orderlist_status`),
  KEY `orderlist_assigned_user` (`orderlist_assigned_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `parameters`
--

DROP TABLE IF EXISTS `parameters`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `parameters` (
  `parameter_id` int(11) NOT NULL default '0',
  `parameter_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `parameter_shortname` varchar(20) collate utf8_unicode_ci NOT NULL default '',
  `parameter_type` char(1) collate utf8_unicode_ci NOT NULL default '',
  `parameter_decimals` int(11) default NULL,
  `parameter_unit` varchar(255) collate utf8_unicode_ci default NULL,
  `parameter_description` text collate utf8_unicode_ci,
  `parameter_default` varchar(255) collate utf8_unicode_ci default NULL,
  `parameter_choose_list` text collate utf8_unicode_ci,
  `parameter_normal_range` varchar(255) collate utf8_unicode_ci default '',
  `parameter_is_metadata` char(1) collate utf8_unicode_ci default 'n',
  PRIMARY KEY  (`parameter_id`),
  KEY `parameter_name` (`parameter_name`),
  KEY `parameter_shortname` (`parameter_shortname`),
  KEY `parameter_type` (`parameter_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `parametersets`
--

DROP TABLE IF EXISTS `parametersets`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `parametersets` (
  `parameterset_id` int(11) NOT NULL auto_increment,
  `parameterset_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `parameterset_description` text collate utf8_unicode_ci,
  `parameterset_project_id` int(11) NOT NULL default '0',
  `parameterset_class` int(11) NOT NULL default '0',
  `parameterset_display_order` int(11) NOT NULL default '0',
  `parameterset_version` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `parameterset_version_datetime` datetime NOT NULL default '0000-00-00 00:00:00',
  `parameterset_is_active` char(1) collate utf8_unicode_ci default 'y',
  PRIMARY KEY  (`parameterset_id`),
  KEY `parameterset_name` (`parameterset_name`),
  KEY `parameterset_project_id` (`parameterset_project_id`),
  KEY `parameterset_class` (`parameterset_class`),
  KEY `parameterset_display_order` (`parameterset_display_order`),
  KEY `parameterset_is_active` (`parameterset_is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=161 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `parametersets2parameters`
--

DROP TABLE IF EXISTS `parametersets2parameters`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `parametersets2parameters` (
  `p2p_parameterset_id` int(11) NOT NULL default '0',
  `p2p_parameter_id` int(11) NOT NULL default '0',
  `p2p_display_row` int(11) default '0',
  `p2p_display_column` int(11) default '1',
  `p2p_upload_column` int(11) NOT NULL,
  `p2p_upload_column_name` varchar(100) collate utf8_unicode_ci default NULL,
  `p2p_parameter_category` varchar(20) collate utf8_unicode_ci default 'simple',
  `p2p_increment_value` varchar(20) collate utf8_unicode_ci NOT NULL default 'simple',
  `p2p_increment_unit` varchar(20) collate utf8_unicode_ci default NULL,
  `p2p_parameter_required` char(1) collate utf8_unicode_ci NOT NULL default 'y',
  PRIMARY KEY  (`p2p_parameterset_id`,`p2p_parameter_id`,`p2p_increment_value`),
  KEY `p2p_parameter_id` (`p2p_parameter_id`),
  KEY `p2p_display_row` (`p2p_display_row`),
  KEY `p2p_display_column` (`p2p_display_column`),
  KEY `p2p_parameter_category` (`p2p_parameter_category`),
  KEY `p2p_parameter_required` (`p2p_parameter_required`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `parent_strains2litter_strain`
--

DROP TABLE IF EXISTS `parent_strains2litter_strain`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `parent_strains2litter_strain` (
  `ps2ls_mother_strain` int(11) NOT NULL,
  `ps2ls_father_strain` int(11) NOT NULL,
  `ps2ls_litter_strain` int(11) NOT NULL,
  PRIMARY KEY  (`ps2ls_mother_strain`,`ps2ls_father_strain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `parents2matings`
--

DROP TABLE IF EXISTS `parents2matings`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `parents2matings` (
  `p2m_mating_id` int(11) NOT NULL default '0',
  `p2m_parent_id` int(11) NOT NULL default '0',
  `p2m_parent_type` varchar(20) collate utf8_unicode_ci NOT NULL default '',
  `p2m_parent_start_date` datetime default NULL,
  `p2m_parent_end_date` datetime default NULL,
  PRIMARY KEY  (`p2m_mating_id`,`p2m_parent_id`),
  KEY `p2m_parent_id` (`p2m_parent_id`),
  KEY `p2m_parent_type` (`p2m_parent_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `pressure_table`
--

DROP TABLE IF EXISTS `pressure_table`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `pressure_table` (
  `mline` varchar(100) default NULL,
  `mouse_id` int(11) default NULL,
  `sex` varchar(1) default NULL,
  `genotype` varchar(50) default NULL,
  `orderlist` int(11) default NULL,
  `sys` float default NULL,
  `pulse` float default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `projects` (
  `project_id` int(11) NOT NULL default '0',
  `project_name` varchar(50) collate utf8_unicode_ci NOT NULL default '',
  `project_shortname` varchar(10) collate utf8_unicode_ci NOT NULL default '',
  `project_description` text collate utf8_unicode_ci,
  `project_parent_project` int(11) default NULL,
  `project_owner` int(11) NOT NULL default '0',
  PRIMARY KEY  (`project_id`),
  KEY `project_shortname` (`project_shortname`),
  KEY `project_parent_project` (`project_parent_project`),
  KEY `project_owner` (`project_owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `properties`
--

DROP TABLE IF EXISTS `properties`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `properties` (
  `property_id` int(11) NOT NULL auto_increment,
  `property_category` varchar(20) collate utf8_unicode_ci NOT NULL default '',
  `property_key` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `property_type` varchar(10) collate utf8_unicode_ci NOT NULL default '',
  `property_value_integer` int(11) default NULL,
  `property_value_bool` char(1) collate utf8_unicode_ci default NULL,
  `property_value_float` float default NULL,
  `property_value_text` text collate utf8_unicode_ci,
  PRIMARY KEY  (`property_id`),
  KEY `property_key` (`property_key`),
  KEY `property_type` (`property_type`),
  KEY `property_category` (`property_category`)
) ENGINE=InnoDB AUTO_INCREMENT=59022 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `settings` (
  `setting_id` int(11) NOT NULL auto_increment,
  `setting_category` varchar(100) collate utf8_unicode_ci NOT NULL default '',
  `setting_item` varchar(100) collate utf8_unicode_ci NOT NULL default '',
  `setting_key` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `setting_value_type` varchar(10) collate utf8_unicode_ci NOT NULL default '',
  `setting_value_int` int(11) default NULL,
  `setting_value_text` text collate utf8_unicode_ci,
  `setting_value_bool` char(1) collate utf8_unicode_ci default NULL,
  `setting_value_float` float default NULL,
  `setting_description` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`setting_id`),
  KEY `setting_key` (`setting_key`),
  KEY `setting_category` (`setting_category`),
  KEY `setting_item` (`setting_item`)
) ENGINE=InnoDB AUTO_INCREMENT=320 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `sops`
--

DROP TABLE IF EXISTS `sops`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `sops` (
  `sop_id` int(11) NOT NULL default '0',
  `sop_name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `sop_version` varchar(255) collate utf8_unicode_ci default NULL,
  `sop_last_modified` datetime default NULL,
  `sop_URL` varchar(255) collate utf8_unicode_ci default '',
  `sop_text` text collate utf8_unicode_ci,
  PRIMARY KEY  (`sop_id`),
  KEY `sop_name` (`sop_name`),
  KEY `sop_version` (`sop_version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `treatment_procedures`
--

DROP TABLE IF EXISTS `treatment_procedures`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `treatment_procedures` (
  `tp_id` int(11) NOT NULL,
  `tp_treatment_name` varchar(50) NOT NULL,
  `tp_treatment_description` varchar(255) default NULL,
  `tp_treatment_full_protocol` text,
  `tp_treatment_type` varchar(50) NOT NULL,
  `tp_application_type` varchar(50) NOT NULL,
  `tp_applied_substance` varchar(255) default NULL,
  `tp_applied_substance_amount` float default NULL,
  `tp_applied_substance_amount_unit` varchar(20) default NULL,
  `tp_applied_substance_concentration` float default NULL,
  `tp_applied_substance_concentration_unit` varchar(20) default NULL,
  `tp_applied_substance_volume` float default NULL,
  `tp_applied_substance_volume_unit` varchar(20) default NULL,
  `tp_application_medium` varchar(20) default NULL,
  `tp_application_purpose` varchar(255) default NULL,
  `tp_treatment_project` int(11) NOT NULL,
  `tp_treatment_deprecated_since` date default NULL,
  PRIMARY KEY  (`tp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL default '0',
  `user_name` varchar(20) collate utf8_unicode_ci NOT NULL default '',
  `user_contact` int(11) NOT NULL default '0',
  `user_password` varchar(255) collate utf8_unicode_ci default 'password',
  `user_status` varchar(10) collate utf8_unicode_ci default NULL,
  `user_roles` char(5) collate utf8_unicode_ci default 'u',
  `user_comment` text collate utf8_unicode_ci,
  PRIMARY KEY  (`user_id`),
  KEY `user_name` (`user_name`),
  KEY `user_password` (`user_password`),
  KEY `user_contact` (`user_contact`),
  KEY `user_status` (`user_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `users2projects`
--

DROP TABLE IF EXISTS `users2projects`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `users2projects` (
  `u2p_user_id` int(11) NOT NULL default '0',
  `u2p_project_id` int(11) NOT NULL default '0',
  `u2p_rights` varchar(10) collate utf8_unicode_ci default 'v',
  PRIMARY KEY  (`u2p_user_id`,`u2p_project_id`),
  KEY `u2p_project_id` (`u2p_project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `workflows`
--

DROP TABLE IF EXISTS `workflows`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `workflows` (
  `workflow_id` int(11) NOT NULL default '0',
  `workflow_name` varchar(255) collate utf8_unicode_ci default '',
  `workflow_description` text collate utf8_unicode_ci,
  `workflow_is_active` char(1) collate utf8_unicode_ci default 'y',
  PRIMARY KEY  (`workflow_id`),
  KEY `workflow_name` (`workflow_name`),
  KEY `workflow_is_active` (`workflow_is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `workflows2parametersets`
--

DROP TABLE IF EXISTS `workflows2parametersets`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `workflows2parametersets` (
  `w2p_workflow_id` int(11) NOT NULL default '0',
  `w2p_parameterset_id` int(11) NOT NULL default '0',
  `w2p_days_from_ref_date` int(11) NOT NULL default '0',
  PRIMARY KEY  (`w2p_workflow_id`,`w2p_parameterset_id`,`w2p_days_from_ref_date`),
  KEY `w2p_parameterset_id` (`w2p_parameterset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2010-03-30  6:53:07
