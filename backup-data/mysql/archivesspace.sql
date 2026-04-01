-- ArchivesSpace v2.6.0 Test Database Dump
-- Generated from fresh installation with auto-initialized schema
-- Created: 2026-04-01
--
-- This dump contains:
--   - Complete ArchivesSpace v2.6.0 database schema (120 migrations)
--   - Default admin user (username: admin, password: admin)
--   - Empty database with no collection data
--
-- Purpose: Allows immediate startup without waiting 2-3 minutes for schema initialization
--
-- For production use: Replace this file with a mysqldump from your ArchivesSpace
-- development or production server to get real collection data.
--

-- MySQL dump 10.13  Distrib 5.7.44, for Linux (x86_64)
--
-- Host: localhost    Database: archivesspace
-- ------------------------------------------------------
-- Server version	5.7.44

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
-- Table structure for table `accession`
--

DROP TABLE IF EXISTS `accession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accession` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `repo_id` int(11) NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `identifier` varchar(255) NOT NULL,
  `title` varchar(8704) DEFAULT NULL,
  `display_string` text,
  `publish` int(11) DEFAULT NULL,
  `content_description` text,
  `condition_description` text,
  `disposition` text,
  `inventory` text,
  `provenance` text,
  `general_note` text,
  `resource_type_id` int(11) DEFAULT NULL,
  `acquisition_type_id` int(11) DEFAULT NULL,
  `accession_date` date DEFAULT NULL,
  `restrictions_apply` int(11) DEFAULT NULL,
  `retention_rule` text,
  `access_restrictions` int(11) DEFAULT NULL,
  `access_restrictions_note` text,
  `use_restrictions` int(11) DEFAULT NULL,
  `use_restrictions_note` text,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `accession_unique_identifier` (`repo_id`,`identifier`),
  KEY `resource_type_id` (`resource_type_id`),
  KEY `acquisition_type_id` (`acquisition_type_id`),
  KEY `accession_system_mtime_index` (`system_mtime`),
  KEY `accession_user_mtime_index` (`user_mtime`),
  KEY `accession_suppressed_index` (`suppressed`),
  CONSTRAINT `accession_ibfk_1` FOREIGN KEY (`resource_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `accession_ibfk_2` FOREIGN KEY (`acquisition_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `accession_ibfk_3` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accession`
--

LOCK TABLES `accession` WRITE;
/*!40000 ALTER TABLE `accession` DISABLE KEYS */;
/*!40000 ALTER TABLE `accession` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `active_edit`
--

DROP TABLE IF EXISTS `active_edit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_edit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uri` varchar(255) NOT NULL,
  `operator` varchar(255) NOT NULL,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `active_edit_timestamp_index` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `active_edit`
--

LOCK TABLES `active_edit` WRITE;
/*!40000 ALTER TABLE `active_edit` DISABLE KEYS */;
/*!40000 ALTER TABLE `active_edit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_contact`
--

DROP TABLE IF EXISTS `agent_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agent_contact` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `agent_person_id` int(11) DEFAULT NULL,
  `agent_family_id` int(11) DEFAULT NULL,
  `agent_corporate_entity_id` int(11) DEFAULT NULL,
  `agent_software_id` int(11) DEFAULT NULL,
  `name` text NOT NULL,
  `salutation_id` int(11) DEFAULT NULL,
  `address_1` text,
  `address_2` text,
  `address_3` text,
  `city` text,
  `region` text,
  `country` text,
  `post_code` text,
  `email` text,
  `email_signature` text,
  `note` text,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `salutation_id` (`salutation_id`),
  KEY `agent_contact_system_mtime_index` (`system_mtime`),
  KEY `agent_contact_user_mtime_index` (`user_mtime`),
  KEY `agent_person_id` (`agent_person_id`),
  KEY `agent_family_id` (`agent_family_id`),
  KEY `agent_corporate_entity_id` (`agent_corporate_entity_id`),
  KEY `agent_software_id` (`agent_software_id`),
  CONSTRAINT `agent_contact_ibfk_1` FOREIGN KEY (`salutation_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `agent_contact_ibfk_2` FOREIGN KEY (`agent_person_id`) REFERENCES `agent_person` (`id`),
  CONSTRAINT `agent_contact_ibfk_3` FOREIGN KEY (`agent_family_id`) REFERENCES `agent_family` (`id`),
  CONSTRAINT `agent_contact_ibfk_4` FOREIGN KEY (`agent_corporate_entity_id`) REFERENCES `agent_corporate_entity` (`id`),
  CONSTRAINT `agent_contact_ibfk_5` FOREIGN KEY (`agent_software_id`) REFERENCES `agent_software` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_contact`
--

LOCK TABLES `agent_contact` WRITE;
/*!40000 ALTER TABLE `agent_contact` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_contact` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_corporate_entity`
--

DROP TABLE IF EXISTS `agent_corporate_entity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agent_corporate_entity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `publish` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `agent_sha1` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sha1_agent_corporate_entity` (`agent_sha1`),
  KEY `agent_corporate_entity_system_mtime_index` (`system_mtime`),
  KEY `agent_corporate_entity_user_mtime_index` (`user_mtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_corporate_entity`
--

LOCK TABLES `agent_corporate_entity` WRITE;
/*!40000 ALTER TABLE `agent_corporate_entity` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_corporate_entity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_family`
--

DROP TABLE IF EXISTS `agent_family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agent_family` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `publish` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `agent_sha1` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sha1_agent_family` (`agent_sha1`),
  KEY `agent_family_system_mtime_index` (`system_mtime`),
  KEY `agent_family_user_mtime_index` (`user_mtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_family`
--

LOCK TABLES `agent_family` WRITE;
/*!40000 ALTER TABLE `agent_family` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_family` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_person`
--

DROP TABLE IF EXISTS `agent_person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agent_person` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `publish` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `agent_sha1` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sha1_agent_person` (`agent_sha1`),
  KEY `agent_person_system_mtime_index` (`system_mtime`),
  KEY `agent_person_user_mtime_index` (`user_mtime`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_person`
--

LOCK TABLES `agent_person` WRITE;
/*!40000 ALTER TABLE `agent_person` DISABLE KEYS */;
INSERT INTO `agent_person` VALUES (1,0,1,0,NULL,NULL,'2026-04-01 20:40:12','2026-04-01 20:40:12','2026-04-01 20:40:12','34b9f8e2743cd3b6350abb05af694ff4ca399402',NULL,1);
/*!40000 ALTER TABLE `agent_person` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_software`
--

DROP TABLE IF EXISTS `agent_software`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agent_software` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `system_role` varchar(255) NOT NULL DEFAULT 'none',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `publish` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `agent_sha1` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sha1_agent_software` (`agent_sha1`),
  KEY `agent_software_system_role_index` (`system_role`),
  KEY `agent_software_system_mtime_index` (`system_mtime`),
  KEY `agent_software_user_mtime_index` (`user_mtime`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_software`
--

LOCK TABLES `agent_software` WRITE;
/*!40000 ALTER TABLE `agent_software` DISABLE KEYS */;
INSERT INTO `agent_software` VALUES (1,'archivesspace_agent',0,1,0,NULL,NULL,'2026-04-01 20:40:12','2026-04-01 20:40:12','2026-04-01 20:40:12','297d6c2c87743a18ce882596339e9e99602b2c62',NULL,1);
/*!40000 ALTER TABLE `agent_software` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archival_object`
--

DROP TABLE IF EXISTS `archival_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archival_object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `repo_id` int(11) NOT NULL,
  `root_record_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_name` varchar(255) DEFAULT NULL,
  `position` int(11) NOT NULL,
  `publish` int(11) NOT NULL DEFAULT '0',
  `ref_id` varchar(255) NOT NULL,
  `component_id` varchar(255) DEFAULT NULL,
  `title` varchar(8704) DEFAULT NULL,
  `display_string` text,
  `level_id` int(11) NOT NULL,
  `other_level` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `system_generated` int(11) DEFAULT '0',
  `restrictions_apply` int(11) DEFAULT NULL,
  `repository_processing_note` text,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ao_unique_refid` (`root_record_id`,`ref_id`),
  UNIQUE KEY `uniq_ao_pos` (`parent_name`,`position`),
  KEY `level_id` (`level_id`),
  KEY `language_id` (`language_id`),
  KEY `archival_object_system_mtime_index` (`system_mtime`),
  KEY `archival_object_user_mtime_index` (`user_mtime`),
  KEY `repo_id` (`repo_id`),
  KEY `ao_parent_root_idx` (`parent_id`,`root_record_id`),
  KEY `archival_object_ref_id_index` (`ref_id`),
  KEY `archival_object_component_id_index` (`component_id`),
  CONSTRAINT `archival_object_ibfk_1` FOREIGN KEY (`level_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `archival_object_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `archival_object_ibfk_3` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`),
  CONSTRAINT `archival_object_ibfk_4` FOREIGN KEY (`root_record_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `archival_object_ibfk_5` FOREIGN KEY (`parent_id`) REFERENCES `archival_object` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archival_object`
--

LOCK TABLES `archival_object` WRITE;
/*!40000 ALTER TABLE `archival_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `archival_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assessment`
--

DROP TABLE IF EXISTS `assessment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assessment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `repo_id` int(11) NOT NULL,
  `accession_report` int(11) NOT NULL DEFAULT '0',
  `appraisal` int(11) NOT NULL DEFAULT '0',
  `container_list` int(11) NOT NULL DEFAULT '0',
  `catalog_record` int(11) NOT NULL DEFAULT '0',
  `control_file` int(11) NOT NULL DEFAULT '0',
  `finding_aid_ead` int(11) NOT NULL DEFAULT '0',
  `finding_aid_paper` int(11) NOT NULL DEFAULT '0',
  `finding_aid_word` int(11) NOT NULL DEFAULT '0',
  `finding_aid_spreadsheet` int(11) NOT NULL DEFAULT '0',
  `surveyed_duration` varchar(255) DEFAULT NULL,
  `surveyed_extent` text,
  `review_required` int(11) NOT NULL DEFAULT '0',
  `purpose` text,
  `scope` text,
  `sensitive_material` int(11) NOT NULL DEFAULT '0',
  `general_assessment_note` text,
  `special_format_note` text,
  `exhibition_value_note` text,
  `deed_of_gift` int(11) DEFAULT NULL,
  `finding_aid_online` int(11) DEFAULT NULL,
  `related_eac_records` int(11) DEFAULT NULL,
  `existing_description_notes` text,
  `survey_begin` date NOT NULL DEFAULT '1970-01-01',
  `survey_end` date DEFAULT NULL,
  `review_note` text,
  `inactive` int(11) DEFAULT NULL,
  `monetary_value` decimal(16,2) DEFAULT NULL,
  `monetary_value_note` text,
  `conservation_note` text,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `assessment_system_mtime_index` (`system_mtime`),
  KEY `assessment_user_mtime_index` (`user_mtime`),
  KEY `repo_id` (`repo_id`),
  CONSTRAINT `assessment_ibfk_1` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessment`
--

LOCK TABLES `assessment` WRITE;
/*!40000 ALTER TABLE `assessment` DISABLE KEYS */;
/*!40000 ALTER TABLE `assessment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assessment_attribute`
--

DROP TABLE IF EXISTS `assessment_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assessment_attribute` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assessment_id` int(11) NOT NULL,
  `assessment_attribute_definition_id` int(11) NOT NULL,
  `value` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `assessment_id` (`assessment_id`),
  KEY `assessment_attribute_definition_id` (`assessment_attribute_definition_id`),
  CONSTRAINT `assessment_attribute_ibfk_1` FOREIGN KEY (`assessment_id`) REFERENCES `assessment` (`id`),
  CONSTRAINT `assessment_attribute_ibfk_2` FOREIGN KEY (`assessment_attribute_definition_id`) REFERENCES `assessment_attribute_definition` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessment_attribute`
--

LOCK TABLES `assessment_attribute` WRITE;
/*!40000 ALTER TABLE `assessment_attribute` DISABLE KEYS */;
/*!40000 ALTER TABLE `assessment_attribute` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assessment_attribute_definition`
--

DROP TABLE IF EXISTS `assessment_attribute_definition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assessment_attribute_definition` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `repo_id` int(11) NOT NULL,
  `label` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `position` int(11) NOT NULL,
  `readonly` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `assessment_attr_unique_label` (`repo_id`,`type`,`label`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessment_attribute_definition`
--

LOCK TABLES `assessment_attribute_definition` WRITE;
/*!40000 ALTER TABLE `assessment_attribute_definition` DISABLE KEYS */;
INSERT INTO `assessment_attribute_definition` VALUES (1,1,'Reformatting Readiness','rating',0,0),(2,1,'Housing Quality','rating',1,0),(3,1,'Physical Condition','rating',2,0),(4,1,'Physical Access (arrangement)','rating',3,0),(5,1,'Intellectual Access (description)','rating',4,0),(6,1,'Interest','rating',5,0),(7,1,'Documentation Quality','rating',6,0),(8,1,'Research Value','rating',7,1),(9,1,'Architectural Materials','format',7,0),(10,1,'Art Originals','format',8,0),(11,1,'Artifacts','format',9,0),(12,1,'Audio Materials','format',10,0),(13,1,'Biological Specimens','format',11,0),(14,1,'Botanical Specimens','format',12,0),(15,1,'Computer Storage Units','format',13,0),(16,1,'Film (negative, slide, or motion picture)','format',14,0),(17,1,'Glass','format',15,0),(18,1,'Photographs','format',16,0),(19,1,'Scrapbooks','format',17,0),(20,1,'Technical Drawings & Schematics','format',18,0),(21,1,'Textiles','format',19,0),(22,1,'Vellum & Parchment','format',20,0),(23,1,'Video Materials','format',21,0),(24,1,'Other','format',22,0),(25,1,'Potential Mold or Mold Damage','conservation_issue',23,0),(26,1,'Recent Pest Damage','conservation_issue',24,0),(27,1,'Deteriorating Film Base','conservation_issue',25,0),(28,1,'Brittle Paper','conservation_issue',26,0),(29,1,'Metal Fasteners','conservation_issue',27,0),(30,1,'Newspaper','conservation_issue',28,0),(31,1,'Tape','conservation_issue',29,0),(32,1,'Heat-Sensitive Paper','conservation_issue',30,0),(33,1,'Water Damage','conservation_issue',31,0);
/*!40000 ALTER TABLE `assessment_attribute_definition` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assessment_attribute_note`
--

DROP TABLE IF EXISTS `assessment_attribute_note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assessment_attribute_note` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assessment_id` int(11) NOT NULL,
  `assessment_attribute_definition_id` int(11) NOT NULL,
  `note` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `assessment_id` (`assessment_id`),
  KEY `assessment_attribute_definition_id` (`assessment_attribute_definition_id`),
  CONSTRAINT `assessment_attribute_note_ibfk_1` FOREIGN KEY (`assessment_id`) REFERENCES `assessment` (`id`),
  CONSTRAINT `assessment_attribute_note_ibfk_2` FOREIGN KEY (`assessment_attribute_definition_id`) REFERENCES `assessment_attribute_definition` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessment_attribute_note`
--

LOCK TABLES `assessment_attribute_note` WRITE;
/*!40000 ALTER TABLE `assessment_attribute_note` DISABLE KEYS */;
/*!40000 ALTER TABLE `assessment_attribute_note` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assessment_reviewer_rlshp`
--

DROP TABLE IF EXISTS `assessment_reviewer_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assessment_reviewer_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assessment_id` int(11) NOT NULL,
  `agent_person_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `assessment_reviewer_rlshp_system_mtime_index` (`system_mtime`),
  KEY `assessment_reviewer_rlshp_user_mtime_index` (`user_mtime`),
  KEY `assessment_id` (`assessment_id`),
  KEY `agent_person_id` (`agent_person_id`),
  CONSTRAINT `assessment_reviewer_rlshp_ibfk_1` FOREIGN KEY (`assessment_id`) REFERENCES `assessment` (`id`),
  CONSTRAINT `assessment_reviewer_rlshp_ibfk_2` FOREIGN KEY (`agent_person_id`) REFERENCES `agent_person` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessment_reviewer_rlshp`
--

LOCK TABLES `assessment_reviewer_rlshp` WRITE;
/*!40000 ALTER TABLE `assessment_reviewer_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `assessment_reviewer_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assessment_rlshp`
--

DROP TABLE IF EXISTS `assessment_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assessment_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assessment_id` int(11) NOT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `assessment_rlshp_system_mtime_index` (`system_mtime`),
  KEY `assessment_rlshp_user_mtime_index` (`user_mtime`),
  KEY `assessment_id` (`assessment_id`),
  KEY `accession_id` (`accession_id`),
  KEY `resource_id` (`resource_id`),
  KEY `archival_object_id` (`archival_object_id`),
  KEY `digital_object_id` (`digital_object_id`),
  CONSTRAINT `assessment_rlshp_ibfk_1` FOREIGN KEY (`assessment_id`) REFERENCES `assessment` (`id`),
  CONSTRAINT `assessment_rlshp_ibfk_2` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `assessment_rlshp_ibfk_3` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `assessment_rlshp_ibfk_4` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`),
  CONSTRAINT `assessment_rlshp_ibfk_5` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessment_rlshp`
--

LOCK TABLES `assessment_rlshp` WRITE;
/*!40000 ALTER TABLE `assessment_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `assessment_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_db`
--

DROP TABLE IF EXISTS `auth_db`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_db` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `pwhash` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `auth_db_system_mtime_index` (`system_mtime`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_db`
--

LOCK TABLES `auth_db` WRITE;
/*!40000 ALTER TABLE `auth_db` DISABLE KEYS */;
INSERT INTO `auth_db` VALUES (1,'admin','2026-04-01 20:40:12','2026-04-01 20:40:12','$2a$10$K3.NJHcI/3wBsee.wG2FH.uIVuwDnjusN7auRk0AaEZ4on6zxtxqC'),(2,'search_indexer','2026-04-01 20:40:13','2026-04-01 20:48:29','$2a$10$sTpeaQKqFisKtAEFwPk4d.kYCCiGvXnqVOeoyQFT7AiryCZkaqynu'),(4,'public_anonymous','2026-04-01 20:40:13','2026-04-01 20:48:29','$2a$10$lanzo6OeFpGso0FqcabUuuY9tCPQl3483y6bIo132e3XTK5aaRCs2'),(6,'staff_system','2026-04-01 20:40:14','2026-04-01 20:48:29','$2a$10$M4Q/b4iWSUtri2JTXs/UeuPbS.foFFdAwa15LJuJ67ZHADEgNOV5q');
/*!40000 ALTER TABLE `auth_db` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classification`
--

DROP TABLE IF EXISTS `classification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classification` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `repo_id` int(11) NOT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `title` varchar(8704) NOT NULL,
  `description` text,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `publish` int(11) DEFAULT '1',
  `suppressed` int(11) DEFAULT '0',
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `classification_system_mtime_index` (`system_mtime`),
  KEY `classification_user_mtime_index` (`user_mtime`),
  KEY `repo_id` (`repo_id`),
  CONSTRAINT `classification_ibfk_1` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classification`
--

LOCK TABLES `classification` WRITE;
/*!40000 ALTER TABLE `classification` DISABLE KEYS */;
/*!40000 ALTER TABLE `classification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classification_creator_rlshp`
--

DROP TABLE IF EXISTS `classification_creator_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classification_creator_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_person_id` int(11) DEFAULT NULL,
  `agent_software_id` int(11) DEFAULT NULL,
  `agent_family_id` int(11) DEFAULT NULL,
  `agent_corporate_entity_id` int(11) DEFAULT NULL,
  `classification_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `classification_creator_rlshp_system_mtime_index` (`system_mtime`),
  KEY `classification_creator_rlshp_user_mtime_index` (`user_mtime`),
  KEY `agent_person_id` (`agent_person_id`),
  KEY `agent_family_id` (`agent_family_id`),
  KEY `agent_corporate_entity_id` (`agent_corporate_entity_id`),
  KEY `agent_software_id` (`agent_software_id`),
  KEY `classification_id` (`classification_id`),
  CONSTRAINT `classification_creator_rlshp_ibfk_1` FOREIGN KEY (`agent_person_id`) REFERENCES `agent_person` (`id`),
  CONSTRAINT `classification_creator_rlshp_ibfk_2` FOREIGN KEY (`agent_family_id`) REFERENCES `agent_family` (`id`),
  CONSTRAINT `classification_creator_rlshp_ibfk_3` FOREIGN KEY (`agent_corporate_entity_id`) REFERENCES `agent_corporate_entity` (`id`),
  CONSTRAINT `classification_creator_rlshp_ibfk_4` FOREIGN KEY (`agent_software_id`) REFERENCES `agent_software` (`id`),
  CONSTRAINT `classification_creator_rlshp_ibfk_5` FOREIGN KEY (`classification_id`) REFERENCES `classification` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classification_creator_rlshp`
--

LOCK TABLES `classification_creator_rlshp` WRITE;
/*!40000 ALTER TABLE `classification_creator_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `classification_creator_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classification_rlshp`
--

DROP TABLE IF EXISTS `classification_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classification_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_id` int(11) DEFAULT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `classification_id` int(11) DEFAULT NULL,
  `classification_term_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `classification_rlshp_system_mtime_index` (`system_mtime`),
  KEY `classification_rlshp_user_mtime_index` (`user_mtime`),
  KEY `resource_id` (`resource_id`),
  KEY `accession_id` (`accession_id`),
  KEY `classification_id` (`classification_id`),
  KEY `classification_term_id` (`classification_term_id`),
  CONSTRAINT `classification_rlshp_ibfk_1` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `classification_rlshp_ibfk_2` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `classification_rlshp_ibfk_3` FOREIGN KEY (`classification_id`) REFERENCES `classification` (`id`),
  CONSTRAINT `classification_rlshp_ibfk_4` FOREIGN KEY (`classification_term_id`) REFERENCES `classification_term` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classification_rlshp`
--

LOCK TABLES `classification_rlshp` WRITE;
/*!40000 ALTER TABLE `classification_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `classification_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classification_term`
--

DROP TABLE IF EXISTS `classification_term`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classification_term` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `repo_id` int(11) NOT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `title` varchar(8704) NOT NULL,
  `title_sha1` varchar(255) NOT NULL,
  `description` text,
  `root_record_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_name` varchar(255) DEFAULT NULL,
  `position` int(11) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `publish` int(11) DEFAULT '1',
  `suppressed` int(11) DEFAULT '0',
  `display_string` text NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `classification_term_parent_name_title_sha1_index` (`parent_name`,`title_sha1`),
  UNIQUE KEY `classification_term_parent_name_identifier_index` (`parent_name`,`identifier`),
  UNIQUE KEY `uniq_ct_pos` (`parent_name`,`position`),
  KEY `classification_term_system_mtime_index` (`system_mtime`),
  KEY `classification_term_user_mtime_index` (`user_mtime`),
  KEY `repo_id` (`repo_id`),
  CONSTRAINT `classification_term_ibfk_1` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classification_term`
--

LOCK TABLES `classification_term` WRITE;
/*!40000 ALTER TABLE `classification_term` DISABLE KEYS */;
/*!40000 ALTER TABLE `classification_term` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classification_term_creator_rlshp`
--

DROP TABLE IF EXISTS `classification_term_creator_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classification_term_creator_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_person_id` int(11) DEFAULT NULL,
  `agent_software_id` int(11) DEFAULT NULL,
  `agent_family_id` int(11) DEFAULT NULL,
  `agent_corporate_entity_id` int(11) DEFAULT NULL,
  `classification_term_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `classification_term_creator_rlshp_system_mtime_index` (`system_mtime`),
  KEY `classification_term_creator_rlshp_user_mtime_index` (`user_mtime`),
  KEY `agent_person_id` (`agent_person_id`),
  KEY `agent_family_id` (`agent_family_id`),
  KEY `agent_corporate_entity_id` (`agent_corporate_entity_id`),
  KEY `agent_software_id` (`agent_software_id`),
  KEY `classification_term_id` (`classification_term_id`),
  CONSTRAINT `classification_term_creator_rlshp_ibfk_1` FOREIGN KEY (`agent_person_id`) REFERENCES `agent_person` (`id`),
  CONSTRAINT `classification_term_creator_rlshp_ibfk_2` FOREIGN KEY (`agent_family_id`) REFERENCES `agent_family` (`id`),
  CONSTRAINT `classification_term_creator_rlshp_ibfk_3` FOREIGN KEY (`agent_corporate_entity_id`) REFERENCES `agent_corporate_entity` (`id`),
  CONSTRAINT `classification_term_creator_rlshp_ibfk_4` FOREIGN KEY (`agent_software_id`) REFERENCES `agent_software` (`id`),
  CONSTRAINT `classification_term_creator_rlshp_ibfk_5` FOREIGN KEY (`classification_term_id`) REFERENCES `classification_term` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classification_term_creator_rlshp`
--

LOCK TABLES `classification_term_creator_rlshp` WRITE;
/*!40000 ALTER TABLE `classification_term_creator_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `classification_term_creator_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collection_management`
--

DROP TABLE IF EXISTS `collection_management`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collection_management` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `processing_hours_per_foot_estimate` varchar(255) DEFAULT NULL,
  `processing_total_extent` varchar(255) DEFAULT NULL,
  `processing_total_extent_type_id` int(11) DEFAULT NULL,
  `processing_hours_total` varchar(255) DEFAULT NULL,
  `processing_plan` text,
  `processing_priority_id` int(11) DEFAULT NULL,
  `processing_status_id` int(11) DEFAULT NULL,
  `processing_funding_source` text,
  `processors` text,
  `rights_determined` int(11) NOT NULL DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `processing_total_extent_type_id` (`processing_total_extent_type_id`),
  KEY `processing_priority_id` (`processing_priority_id`),
  KEY `processing_status_id` (`processing_status_id`),
  KEY `collection_management_system_mtime_index` (`system_mtime`),
  KEY `collection_management_user_mtime_index` (`user_mtime`),
  KEY `accession_id` (`accession_id`),
  KEY `resource_id` (`resource_id`),
  KEY `digital_object_id` (`digital_object_id`),
  CONSTRAINT `collection_management_ibfk_1` FOREIGN KEY (`processing_total_extent_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `collection_management_ibfk_2` FOREIGN KEY (`processing_priority_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `collection_management_ibfk_3` FOREIGN KEY (`processing_status_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `collection_management_ibfk_4` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `collection_management_ibfk_5` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `collection_management_ibfk_6` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collection_management`
--

LOCK TABLES `collection_management` WRITE;
/*!40000 ALTER TABLE `collection_management` DISABLE KEYS */;
/*!40000 ALTER TABLE `collection_management` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `container_profile`
--

DROP TABLE IF EXISTS `container_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `container_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `extent_dimension` varchar(255) DEFAULT NULL,
  `dimension_units_id` int(11) DEFAULT NULL,
  `height` varchar(255) DEFAULT NULL,
  `width` varchar(255) DEFAULT NULL,
  `depth` varchar(255) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `stacking_limit` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `container_profile_name_uniq` (`name`),
  KEY `dimension_units_id` (`dimension_units_id`),
  KEY `container_profile_system_mtime_index` (`system_mtime`),
  KEY `container_profile_user_mtime_index` (`user_mtime`),
  CONSTRAINT `container_profile_ibfk_1` FOREIGN KEY (`dimension_units_id`) REFERENCES `enumeration_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `container_profile`
--

LOCK TABLES `container_profile` WRITE;
/*!40000 ALTER TABLE `container_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `container_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_report_template`
--

DROP TABLE IF EXISTS `custom_report_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_report_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `repo_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `data` text NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `custom_report_template_system_mtime_index` (`system_mtime`),
  KEY `custom_report_template_user_mtime_index` (`user_mtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_report_template`
--

LOCK TABLES `custom_report_template` WRITE;
/*!40000 ALTER TABLE `custom_report_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_report_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `date`
--

DROP TABLE IF EXISTS `date`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `date` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `deaccession_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `digital_object_component_id` int(11) DEFAULT NULL,
  `related_agents_rlshp_id` int(11) DEFAULT NULL,
  `agent_person_id` int(11) DEFAULT NULL,
  `agent_family_id` int(11) DEFAULT NULL,
  `agent_corporate_entity_id` int(11) DEFAULT NULL,
  `agent_software_id` int(11) DEFAULT NULL,
  `name_person_id` int(11) DEFAULT NULL,
  `name_family_id` int(11) DEFAULT NULL,
  `name_corporate_entity_id` int(11) DEFAULT NULL,
  `name_software_id` int(11) DEFAULT NULL,
  `date_type_id` int(11) DEFAULT NULL,
  `label_id` int(11) NOT NULL,
  `certainty_id` int(11) DEFAULT NULL,
  `expression` varchar(255) DEFAULT NULL,
  `begin` varchar(255) DEFAULT NULL,
  `end` varchar(255) DEFAULT NULL,
  `era_id` int(11) DEFAULT NULL,
  `calendar_id` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `date_type_id` (`date_type_id`),
  KEY `label_id` (`label_id`),
  KEY `certainty_id` (`certainty_id`),
  KEY `era_id` (`era_id`),
  KEY `calendar_id` (`calendar_id`),
  KEY `date_system_mtime_index` (`system_mtime`),
  KEY `date_user_mtime_index` (`user_mtime`),
  KEY `accession_id` (`accession_id`),
  KEY `archival_object_id` (`archival_object_id`),
  KEY `resource_id` (`resource_id`),
  KEY `event_id` (`event_id`),
  KEY `deaccession_id` (`deaccession_id`),
  KEY `related_agents_rlshp_id` (`related_agents_rlshp_id`),
  KEY `digital_object_id` (`digital_object_id`),
  KEY `digital_object_component_id` (`digital_object_component_id`),
  KEY `agent_person_date_fk` (`agent_person_id`),
  KEY `agent_family_date_fk` (`agent_family_id`),
  KEY `agent_corporate_entity_date_fk` (`agent_corporate_entity_id`),
  KEY `agent_software_date_fk` (`agent_software_id`),
  KEY `name_person_date_fk` (`name_person_id`),
  KEY `name_family_date_fk` (`name_family_id`),
  KEY `name_corporate_entity_date_fk` (`name_corporate_entity_id`),
  KEY `name_software_date_fk` (`name_software_id`),
  CONSTRAINT `agent_corporate_entity_date_fk` FOREIGN KEY (`agent_corporate_entity_id`) REFERENCES `agent_corporate_entity` (`id`),
  CONSTRAINT `agent_family_date_fk` FOREIGN KEY (`agent_family_id`) REFERENCES `agent_family` (`id`),
  CONSTRAINT `agent_person_date_fk` FOREIGN KEY (`agent_person_id`) REFERENCES `agent_person` (`id`),
  CONSTRAINT `agent_software_date_fk` FOREIGN KEY (`agent_software_id`) REFERENCES `agent_software` (`id`),
  CONSTRAINT `date_ibfk_1` FOREIGN KEY (`date_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `date_ibfk_10` FOREIGN KEY (`deaccession_id`) REFERENCES `deaccession` (`id`),
  CONSTRAINT `date_ibfk_11` FOREIGN KEY (`related_agents_rlshp_id`) REFERENCES `related_agents_rlshp` (`id`),
  CONSTRAINT `date_ibfk_12` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `date_ibfk_13` FOREIGN KEY (`digital_object_component_id`) REFERENCES `digital_object_component` (`id`),
  CONSTRAINT `date_ibfk_2` FOREIGN KEY (`label_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `date_ibfk_3` FOREIGN KEY (`certainty_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `date_ibfk_4` FOREIGN KEY (`era_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `date_ibfk_5` FOREIGN KEY (`calendar_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `date_ibfk_6` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `date_ibfk_7` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`),
  CONSTRAINT `date_ibfk_8` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `date_ibfk_9` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`),
  CONSTRAINT `name_corporate_entity_date_fk` FOREIGN KEY (`name_corporate_entity_id`) REFERENCES `name_corporate_entity` (`id`),
  CONSTRAINT `name_family_date_fk` FOREIGN KEY (`name_family_id`) REFERENCES `name_family` (`id`),
  CONSTRAINT `name_person_date_fk` FOREIGN KEY (`name_person_id`) REFERENCES `name_person` (`id`),
  CONSTRAINT `name_software_date_fk` FOREIGN KEY (`name_software_id`) REFERENCES `name_software` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `date`
--

LOCK TABLES `date` WRITE;
/*!40000 ALTER TABLE `date` DISABLE KEYS */;
/*!40000 ALTER TABLE `date` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deaccession`
--

DROP TABLE IF EXISTS `deaccession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deaccession` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `scope_id` int(11) NOT NULL,
  `description` text NOT NULL,
  `reason` text,
  `disposition` text,
  `notification` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `scope_id` (`scope_id`),
  KEY `deaccession_system_mtime_index` (`system_mtime`),
  KEY `deaccession_user_mtime_index` (`user_mtime`),
  KEY `accession_id` (`accession_id`),
  KEY `resource_id` (`resource_id`),
  CONSTRAINT `deaccession_ibfk_1` FOREIGN KEY (`scope_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `deaccession_ibfk_2` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `deaccession_ibfk_3` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deaccession`
--

LOCK TABLES `deaccession` WRITE;
/*!40000 ALTER TABLE `deaccession` DISABLE KEYS */;
/*!40000 ALTER TABLE `deaccession` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_values`
--

DROP TABLE IF EXISTS `default_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_values` (
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `id` varchar(255) NOT NULL,
  `blob` blob NOT NULL,
  `repo_id` int(11) NOT NULL,
  `record_type` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `default_values_system_mtime_index` (`system_mtime`),
  KEY `default_values_user_mtime_index` (`user_mtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_values`
--

LOCK TABLES `default_values` WRITE;
/*!40000 ALTER TABLE `default_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deleted_records`
--

DROP TABLE IF EXISTS `deleted_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deleted_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uri` varchar(255) NOT NULL,
  `operator` varchar(255) NOT NULL,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deleted_records`
--

LOCK TABLES `deleted_records` WRITE;
/*!40000 ALTER TABLE `deleted_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `deleted_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `digital_object`
--

DROP TABLE IF EXISTS `digital_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `digital_object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `repo_id` int(11) NOT NULL,
  `digital_object_id` varchar(255) NOT NULL,
  `title` varchar(8704) DEFAULT NULL,
  `level_id` int(11) DEFAULT NULL,
  `digital_object_type_id` int(11) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `publish` int(11) DEFAULT NULL,
  `restrictions` int(11) DEFAULT NULL,
  `system_generated` int(11) DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `digital_object_repo_id_digital_object_id_index` (`repo_id`,`digital_object_id`),
  KEY `level_id` (`level_id`),
  KEY `digital_object_type_id` (`digital_object_type_id`),
  KEY `language_id` (`language_id`),
  KEY `digital_object_system_mtime_index` (`system_mtime`),
  KEY `digital_object_user_mtime_index` (`user_mtime`),
  CONSTRAINT `digital_object_ibfk_1` FOREIGN KEY (`level_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `digital_object_ibfk_2` FOREIGN KEY (`digital_object_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `digital_object_ibfk_3` FOREIGN KEY (`language_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `digital_object_ibfk_4` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_object`
--

LOCK TABLES `digital_object` WRITE;
/*!40000 ALTER TABLE `digital_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `digital_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `digital_object_component`
--

DROP TABLE IF EXISTS `digital_object_component`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `digital_object_component` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `repo_id` int(11) NOT NULL,
  `root_record_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `position` int(11) NOT NULL,
  `parent_name` varchar(255) DEFAULT NULL,
  `publish` int(11) DEFAULT NULL,
  `component_id` varchar(255) DEFAULT NULL,
  `title` varchar(8704) DEFAULT NULL,
  `display_string` text,
  `label` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `system_generated` int(11) DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `doc_unique_identifier` (`repo_id`,`component_id`),
  UNIQUE KEY `uniq_do_pos` (`parent_name`,`position`),
  KEY `language_id` (`language_id`),
  KEY `digital_object_component_system_mtime_index` (`system_mtime`),
  KEY `digital_object_component_user_mtime_index` (`user_mtime`),
  KEY `root_record_id` (`root_record_id`),
  KEY `parent_id` (`parent_id`),
  KEY `digital_object_component_component_id_index` (`component_id`),
  CONSTRAINT `digital_object_component_ibfk_1` FOREIGN KEY (`language_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `digital_object_component_ibfk_2` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`),
  CONSTRAINT `digital_object_component_ibfk_3` FOREIGN KEY (`root_record_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `digital_object_component_ibfk_4` FOREIGN KEY (`parent_id`) REFERENCES `digital_object_component` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_object_component`
--

LOCK TABLES `digital_object_component` WRITE;
/*!40000 ALTER TABLE `digital_object_component` DISABLE KEYS */;
/*!40000 ALTER TABLE `digital_object_component` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enumeration`
--

DROP TABLE IF EXISTS `enumeration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `enumeration` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `default_value` int(11) DEFAULT NULL,
  `editable` int(11) DEFAULT '1',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `enumeration_system_mtime_index` (`system_mtime`),
  KEY `enumeration_user_mtime_index` (`user_mtime`),
  KEY `enumeration_default_value_fk` (`default_value`),
  CONSTRAINT `enumeration_default_value_fk` FOREIGN KEY (`default_value`) REFERENCES `enumeration_value` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enumeration`
--

LOCK TABLES `enumeration` WRITE;
/*!40000 ALTER TABLE `enumeration` DISABLE KEYS */;
INSERT INTO `enumeration` VALUES (1,0,1,'linked_agent_archival_record_relators',NULL,1,NULL,NULL,'2026-04-01 20:39:51','2026-04-01 20:39:51','2026-04-01 20:39:51'),(2,0,1,'linked_event_archival_record_roles',NULL,0,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(3,0,1,'linked_agent_event_roles',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(4,0,1,'name_source',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(5,0,1,'name_rule',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(6,0,1,'accession_acquisition_type',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(7,0,1,'accession_resource_type',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(8,0,1,'collection_management_processing_priority',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(9,0,1,'collection_management_processing_status',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(10,0,1,'date_era',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(11,0,1,'date_calendar',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(12,0,1,'digital_object_digital_object_type',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(13,0,1,'digital_object_level',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(14,0,1,'extent_extent_type',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(15,0,1,'event_event_type',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(16,0,1,'container_type',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(17,0,1,'agent_contact_salutation',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(18,0,1,'event_outcome',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(19,0,1,'resource_resource_type',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(20,0,1,'resource_finding_aid_description_rules',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(21,0,1,'resource_finding_aid_status',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(22,0,1,'instance_instance_type',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(23,0,1,'subject_source',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(24,0,1,'file_version_use_statement',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(25,0,1,'file_version_checksum_methods',NULL,1,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(26,0,1,'language_iso639_2',NULL,0,NULL,NULL,'2026-04-01 20:39:52','2026-04-01 20:39:52','2026-04-01 20:39:52'),(27,0,1,'linked_agent_role',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(28,0,1,'agent_relationship_associative_relator',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(29,0,1,'agent_relationship_earlierlater_relator',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(30,0,1,'agent_relationship_parentchild_relator',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(31,0,1,'agent_relationship_subordinatesuperior_relator',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(32,0,1,'archival_record_level',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(33,0,1,'container_location_status',899,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(34,0,1,'date_type',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(35,0,1,'date_label',NULL,1,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(36,0,1,'date_certainty',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(37,0,1,'deaccession_scope',921,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(38,0,1,'extent_portion',923,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(39,0,1,'file_version_xlink_actuate_attribute',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(40,0,1,'file_version_xlink_show_attribute',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(41,0,1,'file_version_file_format_name',NULL,1,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(42,0,1,'location_temporary',NULL,1,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(43,0,1,'name_person_name_order',946,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(44,0,1,'note_digital_object_type',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(45,0,1,'note_multipart_type',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(46,0,1,'note_orderedlist_enumeration',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(47,0,1,'note_singlepart_type',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(48,0,1,'note_bibliography_type',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(49,0,1,'note_index_type',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(50,0,1,'note_index_item_type',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(51,0,1,'country_iso_3166',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(52,0,1,'rights_statement_rights_type',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(53,0,1,'rights_statement_ip_status',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(54,0,1,'subject_term_type',NULL,0,NULL,NULL,'2026-04-01 20:39:53','2026-04-01 20:39:53','2026-04-01 20:39:53'),(55,0,1,'user_defined_enum_1',NULL,1,NULL,NULL,'2026-04-01 20:39:54','2026-04-01 20:39:54','2026-04-01 20:39:54'),(56,0,1,'user_defined_enum_2',NULL,1,NULL,NULL,'2026-04-01 20:39:54','2026-04-01 20:39:54','2026-04-01 20:39:54'),(57,0,1,'user_defined_enum_3',NULL,1,NULL,NULL,'2026-04-01 20:39:54','2026-04-01 20:39:54','2026-04-01 20:39:54'),(58,0,1,'user_defined_enum_4',NULL,1,NULL,NULL,'2026-04-01 20:39:54','2026-04-01 20:39:54','2026-04-01 20:39:54'),(59,0,1,'accession_parts_relator',NULL,0,NULL,NULL,'2026-04-01 20:39:56','2026-04-01 20:39:56','2026-04-01 20:39:56'),(60,0,1,'accession_parts_relator_type',NULL,1,NULL,NULL,'2026-04-01 20:39:56','2026-04-01 20:39:56','2026-04-01 20:39:56'),(61,0,1,'accession_sibling_relator',NULL,0,NULL,NULL,'2026-04-01 20:39:56','2026-04-01 20:39:56','2026-04-01 20:39:56'),(62,0,1,'accession_sibling_relator_type',NULL,1,NULL,NULL,'2026-04-01 20:39:56','2026-04-01 20:39:56','2026-04-01 20:39:56'),(64,0,1,'telephone_number_type',NULL,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(65,0,1,'restriction_type',NULL,1,NULL,NULL,'2026-04-01 20:40:00','2026-04-01 20:40:00','2026-04-01 20:40:00'),(66,0,1,'dimension_units',NULL,0,NULL,NULL,'2026-04-01 20:40:00','2026-04-01 20:40:00','2026-04-01 20:40:00'),(67,0,1,'location_function_type',NULL,1,NULL,NULL,'2026-04-01 20:40:00','2026-04-01 20:40:00','2026-04-01 20:40:00'),(68,0,1,'rights_statement_act_type',NULL,1,NULL,NULL,'2026-04-01 20:40:00','2026-04-01 20:40:00','2026-04-01 20:40:00'),(69,0,1,'rights_statement_act_restriction',NULL,1,NULL,NULL,'2026-04-01 20:40:00','2026-04-01 20:40:00','2026-04-01 20:40:00'),(70,0,1,'note_rights_statement_act_type',NULL,0,NULL,NULL,'2026-04-01 20:40:00','2026-04-01 20:40:00','2026-04-01 20:40:00'),(71,0,1,'note_rights_statement_type',NULL,0,NULL,NULL,'2026-04-01 20:40:00','2026-04-01 20:40:00','2026-04-01 20:40:00'),(72,0,1,'rights_statement_external_document_identifier_type',NULL,1,NULL,NULL,'2026-04-01 20:40:01','2026-04-01 20:40:01','2026-04-01 20:40:01'),(73,0,1,'rights_statement_other_rights_basis',NULL,1,NULL,NULL,'2026-04-01 20:40:01','2026-04-01 20:40:01','2026-04-01 20:40:01');
/*!40000 ALTER TABLE `enumeration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enumeration_value`
--

DROP TABLE IF EXISTS `enumeration_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `enumeration_value` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enumeration_id` int(11) NOT NULL,
  `value` varchar(255) COLLATE utf8_bin NOT NULL,
  `readonly` int(11) DEFAULT '0',
  `position` int(11) NOT NULL DEFAULT '0',
  `suppressed` int(11) DEFAULT '0',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL DEFAULT '1',
  `created_by` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `last_modified_by` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `system_mtime` datetime DEFAULT NULL,
  `user_mtime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `enumeration_value_uniq` (`enumeration_id`,`value`),
  UNIQUE KEY `enumeration_position_uniq` (`enumeration_id`,`position`),
  KEY `enumeration_value_enumeration_id_index` (`enumeration_id`),
  KEY `enumeration_value_value_index` (`value`),
  CONSTRAINT `enumeration_value_ibfk_1` FOREIGN KEY (`enumeration_id`) REFERENCES `enumeration` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1495 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enumeration_value`
--

LOCK TABLES `enumeration_value` WRITE;
/*!40000 ALTER TABLE `enumeration_value` DISABLE KEYS */;
INSERT INTO `enumeration_value` VALUES (1,1,'act',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(2,1,'adp',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(3,1,'anl',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(4,1,'anm',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(5,1,'ann',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(6,1,'app',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(7,1,'arc',0,10,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(8,1,'arr',0,12,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(9,1,'acp',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(10,1,'art',0,13,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(11,1,'ard',0,11,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(12,1,'asg',0,14,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(13,1,'asn',0,15,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(14,1,'att',0,16,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(15,1,'auc',0,17,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(16,1,'aut',0,21,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(17,1,'aqt',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(18,1,'aft',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(19,1,'aud',0,18,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(20,1,'aui',0,19,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(21,1,'aus',0,20,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(22,1,'ant',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(23,1,'bnd',0,27,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(24,1,'bdd',0,22,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(25,1,'blw',0,26,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(26,1,'bkd',0,24,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(27,1,'bkp',0,25,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(28,1,'bjd',0,23,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(29,1,'bpd',0,28,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(30,1,'bsl',0,29,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(31,1,'cll',0,34,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(32,1,'ctg',0,63,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(33,1,'cns',0,42,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(34,1,'chr',0,31,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(35,1,'cng',0,41,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(36,1,'cli',0,33,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(37,1,'clb',0,32,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(38,1,'col',0,44,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(39,1,'clt',0,36,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(40,1,'clr',0,35,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(41,1,'cmm',0,37,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(42,1,'cwt',0,68,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(43,1,'com',0,45,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(44,1,'cpl',0,53,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(45,1,'cpt',0,54,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(46,1,'cpe',0,51,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(47,1,'cmp',0,38,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(48,1,'cmt',0,39,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(49,1,'ccp',0,30,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(50,1,'cnd',0,40,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(51,1,'con',0,46,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(52,1,'csl',0,58,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(53,1,'csp',0,59,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(54,1,'cos',0,47,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(55,1,'cot',0,48,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(56,1,'coe',0,43,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(57,1,'cts',0,65,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(58,1,'ctt',0,66,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(59,1,'cte',0,62,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(60,1,'ctr',0,64,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(61,1,'ctb',0,61,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(62,1,'cpc',0,50,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(63,1,'cph',0,52,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(64,1,'crr',0,57,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(65,1,'crp',0,56,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(66,1,'cst',0,60,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(67,1,'cov',0,49,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(68,1,'cre',0,55,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(69,1,'cur',0,67,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(70,1,'dnc',0,76,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(71,1,'dtc',0,84,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(72,1,'dtm',0,86,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(73,1,'dte',0,85,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(74,1,'dto',0,87,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(75,1,'dfd',0,70,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(76,1,'dft',0,72,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(77,1,'dfe',0,71,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(78,1,'dgg',0,73,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(79,1,'dln',0,75,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(80,1,'dpc',0,78,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(81,1,'dpt',0,79,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(82,1,'dsr',0,82,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(83,1,'drt',0,81,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(84,1,'dis',0,74,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(85,1,'dbp',0,69,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(86,1,'dst',0,83,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(87,1,'drm',0,80,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(88,1,'dub',0,88,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(89,1,'edt',0,89,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(90,1,'elg',0,91,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(91,1,'elt',0,92,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(92,1,'eng',0,93,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(93,1,'egr',0,90,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(94,1,'etr',0,94,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(95,1,'evp',0,95,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(96,1,'exp',0,96,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(97,1,'fac',0,97,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(98,1,'fld',0,98,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(99,1,'flm',0,99,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(100,1,'fpy',0,102,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(101,1,'frg',0,103,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(102,1,'fmo',0,100,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(103,1,'dnr',0,77,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(104,1,'fnd',0,101,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(105,1,'gis',0,104,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(106,1,'grt',0,105,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(107,1,'hnr',0,106,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(108,1,'hst',0,107,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(109,1,'ilu',0,109,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(110,1,'ill',0,108,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(111,1,'ins',0,110,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(112,1,'itr',0,112,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(113,1,'ive',0,113,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(114,1,'ivr',0,114,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(115,1,'inv',0,111,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(116,1,'lbr',0,115,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(117,1,'ldr',0,117,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(118,1,'lsa',0,127,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(119,1,'led',0,118,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(120,1,'len',0,121,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(121,1,'lil',0,125,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(122,1,'lit',0,126,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(123,1,'lie',0,124,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(124,1,'lel',0,120,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(125,1,'let',0,122,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(126,1,'lee',0,119,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(127,1,'lbt',0,116,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(128,1,'lse',0,128,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(129,1,'lso',0,129,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(130,1,'lgd',0,123,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(131,1,'ltg',0,130,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(132,1,'lyr',0,131,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(133,1,'mfp',0,134,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(134,1,'mfr',0,135,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(135,1,'mrb',0,138,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(136,1,'mrk',0,139,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(137,1,'mdc',0,133,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(138,1,'mte',0,141,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(139,1,'mod',0,136,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(140,1,'mon',0,137,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(141,1,'mcp',0,132,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(142,1,'msd',0,140,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(143,1,'mus',0,142,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(144,1,'nrt',0,143,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(145,1,'opn',0,144,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(146,1,'orm',0,146,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(147,1,'org',0,145,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(148,1,'oth',0,147,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(149,1,'own',0,148,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(150,1,'ppm',0,159,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(151,1,'pta',0,170,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(152,1,'pth',0,173,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(153,1,'pat',0,149,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(154,1,'prf',0,163,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(155,1,'pma',0,156,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(156,1,'pht',0,154,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(157,1,'ptf',0,172,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(158,1,'ptt',0,174,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(159,1,'pte',0,171,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(160,1,'plt',0,155,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(161,1,'prt',0,168,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(162,1,'pop',0,158,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(163,1,'prm',0,165,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(164,1,'prc',0,161,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(165,1,'pro',0,166,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(166,1,'pmn',0,157,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(167,1,'prd',0,162,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(168,1,'prp',0,167,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(169,1,'prg',0,164,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(170,1,'pdr',0,152,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(171,1,'pfr',0,153,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(172,1,'prv',0,169,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(173,1,'pup',0,175,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(174,1,'pbl',0,151,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(175,1,'pbd',0,150,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(176,1,'ppt',0,160,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(177,1,'rcp',0,179,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(178,1,'rce',0,178,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(179,1,'rcd',0,177,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(180,1,'red',0,180,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(181,1,'ren',0,181,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(182,1,'rpt',0,185,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(183,1,'rps',0,184,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(184,1,'rth',0,191,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(185,1,'rtm',0,192,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(186,1,'res',0,182,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(187,1,'rsp',0,189,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(188,1,'rst',0,190,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(189,1,'rse',0,187,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(190,1,'rpy',0,186,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(191,1,'rsg',0,188,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(192,1,'rev',0,183,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(193,1,'rbr',0,176,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(194,1,'sce',0,194,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(195,1,'sad',0,193,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(196,1,'scr',0,196,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(197,1,'scl',0,195,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(198,1,'spy',0,204,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(199,1,'sec',0,198,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(200,1,'std',0,206,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(201,1,'stg',0,207,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(202,1,'sgn',0,199,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(203,1,'sng',0,201,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(204,1,'sds',0,197,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(205,1,'spk',0,202,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(206,1,'spn',0,203,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(207,1,'stm',0,209,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(208,1,'stn',0,210,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(209,1,'str',0,211,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(210,1,'stl',0,208,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(211,1,'sht',0,200,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(212,1,'srv',0,205,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(213,1,'tch',0,213,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(214,1,'tcd',0,212,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(215,1,'ths',0,214,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(216,1,'trc',0,215,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(217,1,'trl',0,216,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(218,1,'tyd',0,217,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(219,1,'tyg',0,218,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(220,1,'uvp',0,219,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(221,1,'vdg',0,220,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(222,1,'voc',0,221,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(223,1,'wit',0,225,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(224,1,'wde',0,224,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(225,1,'wdc',0,223,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(226,1,'wam',0,222,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(227,2,'source',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(228,2,'outcome',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(229,2,'transfer',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(230,3,'authorizer',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(231,3,'executing_program',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(232,3,'implementer',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(233,3,'recipient',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(234,3,'transmitter',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(235,3,'validator',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(236,4,'local',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(237,4,'naf',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(238,4,'nad',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(239,4,'ulan',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(240,5,'local',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(241,5,'aacr',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(242,5,'dacs',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(243,5,'rda',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(244,6,'deposit',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(245,6,'gift',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(246,6,'purchase',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(247,6,'transfer',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(248,7,'collection',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(249,7,'publications',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(250,7,'papers',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(251,7,'records',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(252,8,'high',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(253,8,'medium',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(254,8,'low',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(255,9,'new',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(256,9,'in_progress',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(257,9,'completed',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(258,10,'ce',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(259,11,'gregorian',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(260,12,'cartographic',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(261,12,'mixed_materials',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(262,12,'moving_image',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(263,12,'notated_music',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(264,12,'software_multimedia',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(265,12,'sound_recording',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(266,12,'sound_recording_musical',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(267,12,'sound_recording_nonmusical',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(268,12,'still_image',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(269,12,'text',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(270,13,'collection',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(271,13,'work',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(272,13,'image',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(273,14,'cassettes',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(274,14,'cubic_feet',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(275,14,'gigabytes',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(276,14,'leaves',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(277,14,'linear_feet',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(278,14,'megabytes',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(279,14,'photographic_prints',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(280,14,'photographic_slides',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(281,14,'reels',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(282,14,'sheets',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(283,14,'terabytes',0,10,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(284,14,'volumes',0,11,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(285,15,'accession',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(286,15,'accumulation',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(287,15,'acknowledgement_sent',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(288,15,'acknowledgement_received',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(289,15,'agreement_signed',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(290,15,'agreement_received',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(291,15,'agreement_sent',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(292,15,'appraisal',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(293,15,'assessment',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(294,15,'capture',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(295,15,'cataloged',0,10,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(296,15,'collection',0,11,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(297,15,'compression',0,13,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(298,15,'contribution',0,14,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(299,15,'component_transfer',0,12,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(300,15,'copyright_transfer',0,15,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(301,15,'custody_transfer',0,16,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(302,15,'deaccession',0,17,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(303,15,'decompression',0,18,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(304,15,'decryption',0,19,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(305,15,'deletion',0,20,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(306,15,'digital_signature_validation',0,21,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(307,15,'fixity_check',0,22,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(308,15,'ingestion',0,23,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(309,15,'message_digest_calculation',0,24,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(310,15,'migration',0,25,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(311,15,'normalization',0,26,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(312,15,'processed',0,27,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(313,15,'publication',0,28,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(314,15,'replication',0,29,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(315,15,'validation',0,30,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(316,15,'virus_check',0,31,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(317,16,'box',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(318,16,'carton',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(319,16,'case',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(320,16,'folder',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(321,16,'frame',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(322,16,'object',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(323,16,'reel',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(324,17,'mr',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(325,17,'mrs',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(326,17,'ms',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(327,17,'madame',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(328,17,'sir',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(329,18,'pass',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(330,18,'partial pass',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(331,18,'fail',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(332,19,'collection',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(333,19,'publications',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(334,19,'papers',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(335,19,'records',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(336,20,'aacr',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(337,20,'cco',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(338,20,'dacs',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(339,20,'rad',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(340,20,'isadg',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(341,21,'completed',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(342,21,'in_progress',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(343,21,'under_revision',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(344,21,'unprocessed',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(345,22,'accession',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(346,22,'audio',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(347,22,'books',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(348,22,'computer_disks',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(349,22,'digital_object',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(350,22,'graphic_materials',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(351,22,'maps',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(352,22,'microform',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(353,22,'mixed_materials',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(354,22,'moving_images',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(355,22,'realia',0,10,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(356,22,'text',0,11,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(357,23,'aat',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(358,23,'rbgenr',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(359,23,'tgn',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(360,23,'lcsh',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(361,23,'local',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(362,23,'mesh',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(363,23,'gmgpc',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(364,24,'application',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(365,24,'application-pdf',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(366,24,'audio-clip',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(367,24,'audio-master',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(368,24,'audio-master-edited',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(369,24,'audio-service',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(370,24,'image-master',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(371,24,'image-master-edited',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(372,24,'image-service',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(373,24,'image-service-edited',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(374,24,'image-thumbnail',0,10,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(375,24,'text-codebook',0,12,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(376,24,'test-data',0,11,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(377,24,'text-data_definition',0,13,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(378,24,'text-georeference',0,14,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(379,24,'text-ocr-edited',0,15,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(380,24,'text-ocr-unedited',0,16,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(381,24,'text-tei-transcripted',0,17,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(382,24,'text-tei-translated',0,18,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(383,24,'video-clip',0,19,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(384,24,'video-master',0,20,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(385,24,'video-master-edited',0,21,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(386,24,'video-service',0,22,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(387,24,'video-streaming',0,23,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(388,25,'md5',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(389,25,'sha-1',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(390,25,'sha-256',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(391,25,'sha-384',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(392,25,'sha-512',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(393,26,'aar',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(394,26,'abk',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(395,26,'ace',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(396,26,'ach',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(397,26,'ada',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(398,26,'ady',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(399,26,'afa',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(400,26,'afh',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(401,26,'afr',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(402,26,'ain',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(403,26,'aka',0,10,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(404,26,'akk',0,11,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(405,26,'alb',0,12,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(406,26,'ale',0,13,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(407,26,'alg',0,14,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(408,26,'alt',0,15,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(409,26,'amh',0,16,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(410,26,'ang',0,17,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(411,26,'anp',0,18,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(412,26,'apa',0,19,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(413,26,'ara',0,20,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(414,26,'arc',0,21,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(415,26,'arg',0,22,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(416,26,'arm',0,23,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(417,26,'arn',0,24,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(418,26,'arp',0,25,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(419,26,'art',0,26,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(420,26,'arw',0,27,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(421,26,'asm',0,28,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(422,26,'ast',0,29,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(423,26,'ath',0,30,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(424,26,'aus',0,31,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(425,26,'ava',0,32,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(426,26,'ave',0,33,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(427,26,'awa',0,34,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(428,26,'aym',0,35,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(429,26,'aze',0,36,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(430,26,'bad',0,37,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(431,26,'bai',0,38,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(432,26,'bak',0,39,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(433,26,'bal',0,40,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(434,26,'bam',0,41,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(435,26,'ban',0,42,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(436,26,'baq',0,43,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(437,26,'bas',0,44,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(438,26,'bat',0,45,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(439,26,'bej',0,46,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(440,26,'bel',0,47,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(441,26,'bem',0,48,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(442,26,'ben',0,49,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(443,26,'ber',0,50,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(444,26,'bho',0,51,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(445,26,'bih',0,52,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(446,26,'bik',0,53,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(447,26,'bin',0,54,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(448,26,'bis',0,55,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(449,26,'bla',0,56,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(450,26,'bnt',0,57,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(451,26,'bos',0,58,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(452,26,'bra',0,59,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(453,26,'bre',0,60,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(454,26,'btk',0,61,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(455,26,'bua',0,62,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(456,26,'bug',0,63,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(457,26,'bul',0,64,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(458,26,'bur',0,65,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(459,26,'byn',0,66,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(460,26,'cad',0,67,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(461,26,'cai',0,68,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(462,26,'car',0,69,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(463,26,'cat',0,70,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(464,26,'cau',0,71,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(465,26,'ceb',0,72,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(466,26,'cel',0,73,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(467,26,'cha',0,74,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(468,26,'chb',0,75,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(469,26,'che',0,76,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(470,26,'chg',0,77,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(471,26,'chi',0,78,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(472,26,'chk',0,79,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(473,26,'chm',0,80,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(474,26,'chn',0,81,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(475,26,'cho',0,82,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(476,26,'chp',0,83,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(477,26,'chr',0,84,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(478,26,'chu',0,85,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(479,26,'chv',0,86,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(480,26,'chy',0,87,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(481,26,'cmc',0,88,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(482,26,'cop',0,89,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(483,26,'cor',0,90,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(484,26,'cos',0,91,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(485,26,'cpe',0,92,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(486,26,'cpf',0,93,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(487,26,'cpp',0,94,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(488,26,'cre',0,95,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(489,26,'crh',0,96,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(490,26,'crp',0,97,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(491,26,'csb',0,98,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(492,26,'cus',0,99,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(493,26,'cze',0,100,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(494,26,'dak',0,101,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(495,26,'dan',0,102,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(496,26,'dar',0,103,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(497,26,'day',0,104,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(498,26,'del',0,105,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(499,26,'den',0,106,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(500,26,'dgr',0,107,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(501,26,'din',0,108,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(502,26,'div',0,109,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(503,26,'doi',0,110,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(504,26,'dra',0,111,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(505,26,'dsb',0,112,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(506,26,'dua',0,113,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(507,26,'dum',0,114,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(508,26,'dut',0,115,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(509,26,'dyu',0,116,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(510,26,'dzo',0,117,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(511,26,'efi',0,118,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(512,26,'egy',0,119,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(513,26,'eka',0,120,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(514,26,'elx',0,121,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(515,26,'eng',0,122,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(516,26,'enm',0,123,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(517,26,'epo',0,124,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(518,26,'est',0,125,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(519,26,'ewe',0,126,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(520,26,'ewo',0,127,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(521,26,'fan',0,128,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(522,26,'fao',0,129,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(523,26,'fat',0,130,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(524,26,'fij',0,131,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(525,26,'fil',0,132,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(526,26,'fin',0,133,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(527,26,'fiu',0,134,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(528,26,'fon',0,135,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(529,26,'fre',0,136,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(530,26,'frm',0,137,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(531,26,'fro',0,138,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(532,26,'frr',0,139,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(533,26,'frs',0,140,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(534,26,'fry',0,141,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(535,26,'ful',0,142,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(536,26,'fur',0,143,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(537,26,'gaa',0,144,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(538,26,'gay',0,145,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(539,26,'gba',0,146,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(540,26,'gem',0,147,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(541,26,'geo',0,148,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(542,26,'ger',0,149,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(543,26,'gez',0,150,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(544,26,'gil',0,151,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(545,26,'gla',0,152,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(546,26,'gle',0,153,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(547,26,'glg',0,154,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(548,26,'glv',0,155,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(549,26,'gmh',0,156,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(550,26,'goh',0,157,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(551,26,'gon',0,158,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(552,26,'gor',0,159,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(553,26,'got',0,160,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(554,26,'grb',0,161,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(555,26,'grc',0,162,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(556,26,'gre',0,163,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(557,26,'grn',0,164,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(558,26,'gsw',0,165,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(559,26,'guj',0,166,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(560,26,'gwi',0,167,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(561,26,'hai',0,168,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(562,26,'hat',0,169,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(563,26,'hau',0,170,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(564,26,'haw',0,171,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(565,26,'heb',0,172,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(566,26,'her',0,173,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(567,26,'hil',0,174,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(568,26,'him',0,175,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(569,26,'hin',0,176,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(570,26,'hit',0,177,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(571,26,'hmn',0,178,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(572,26,'hmo',0,179,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(573,26,'hrv',0,180,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(574,26,'hsb',0,181,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(575,26,'hun',0,182,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(576,26,'hup',0,183,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(577,26,'iba',0,184,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(578,26,'ibo',0,185,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(579,26,'ice',0,186,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(580,26,'ido',0,187,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(581,26,'iii',0,188,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(582,26,'ijo',0,189,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(583,26,'iku',0,190,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(584,26,'ile',0,191,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(585,26,'ilo',0,192,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(586,26,'ina',0,193,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(587,26,'inc',0,194,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(588,26,'ind',0,195,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(589,26,'ine',0,196,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(590,26,'inh',0,197,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(591,26,'ipk',0,198,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(592,26,'ira',0,199,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(593,26,'iro',0,200,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(594,26,'ita',0,201,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(595,26,'jav',0,202,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(596,26,'jbo',0,203,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(597,26,'jpn',0,204,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(598,26,'jpr',0,205,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(599,26,'jrb',0,206,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(600,26,'kaa',0,207,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(601,26,'kab',0,208,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(602,26,'kac',0,209,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(603,26,'kal',0,210,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(604,26,'kam',0,211,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(605,26,'kan',0,212,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(606,26,'kar',0,213,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(607,26,'kas',0,214,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(608,26,'kau',0,215,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(609,26,'kaw',0,216,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(610,26,'kaz',0,217,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(611,26,'kbd',0,218,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(612,26,'kha',0,219,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(613,26,'khi',0,220,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(614,26,'khm',0,221,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(615,26,'kho',0,222,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(616,26,'kik',0,223,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(617,26,'kin',0,224,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(618,26,'kir',0,225,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(619,26,'kmb',0,226,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(620,26,'kok',0,227,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(621,26,'kom',0,228,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(622,26,'kon',0,229,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(623,26,'kor',0,230,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(624,26,'kos',0,231,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(625,26,'kpe',0,232,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(626,26,'krc',0,233,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(627,26,'krl',0,234,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(628,26,'kro',0,235,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(629,26,'kru',0,236,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(630,26,'kua',0,237,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(631,26,'kum',0,238,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(632,26,'kur',0,239,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(633,26,'kut',0,240,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(634,26,'lad',0,241,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(635,26,'lah',0,242,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(636,26,'lam',0,243,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(637,26,'lao',0,244,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(638,26,'lat',0,245,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(639,26,'lav',0,246,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(640,26,'lez',0,247,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(641,26,'lim',0,248,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(642,26,'lin',0,249,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(643,26,'lit',0,250,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(644,26,'lol',0,251,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(645,26,'loz',0,252,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(646,26,'ltz',0,253,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(647,26,'lua',0,254,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(648,26,'lub',0,255,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(649,26,'lug',0,256,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(650,26,'lui',0,257,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(651,26,'lun',0,258,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(652,26,'luo',0,259,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(653,26,'lus',0,260,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(654,26,'mac',0,261,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(655,26,'mad',0,262,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(656,26,'mag',0,263,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(657,26,'mah',0,264,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(658,26,'mai',0,265,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(659,26,'mak',0,266,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(660,26,'mal',0,267,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(661,26,'man',0,268,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(662,26,'mao',0,269,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(663,26,'map',0,270,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(664,26,'mar',0,271,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(665,26,'mas',0,272,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(666,26,'may',0,273,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(667,26,'mdf',0,274,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(668,26,'mdr',0,275,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(669,26,'men',0,276,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(670,26,'mga',0,277,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(671,26,'mic',0,278,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(672,26,'min',0,279,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(673,26,'mis',0,280,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(674,26,'mkh',0,281,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(675,26,'mlg',0,282,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(676,26,'mlt',0,283,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(677,26,'mnc',0,284,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(678,26,'mni',0,285,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(679,26,'mno',0,286,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(680,26,'moh',0,287,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(681,26,'mon',0,288,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(682,26,'mos',0,289,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(683,26,'mul',0,290,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(684,26,'mun',0,291,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(685,26,'mus',0,292,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(686,26,'mwl',0,293,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(687,26,'mwr',0,294,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(688,26,'myn',0,295,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(689,26,'myv',0,296,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(690,26,'nah',0,297,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(691,26,'nai',0,298,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(692,26,'nap',0,299,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(693,26,'nau',0,300,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(694,26,'nav',0,301,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(695,26,'nbl',0,302,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(696,26,'nde',0,303,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(697,26,'ndo',0,304,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(698,26,'nds',0,305,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(699,26,'nep',0,306,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(700,26,'new',0,307,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(701,26,'nia',0,308,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(702,26,'nic',0,309,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(703,26,'niu',0,310,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(704,26,'nno',0,311,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(705,26,'nob',0,312,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(706,26,'nog',0,313,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(707,26,'non',0,314,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(708,26,'nor',0,315,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(709,26,'nqo',0,316,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(710,26,'nso',0,317,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(711,26,'nub',0,318,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(712,26,'nwc',0,319,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(713,26,'nya',0,320,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(714,26,'nym',0,321,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(715,26,'nyn',0,322,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(716,26,'nyo',0,323,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(717,26,'nzi',0,324,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(718,26,'oci',0,325,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(719,26,'oji',0,326,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(720,26,'ori',0,327,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(721,26,'orm',0,328,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(722,26,'osa',0,329,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(723,26,'oss',0,330,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(724,26,'ota',0,331,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(725,26,'oto',0,332,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(726,26,'paa',0,333,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(727,26,'pag',0,334,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(728,26,'pal',0,335,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(729,26,'pam',0,336,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(730,26,'pan',0,337,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(731,26,'pap',0,338,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(732,26,'pau',0,339,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(733,26,'peo',0,340,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(734,26,'per',0,341,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(735,26,'phi',0,342,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(736,26,'phn',0,343,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(737,26,'pli',0,344,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(738,26,'pol',0,345,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(739,26,'pon',0,346,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(740,26,'por',0,347,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(741,26,'pra',0,348,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(742,26,'pro',0,349,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(743,26,'pus',0,350,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(745,26,'que',0,352,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(746,26,'raj',0,353,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(747,26,'rap',0,354,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(748,26,'rar',0,355,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(749,26,'roa',0,356,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(750,26,'roh',0,357,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(751,26,'rom',0,358,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(752,26,'rum',0,359,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(753,26,'run',0,360,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(754,26,'rup',0,361,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(755,26,'rus',0,362,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(756,26,'sad',0,363,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(757,26,'sag',0,364,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(758,26,'sah',0,365,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(759,26,'sai',0,366,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(760,26,'sal',0,367,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(761,26,'sam',0,368,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(762,26,'san',0,369,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(763,26,'sas',0,370,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(764,26,'sat',0,371,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(765,26,'scn',0,372,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(766,26,'sco',0,373,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(767,26,'sel',0,374,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(768,26,'sem',0,375,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(769,26,'sga',0,376,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(770,26,'sgn',0,377,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(771,26,'shn',0,378,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(772,26,'sid',0,379,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(773,26,'sin',0,380,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(774,26,'sio',0,381,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(775,26,'sit',0,382,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(776,26,'sla',0,383,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(777,26,'slo',0,384,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(778,26,'slv',0,385,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(779,26,'sma',0,386,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(780,26,'sme',0,387,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(781,26,'smi',0,388,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(782,26,'smj',0,389,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(783,26,'smn',0,390,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(784,26,'smo',0,391,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(785,26,'sms',0,392,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(786,26,'sna',0,393,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(787,26,'snd',0,394,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(788,26,'snk',0,395,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(789,26,'sog',0,396,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(790,26,'som',0,397,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(791,26,'son',0,398,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(792,26,'sot',0,399,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(793,26,'spa',0,400,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(794,26,'srd',0,401,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(795,26,'srn',0,402,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(796,26,'srp',0,403,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(797,26,'srr',0,404,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(798,26,'ssa',0,405,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(799,26,'ssw',0,406,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(800,26,'suk',0,407,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(801,26,'sun',0,408,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(802,26,'sus',0,409,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(803,26,'sux',0,410,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(804,26,'swa',0,411,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(805,26,'swe',0,412,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(806,26,'syc',0,413,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(807,26,'syr',0,414,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(808,26,'tah',0,415,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(809,26,'tai',0,416,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(810,26,'tam',0,417,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(811,26,'tat',0,418,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(812,26,'tel',0,419,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(813,26,'tem',0,420,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(814,26,'ter',0,421,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(815,26,'tet',0,422,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(816,26,'tgk',0,423,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(817,26,'tgl',0,424,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(818,26,'tha',0,425,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(819,26,'tib',0,426,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(820,26,'tig',0,427,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(821,26,'tir',0,428,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(822,26,'tiv',0,429,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(823,26,'tkl',0,430,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(824,26,'tlh',0,431,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(825,26,'tli',0,432,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(826,26,'tmh',0,433,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(827,26,'tog',0,434,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(828,26,'ton',0,435,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(829,26,'tpi',0,436,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(830,26,'tsi',0,437,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(831,26,'tsn',0,438,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(832,26,'tso',0,439,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(833,26,'tuk',0,440,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(834,26,'tum',0,441,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(835,26,'tup',0,442,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(836,26,'tur',0,443,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(837,26,'tut',0,444,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(838,26,'tvl',0,445,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(839,26,'twi',0,446,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(840,26,'tyv',0,447,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(841,26,'udm',0,448,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(842,26,'uga',0,449,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(843,26,'uig',0,450,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(844,26,'ukr',0,451,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(845,26,'umb',0,452,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(846,26,'und',0,453,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(847,26,'urd',0,454,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(848,26,'uzb',0,455,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(849,26,'vai',0,456,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(850,26,'ven',0,457,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(851,26,'vie',0,458,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(852,26,'vol',0,459,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(853,26,'vot',0,460,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(854,26,'wak',0,461,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(855,26,'wal',0,462,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(856,26,'war',0,463,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(857,26,'was',0,464,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(858,26,'wel',0,465,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(859,26,'wen',0,466,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(860,26,'wln',0,467,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(861,26,'wol',0,468,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(862,26,'xal',0,469,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(863,26,'xho',0,470,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(864,26,'yao',0,471,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(865,26,'yap',0,472,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(866,26,'yid',0,473,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(867,26,'yor',0,474,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(868,26,'ypk',0,475,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(869,26,'zap',0,476,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(870,26,'zbl',0,477,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(871,26,'zen',0,478,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(872,26,'zha',0,479,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(873,26,'znd',0,480,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(874,26,'zul',0,481,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(875,26,'zun',0,482,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(876,26,'zxx',0,483,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(877,26,'zza',0,484,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(878,27,'creator',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(879,27,'source',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(880,27,'subject',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(881,28,'is_associative_with',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(882,29,'is_earlier_form_of',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(883,29,'is_later_form_of',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(884,30,'is_parent_of',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(885,30,'is_child_of',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(886,31,'is_subordinate_to',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(887,31,'is_superior_of',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(888,32,'class',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(889,32,'collection',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(890,32,'file',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(891,32,'fonds',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(892,32,'item',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(893,32,'otherlevel',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(894,32,'recordgrp',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(895,32,'series',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(896,32,'subfonds',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(897,32,'subgrp',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(898,32,'subseries',0,10,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(899,33,'current',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(900,33,'previous',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(901,34,'single',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(902,34,'bulk',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(903,34,'inclusive',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(904,35,'broadcast',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(905,35,'copyright',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(906,35,'creation',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(907,35,'deaccession',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(908,35,'digitized',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(909,35,'event',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(910,35,'issued',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(911,35,'modified',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(912,35,'publication',0,11,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(913,35,'agent_relation',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(914,35,'other',0,10,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(915,35,'usage',0,13,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(916,35,'existence',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(917,35,'record_keeping',0,12,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(918,36,'approximate',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(919,36,'inferred',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(920,36,'questionable',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(921,37,'whole',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(922,37,'part',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(923,38,'whole',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(924,38,'part',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(925,39,'none',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(926,39,'other',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(927,39,'onLoad',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(928,39,'onRequest',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(929,40,'new',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(930,40,'replace',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(931,40,'embed',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(932,40,'other',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(933,40,'none',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(934,41,'aiff',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(935,41,'avi',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(936,41,'gif',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(937,41,'jpeg',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(938,41,'mp3',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(939,41,'pdf',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(940,41,'tiff',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(941,41,'txt',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(942,42,'conservation',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(943,42,'exhibit',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(944,42,'loan',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(945,42,'reading_room',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(946,43,'inverted',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(947,43,'direct',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(948,44,'summary',0,17,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(949,44,'bioghist',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(950,44,'accessrestrict',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(951,44,'userestrict',0,18,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(952,44,'custodhist',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(953,44,'dimensions',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(954,44,'edition',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(955,44,'extent',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(956,44,'altformavail',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(957,44,'originalsloc',0,12,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(958,44,'note',0,11,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(959,44,'acqinfo',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(960,44,'inscription',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(961,44,'langmaterial',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(962,44,'legalstatus',0,10,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(963,44,'physdesc',0,13,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(964,44,'prefercite',0,14,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(965,44,'processinfo',0,15,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(966,44,'relatedmaterial',0,16,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(967,45,'accruals',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(968,45,'appraisal',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(969,45,'arrangement',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(970,45,'bioghist',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(971,45,'accessrestrict',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(972,45,'userestrict',0,20,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(973,45,'custodhist',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(974,45,'dimensions',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(975,45,'altformavail',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(976,45,'originalsloc',0,12,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(977,45,'fileplan',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(978,45,'odd',0,11,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(979,45,'acqinfo',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(980,45,'legalstatus',0,10,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(981,45,'otherfindaid',0,13,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(982,45,'phystech',0,14,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(983,45,'prefercite',0,15,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(984,45,'processinfo',0,16,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(985,45,'relatedmaterial',0,17,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(986,45,'scopecontent',0,18,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(987,45,'separatedmaterial',0,19,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(988,46,'arabic',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(989,46,'loweralpha',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(990,46,'upperalpha',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(991,46,'lowerroman',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(992,46,'upperroman',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(993,47,'abstract',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(994,47,'physdesc',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(995,47,'langmaterial',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(996,47,'physloc',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(997,47,'materialspec',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(998,47,'physfacet',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(999,48,'bibliography',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1000,49,'index',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1001,50,'name',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1002,50,'person',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1003,50,'family',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1004,50,'corporate_entity',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1005,50,'subject',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1006,50,'function',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1007,50,'occupation',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1008,50,'title',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1009,50,'geographic_name',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1010,50,'genre_form',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1011,51,'AF',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1012,51,'AX',0,14,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1013,51,'AL',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1014,51,'DZ',0,61,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1015,51,'AS',0,10,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1016,51,'AD',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1017,51,'AO',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1018,51,'AI',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1019,51,'AQ',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1020,51,'AG',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1021,51,'AR',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1022,51,'AM',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1023,51,'AW',0,13,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1024,51,'AU',0,12,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1025,51,'AT',0,11,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1026,51,'AZ',0,15,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1027,51,'BS',0,31,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1028,51,'BH',0,22,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1029,51,'BD',0,18,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1030,51,'BB',0,17,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1031,51,'BY',0,35,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1032,51,'BE',0,19,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1033,51,'BZ',0,36,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1034,51,'BJ',0,24,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1035,51,'BM',0,26,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1036,51,'BT',0,32,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1037,51,'BO',0,28,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1038,51,'BQ',0,29,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1039,51,'BA',0,16,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1040,51,'BW',0,34,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1041,51,'BV',0,33,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1042,51,'BR',0,30,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1043,51,'IO',0,105,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1044,51,'BN',0,27,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1045,51,'BG',0,21,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1046,51,'BF',0,20,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1047,51,'BI',0,23,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1048,51,'KH',0,116,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1049,51,'CM',0,46,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1050,51,'CA',0,37,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1051,51,'CV',0,51,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1052,51,'KY',0,123,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1053,51,'CF',0,40,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1054,51,'TD',0,214,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1055,51,'CL',0,45,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1056,51,'CN',0,47,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1057,51,'CX',0,53,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1058,51,'CC',0,38,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1059,51,'CO',0,48,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1060,51,'KM',0,118,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1061,51,'CG',0,41,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1062,51,'CD',0,39,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1063,51,'CK',0,44,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1064,51,'CR',0,49,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1065,51,'CI',0,43,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1066,51,'HR',0,97,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1067,51,'CU',0,50,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1068,51,'CW',0,52,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1069,51,'CY',0,54,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1070,51,'CZ',0,55,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1071,51,'DK',0,58,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1072,51,'DJ',0,57,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1073,51,'DM',0,59,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1074,51,'DO',0,60,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1075,51,'EC',0,62,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1076,51,'EG',0,64,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1077,51,'SV',0,209,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1078,51,'GQ',0,87,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1079,51,'ER',0,66,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1080,51,'EE',0,63,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1081,51,'ET',0,68,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1082,51,'FK',0,71,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1083,51,'FO',0,73,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1084,51,'FJ',0,70,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1085,51,'FI',0,69,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1086,51,'FR',0,74,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1087,51,'GF',0,79,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1088,51,'PF',0,174,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1089,51,'TF',0,215,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1090,51,'GA',0,75,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1091,51,'GM',0,84,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1092,51,'GE',0,78,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1093,51,'DE',0,56,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1094,51,'GH',0,81,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1095,51,'GI',0,82,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1096,51,'GR',0,88,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1097,51,'GL',0,83,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1098,51,'GD',0,77,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1099,51,'GP',0,86,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1100,51,'GU',0,91,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1101,51,'GT',0,90,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1102,51,'GG',0,80,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1103,51,'GN',0,85,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1104,51,'GW',0,92,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1105,51,'GY',0,93,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1106,51,'HT',0,98,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1107,51,'HM',0,95,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1108,51,'VA',0,235,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1109,51,'HN',0,96,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1110,51,'HK',0,94,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1111,51,'HU',0,99,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1112,51,'IS',0,108,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1113,51,'IN',0,104,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1114,51,'ID',0,100,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1115,51,'IR',0,107,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1116,51,'IQ',0,106,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1117,51,'IE',0,101,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1118,51,'IM',0,103,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1119,51,'IL',0,102,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1120,51,'IT',0,109,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1121,51,'JM',0,111,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1122,51,'JP',0,113,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1123,51,'JE',0,110,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1124,51,'JO',0,112,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1125,51,'KZ',0,124,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1126,51,'KE',0,114,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1127,51,'KI',0,117,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1128,51,'KP',0,120,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1129,51,'KR',0,121,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1130,51,'KW',0,122,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1131,51,'KG',0,115,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1132,51,'LA',0,125,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1133,51,'LV',0,134,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1134,51,'LB',0,126,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1135,51,'LS',0,131,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1136,51,'LR',0,130,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1137,51,'LY',0,135,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1138,51,'LI',0,128,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1139,51,'LT',0,132,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1140,51,'LU',0,133,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1141,51,'MO',0,147,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1142,51,'MK',0,143,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1143,51,'MG',0,141,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1144,51,'MW',0,155,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1145,51,'MY',0,157,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1146,51,'MV',0,154,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1147,51,'ML',0,144,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1148,51,'MT',0,152,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1149,51,'MH',0,142,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1150,51,'MQ',0,149,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1151,51,'MR',0,150,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1152,51,'MU',0,153,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1153,51,'YT',0,245,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1154,51,'MX',0,156,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1155,51,'FM',0,72,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1156,51,'MD',0,138,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1157,51,'MC',0,137,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1158,51,'MN',0,146,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1159,51,'ME',0,139,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1160,51,'MS',0,151,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1161,51,'MA',0,136,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1162,51,'MZ',0,158,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1163,51,'MM',0,145,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1164,51,'NA',0,159,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1165,51,'NR',0,168,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1166,51,'NP',0,167,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1167,51,'NL',0,165,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1168,51,'NC',0,160,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1169,51,'NZ',0,170,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1170,51,'NI',0,164,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1171,51,'NE',0,161,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1172,51,'NG',0,163,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1173,51,'NU',0,169,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1174,51,'NF',0,162,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1175,51,'MP',0,148,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1176,51,'NO',0,166,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1177,51,'OM',0,171,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1178,51,'PK',0,177,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1179,51,'PW',0,184,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1180,51,'PS',0,182,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1181,51,'PA',0,172,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1182,51,'PG',0,175,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1183,51,'PY',0,185,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1184,51,'PE',0,173,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1185,51,'PH',0,176,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1186,51,'PN',0,180,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1187,51,'PL',0,178,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1188,51,'PT',0,183,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1189,51,'PR',0,181,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1190,51,'QA',0,186,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1191,51,'RE',0,187,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1192,51,'RO',0,188,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1193,51,'RU',0,190,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1194,51,'RW',0,191,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1195,51,'BL',0,25,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1196,51,'SH',0,198,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1197,51,'KN',0,119,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1198,51,'LC',0,127,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1199,51,'MF',0,140,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1200,51,'PM',0,179,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1201,51,'VC',0,236,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1202,51,'WS',0,243,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1203,51,'SM',0,203,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1204,51,'ST',0,208,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1205,51,'SA',0,192,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1206,51,'SN',0,204,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1207,51,'RS',0,189,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1208,51,'SC',0,194,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1209,51,'SL',0,202,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1210,51,'SG',0,197,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1211,51,'SX',0,210,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1212,51,'SK',0,201,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1213,51,'SI',0,199,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1214,51,'SB',0,193,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1215,51,'SO',0,205,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1216,51,'ZA',0,246,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1217,51,'GS',0,89,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1218,51,'SS',0,207,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1219,51,'ES',0,67,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1220,51,'LK',0,129,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1221,51,'SD',0,195,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1222,51,'SR',0,206,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1223,51,'SJ',0,200,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1224,51,'SZ',0,212,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1225,51,'SE',0,196,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1226,51,'CH',0,42,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1227,51,'SY',0,211,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1228,51,'TW',0,227,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1229,51,'TJ',0,218,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1230,51,'TZ',0,228,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1231,51,'TH',0,217,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1232,51,'TL',0,220,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1233,51,'TG',0,216,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1234,51,'TK',0,219,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1235,51,'TO',0,223,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1236,51,'TT',0,225,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1237,51,'TN',0,222,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1238,51,'TR',0,224,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1239,51,'TM',0,221,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1240,51,'TC',0,213,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1241,51,'TV',0,226,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1242,51,'UG',0,230,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1243,51,'UA',0,229,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1244,51,'AE',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1245,51,'GB',0,76,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1246,51,'US',0,232,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1247,51,'UM',0,231,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1248,51,'UY',0,233,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1249,51,'UZ',0,234,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1250,51,'VU',0,241,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1251,51,'VE',0,237,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1252,51,'VN',0,240,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1253,51,'VG',0,238,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1254,51,'VI',0,239,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1255,51,'WF',0,242,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1256,51,'EH',0,65,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1257,51,'YE',0,244,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1258,51,'ZM',0,247,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1259,51,'ZW',0,248,0,0,1,NULL,NULL,'2026-04-01 20:39:57','2026-04-01 20:39:57','2026-04-01 20:39:57'),(1260,52,'copyright',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1261,52,'license',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1262,52,'statute',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1263,52,'other',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1264,53,'copyrighted',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1265,53,'public_domain',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1266,53,'unknown',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1267,54,'cultural_context',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1268,54,'function',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1269,54,'geographic',0,3,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1270,54,'genre_form',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1271,54,'occupation',0,4,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1272,54,'style_period',0,5,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1273,54,'technique',0,6,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1274,54,'temporal',0,7,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1275,54,'topical',0,8,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1276,54,'uniform_title',0,9,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1277,55,'novalue',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1278,56,'novalue',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1279,57,'novalue',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1280,58,'novalue',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1281,34,'range',0,2,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1282,59,'has_part',0,1,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1283,59,'forms_part_of',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1284,60,'part',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1285,61,'sibling_of',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:59','2026-04-01 20:39:59','2026-04-01 20:39:59'),(1286,62,'bound_with',0,0,0,0,1,NULL,NULL,'2026-04-01 20:39:58','2026-04-01 20:39:58','2026-04-01 20:39:58'),(1290,1,'abr',0,226,0,0,1,NULL,NULL,NULL,NULL,NULL),(1291,1,'adi',0,227,0,0,1,NULL,NULL,NULL,NULL,NULL),(1292,1,'ape',0,228,0,0,1,NULL,NULL,NULL,NULL,NULL),(1293,1,'apl',0,229,0,0,1,NULL,NULL,NULL,NULL,NULL),(1294,1,'ato',0,230,0,0,1,NULL,NULL,NULL,NULL,NULL),(1295,1,'brd',0,231,0,0,1,NULL,NULL,NULL,NULL,NULL),(1296,1,'brl',0,232,0,0,1,NULL,NULL,NULL,NULL,NULL),(1297,1,'cas',0,233,0,0,1,NULL,NULL,NULL,NULL,NULL),(1298,1,'cor',0,234,0,0,1,NULL,NULL,NULL,NULL,NULL),(1299,1,'cou',0,235,0,0,1,NULL,NULL,NULL,NULL,NULL),(1300,1,'crt',0,236,0,0,1,NULL,NULL,NULL,NULL,NULL),(1301,1,'dgs',0,237,0,0,1,NULL,NULL,NULL,NULL,NULL),(1302,1,'edc',0,238,0,0,1,NULL,NULL,NULL,NULL,NULL),(1303,1,'edm',0,239,0,0,1,NULL,NULL,NULL,NULL,NULL),(1304,1,'enj',0,240,0,0,1,NULL,NULL,NULL,NULL,NULL),(1305,1,'fds',0,241,0,0,1,NULL,NULL,NULL,NULL,NULL),(1306,1,'fmd',0,242,0,0,1,NULL,NULL,NULL,NULL,NULL),(1307,1,'fmk',0,243,0,0,1,NULL,NULL,NULL,NULL,NULL),(1308,1,'fmp',0,244,0,0,1,NULL,NULL,NULL,NULL,NULL),(1309,1,'-grt',0,245,0,0,1,NULL,NULL,NULL,NULL,NULL),(1310,1,'his',0,246,0,0,1,NULL,NULL,NULL,NULL,NULL),(1311,1,'isb',0,247,0,0,1,NULL,NULL,NULL,NULL,NULL),(1312,1,'jud',0,248,0,0,1,NULL,NULL,NULL,NULL,NULL),(1313,1,'jug',0,249,0,0,1,NULL,NULL,NULL,NULL,NULL),(1314,1,'med',0,250,0,0,1,NULL,NULL,NULL,NULL,NULL),(1315,1,'mtk',0,251,0,0,1,NULL,NULL,NULL,NULL,NULL),(1316,1,'osp',0,252,0,0,1,NULL,NULL,NULL,NULL,NULL),(1317,1,'pan',0,253,0,0,1,NULL,NULL,NULL,NULL,NULL),(1318,1,'pra',0,254,0,0,1,NULL,NULL,NULL,NULL,NULL),(1319,1,'pre',0,255,0,0,1,NULL,NULL,NULL,NULL,NULL),(1320,1,'prn',0,256,0,0,1,NULL,NULL,NULL,NULL,NULL),(1321,1,'prs',0,257,0,0,1,NULL,NULL,NULL,NULL,NULL),(1322,1,'rdd',0,258,0,0,1,NULL,NULL,NULL,NULL,NULL),(1323,1,'rpc',0,259,0,0,1,NULL,NULL,NULL,NULL,NULL),(1324,1,'rsr',0,260,0,0,1,NULL,NULL,NULL,NULL,NULL),(1325,1,'sgd',0,261,0,0,1,NULL,NULL,NULL,NULL,NULL),(1326,1,'sll',0,262,0,0,1,NULL,NULL,NULL,NULL,NULL),(1327,1,'tld',0,263,0,0,1,NULL,NULL,NULL,NULL,NULL),(1328,1,'tlp',0,264,0,0,1,NULL,NULL,NULL,NULL,NULL),(1329,1,'vac',0,265,0,0,1,NULL,NULL,NULL,NULL,NULL),(1330,1,'wac',0,266,0,0,1,NULL,NULL,NULL,NULL,NULL),(1331,1,'wal',0,267,0,0,1,NULL,NULL,NULL,NULL,NULL),(1332,1,'wat',0,268,0,0,1,NULL,NULL,NULL,NULL,NULL),(1333,1,'win',0,269,0,0,1,NULL,NULL,NULL,NULL,NULL),(1334,1,'wpr',0,270,0,0,1,NULL,NULL,NULL,NULL,NULL),(1335,1,'wst',0,271,0,0,1,NULL,NULL,NULL,NULL,NULL),(1336,64,'business',0,0,0,0,1,NULL,NULL,NULL,NULL,NULL),(1337,64,'home',0,1,0,0,1,NULL,NULL,NULL,NULL,NULL),(1338,64,'cell',0,2,0,0,1,NULL,NULL,NULL,NULL,NULL),(1339,64,'fax',0,3,0,0,1,NULL,NULL,NULL,NULL,NULL),(1340,15,'processing_started',0,33,0,0,1,NULL,NULL,NULL,NULL,NULL),(1341,15,'processing_completed',0,34,0,0,1,NULL,NULL,NULL,NULL,NULL),(1342,15,'processing_in_progress',0,35,0,0,1,NULL,NULL,NULL,NULL,NULL),(1343,15,'processing_new',0,36,0,0,1,NULL,NULL,NULL,NULL,NULL),(1344,65,'RestrictedSpecColl',0,0,0,0,1,NULL,NULL,NULL,NULL,NULL),(1345,65,'RestrictedCurApprSpecColl',0,1,0,0,1,NULL,NULL,NULL,NULL,NULL),(1346,65,'RestrictedFragileSpecColl',0,2,0,0,1,NULL,NULL,NULL,NULL,NULL),(1347,65,'InProcessSpecColl',0,3,0,0,1,NULL,NULL,NULL,NULL,NULL),(1348,65,'ColdStorageBrbl',0,4,0,0,1,NULL,NULL,NULL,NULL,NULL),(1349,66,'inches',0,0,0,0,1,NULL,NULL,NULL,NULL,NULL),(1350,66,'feet',0,1,0,0,1,NULL,NULL,NULL,NULL,NULL),(1351,66,'yards',0,2,0,0,1,NULL,NULL,NULL,NULL,NULL),(1352,66,'millimeters',0,3,0,0,1,NULL,NULL,NULL,NULL,NULL),(1353,66,'centimeters',0,4,0,0,1,NULL,NULL,NULL,NULL,NULL),(1354,66,'meters',0,5,0,0,1,NULL,NULL,NULL,NULL,NULL),(1357,67,'av_materials',0,0,0,0,1,NULL,NULL,NULL,NULL,NULL),(1358,67,'arrivals',0,1,0,0,1,NULL,NULL,NULL,NULL,NULL),(1359,67,'shared',0,2,0,0,1,NULL,NULL,NULL,NULL,NULL),(1360,68,'delete',0,0,0,0,1,NULL,NULL,NULL,NULL,NULL),(1361,68,'disseminate',0,1,0,0,1,NULL,NULL,NULL,NULL,NULL),(1362,68,'migrate',0,2,0,0,1,NULL,NULL,NULL,NULL,NULL),(1363,68,'modify',0,3,0,0,1,NULL,NULL,NULL,NULL,NULL),(1364,68,'replicate',0,4,0,0,1,NULL,NULL,NULL,NULL,NULL),(1365,68,'use',0,5,0,0,1,NULL,NULL,NULL,NULL,NULL),(1366,69,'allow',0,0,0,0,1,NULL,NULL,NULL,NULL,NULL),(1367,69,'disallow',0,1,0,0,1,NULL,NULL,NULL,NULL,NULL),(1368,69,'conditional',0,2,0,0,1,NULL,NULL,NULL,NULL,NULL),(1369,70,'permissions',0,0,0,0,1,NULL,NULL,NULL,NULL,NULL),(1370,70,'restrictions',0,1,0,0,1,NULL,NULL,NULL,NULL,NULL),(1371,70,'extension',0,2,0,0,1,NULL,NULL,NULL,NULL,NULL),(1372,70,'expiration',0,3,0,0,1,NULL,NULL,NULL,NULL,NULL),(1373,70,'additional_information',0,4,0,0,1,NULL,NULL,NULL,NULL,NULL),(1374,71,'materials',0,0,0,0,1,NULL,NULL,NULL,NULL,NULL),(1375,71,'type_note',0,1,0,0,1,NULL,NULL,NULL,NULL,NULL),(1376,71,'additional_information',0,2,0,0,1,NULL,NULL,NULL,NULL,NULL),(1377,72,'agrovoc',0,0,0,0,1,NULL,NULL,NULL,NULL,NULL),(1378,72,'allmovie',0,1,0,0,1,NULL,NULL,NULL,NULL,NULL),(1379,72,'allmusic',0,2,0,0,1,NULL,NULL,NULL,NULL,NULL),(1380,72,'allocine',0,3,0,0,1,NULL,NULL,NULL,NULL,NULL),(1381,72,'amnbo',0,4,0,0,1,NULL,NULL,NULL,NULL,NULL),(1382,72,'ansi',0,5,0,0,1,NULL,NULL,NULL,NULL,NULL),(1383,72,'artsy',0,6,0,0,1,NULL,NULL,NULL,NULL,NULL),(1384,72,'bdusc',0,7,0,0,1,NULL,NULL,NULL,NULL,NULL),(1385,72,'bfi',0,8,0,0,1,NULL,NULL,NULL,NULL,NULL),(1386,72,'bnfcg',0,9,0,0,1,NULL,NULL,NULL,NULL,NULL),(1387,72,'cantic',0,10,0,0,1,NULL,NULL,NULL,NULL,NULL),(1388,72,'cgndb',0,11,0,0,1,NULL,NULL,NULL,NULL,NULL),(1389,72,'danacode',0,12,0,0,1,NULL,NULL,NULL,NULL,NULL),(1390,72,'datoses',0,13,0,0,1,NULL,NULL,NULL,NULL,NULL),(1391,72,'discogs',0,14,0,0,1,NULL,NULL,NULL,NULL,NULL),(1392,72,'dkfilm',0,15,0,0,1,NULL,NULL,NULL,NULL,NULL),(1393,72,'doi',0,16,0,0,1,NULL,NULL,NULL,NULL,NULL),(1394,72,'ean',0,17,0,0,1,NULL,NULL,NULL,NULL,NULL),(1395,72,'eidr',0,18,0,0,1,NULL,NULL,NULL,NULL,NULL),(1396,72,'fast',0,19,0,0,1,NULL,NULL,NULL,NULL,NULL),(1397,72,'filmport',0,20,0,0,1,NULL,NULL,NULL,NULL,NULL),(1398,72,'findagr',0,21,0,0,1,NULL,NULL,NULL,NULL,NULL),(1399,72,'freebase',0,22,0,0,1,NULL,NULL,NULL,NULL,NULL),(1400,72,'gec',0,23,0,0,1,NULL,NULL,NULL,NULL,NULL),(1401,72,'geogndb',0,24,0,0,1,NULL,NULL,NULL,NULL,NULL),(1402,72,'geonames',0,25,0,0,1,NULL,NULL,NULL,NULL,NULL),(1403,72,'gettytgn',0,26,0,0,1,NULL,NULL,NULL,NULL,NULL),(1404,72,'gettyulan',0,27,0,0,1,NULL,NULL,NULL,NULL,NULL),(1405,72,'gnd',0,28,0,0,1,NULL,NULL,NULL,NULL,NULL),(1406,72,'gnis',0,29,0,0,1,NULL,NULL,NULL,NULL,NULL),(1407,72,'gtin-14',0,30,0,0,1,NULL,NULL,NULL,NULL,NULL),(1408,72,'hdl',0,31,0,0,1,NULL,NULL,NULL,NULL,NULL),(1409,72,'ibdb',0,32,0,0,1,NULL,NULL,NULL,NULL,NULL),(1410,72,'idref',0,33,0,0,1,NULL,NULL,NULL,NULL,NULL),(1411,72,'imdb',0,34,0,0,1,NULL,NULL,NULL,NULL,NULL),(1412,72,'isan',0,35,0,0,1,NULL,NULL,NULL,NULL,NULL),(1413,72,'isbn',0,36,0,0,1,NULL,NULL,NULL,NULL,NULL),(1414,72,'isbn-a',0,37,0,0,1,NULL,NULL,NULL,NULL,NULL),(1415,72,'isbnre',0,38,0,0,1,NULL,NULL,NULL,NULL,NULL),(1416,72,'isil',0,39,0,0,1,NULL,NULL,NULL,NULL,NULL),(1417,72,'ismn',0,40,0,0,1,NULL,NULL,NULL,NULL,NULL),(1418,72,'isni',0,41,0,0,1,NULL,NULL,NULL,NULL,NULL),(1419,72,'iso',0,42,0,0,1,NULL,NULL,NULL,NULL,NULL),(1420,72,'isrc',0,43,0,0,1,NULL,NULL,NULL,NULL,NULL),(1421,72,'issn',0,44,0,0,1,NULL,NULL,NULL,NULL,NULL),(1422,72,'issn-l',0,45,0,0,1,NULL,NULL,NULL,NULL,NULL),(1423,72,'issue-number',0,46,0,0,1,NULL,NULL,NULL,NULL,NULL),(1424,72,'istc',0,47,0,0,1,NULL,NULL,NULL,NULL,NULL),(1425,72,'iswc',0,48,0,0,1,NULL,NULL,NULL,NULL,NULL),(1426,72,'itar',0,49,0,0,1,NULL,NULL,NULL,NULL,NULL),(1427,72,'kinopo',0,50,0,0,1,NULL,NULL,NULL,NULL,NULL),(1428,72,'lccn',0,51,0,0,1,NULL,NULL,NULL,NULL,NULL),(1429,72,'lcmd',0,52,0,0,1,NULL,NULL,NULL,NULL,NULL),(1430,72,'lcmpt',0,53,0,0,1,NULL,NULL,NULL,NULL,NULL),(1431,72,'libaus',0,54,0,0,1,NULL,NULL,NULL,NULL,NULL),(1432,72,'local',0,55,0,0,1,NULL,NULL,NULL,NULL,NULL),(1433,72,'matrix-number',0,56,0,0,1,NULL,NULL,NULL,NULL,NULL),(1434,72,'moma',0,57,0,0,1,NULL,NULL,NULL,NULL,NULL),(1435,72,'munzing',0,58,0,0,1,NULL,NULL,NULL,NULL,NULL),(1436,72,'music-plate',0,59,0,0,1,NULL,NULL,NULL,NULL,NULL),(1437,72,'music-publisher',0,60,0,0,1,NULL,NULL,NULL,NULL,NULL),(1438,72,'musicb',0,61,0,0,1,NULL,NULL,NULL,NULL,NULL),(1439,72,'natgazfid',0,62,0,0,1,NULL,NULL,NULL,NULL,NULL),(1440,72,'nga',0,63,0,0,1,NULL,NULL,NULL,NULL,NULL),(1441,72,'nipo',0,64,0,0,1,NULL,NULL,NULL,NULL,NULL),(1442,72,'nndb',0,65,0,0,1,NULL,NULL,NULL,NULL,NULL),(1443,72,'npg',0,66,0,0,1,NULL,NULL,NULL,NULL,NULL),(1444,72,'odnb',0,67,0,0,1,NULL,NULL,NULL,NULL,NULL),(1445,72,'opensm',0,68,0,0,1,NULL,NULL,NULL,NULL,NULL),(1446,72,'orcid',0,69,0,0,1,NULL,NULL,NULL,NULL,NULL),(1447,72,'oxforddnb',0,70,0,0,1,NULL,NULL,NULL,NULL,NULL),(1448,72,'porthu',0,71,0,0,1,NULL,NULL,NULL,NULL,NULL),(1449,72,'rbmsbt',0,72,0,0,1,NULL,NULL,NULL,NULL,NULL),(1450,72,'rbmsgt',0,73,0,0,1,NULL,NULL,NULL,NULL,NULL),(1451,72,'rbmspe',0,74,0,0,1,NULL,NULL,NULL,NULL,NULL),(1452,72,'rbmsppe',0,75,0,0,1,NULL,NULL,NULL,NULL,NULL),(1453,72,'rbmspt',0,76,0,0,1,NULL,NULL,NULL,NULL,NULL),(1454,72,'rbmsrd',0,77,0,0,1,NULL,NULL,NULL,NULL,NULL),(1455,72,'rbmste',0,78,0,0,1,NULL,NULL,NULL,NULL,NULL),(1456,72,'rid',0,79,0,0,1,NULL,NULL,NULL,NULL,NULL),(1457,72,'rkda',0,80,0,0,1,NULL,NULL,NULL,NULL,NULL),(1458,72,'saam',0,81,0,0,1,NULL,NULL,NULL,NULL,NULL),(1459,72,'scholaru',0,82,0,0,1,NULL,NULL,NULL,NULL,NULL),(1460,72,'scope',0,83,0,0,1,NULL,NULL,NULL,NULL,NULL),(1461,72,'scopus',0,84,0,0,1,NULL,NULL,NULL,NULL,NULL),(1462,72,'sici',0,85,0,0,1,NULL,NULL,NULL,NULL,NULL),(1463,72,'spotify',0,86,0,0,1,NULL,NULL,NULL,NULL,NULL),(1464,72,'sprfbsb',0,87,0,0,1,NULL,NULL,NULL,NULL,NULL),(1465,72,'sprfbsk',0,88,0,0,1,NULL,NULL,NULL,NULL,NULL),(1466,72,'sprfcbb',0,89,0,0,1,NULL,NULL,NULL,NULL,NULL),(1467,72,'sprfcfb',0,90,0,0,1,NULL,NULL,NULL,NULL,NULL),(1468,72,'sprfhoc',0,91,0,0,1,NULL,NULL,NULL,NULL,NULL),(1469,72,'sprfoly',0,92,0,0,1,NULL,NULL,NULL,NULL,NULL),(1470,72,'sprfpfb',0,93,0,0,1,NULL,NULL,NULL,NULL,NULL),(1471,72,'stock-number',0,94,0,0,1,NULL,NULL,NULL,NULL,NULL),(1472,72,'strn',0,95,0,0,1,NULL,NULL,NULL,NULL,NULL),(1473,72,'svfilm',0,96,0,0,1,NULL,NULL,NULL,NULL,NULL),(1474,72,'tatearid',0,97,0,0,1,NULL,NULL,NULL,NULL,NULL),(1475,72,'theatr',0,98,0,0,1,NULL,NULL,NULL,NULL,NULL),(1476,72,'trove',0,99,0,0,1,NULL,NULL,NULL,NULL,NULL),(1477,72,'upc',0,100,0,0,1,NULL,NULL,NULL,NULL,NULL),(1478,72,'uri',0,101,0,0,1,NULL,NULL,NULL,NULL,NULL),(1479,72,'urn',0,102,0,0,1,NULL,NULL,NULL,NULL,NULL),(1480,72,'viaf',0,103,0,0,1,NULL,NULL,NULL,NULL,NULL),(1481,72,'videorecording-identifier',0,104,0,0,1,NULL,NULL,NULL,NULL,NULL),(1482,72,'wikidata',0,105,0,0,1,NULL,NULL,NULL,NULL,NULL),(1483,72,'wndla',0,106,0,0,1,NULL,NULL,NULL,NULL,NULL),(1484,73,'donor',0,0,0,0,1,NULL,NULL,NULL,NULL,NULL),(1485,73,'policy',0,1,0,0,1,NULL,NULL,NULL,NULL,NULL),(1486,15,'request',1,37,0,0,1,NULL,NULL,'2026-04-01 20:40:01','2026-04-01 20:40:01','2026-04-01 20:40:01'),(1487,18,'cancelled',1,3,0,0,1,NULL,NULL,'2026-04-01 20:40:01','2026-04-01 20:40:01','2026-04-01 20:40:01'),(1488,18,'fulfilled',1,4,0,0,1,NULL,NULL,'2026-04-01 20:40:01','2026-04-01 20:40:01','2026-04-01 20:40:01'),(1489,18,'pending',1,5,0,0,1,NULL,NULL,'2026-04-01 20:40:01','2026-04-01 20:40:01','2026-04-01 20:40:01'),(1490,3,'requester',1,6,0,0,1,NULL,NULL,'2026-04-01 20:40:01','2026-04-01 20:40:01','2026-04-01 20:40:01'),(1491,2,'context',1,3,0,0,1,NULL,NULL,'2026-04-01 20:40:01','2026-04-01 20:40:01','2026-04-01 20:40:01'),(1492,2,'requested',1,4,0,0,1,NULL,NULL,'2026-04-01 20:40:01','2026-04-01 20:40:01','2026-04-01 20:40:01'),(1493,26,'cnr',0,485,0,0,1,NULL,NULL,NULL,NULL,NULL),(1494,26,'zgh',0,486,0,0,1,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `enumeration_value` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `repo_id` int(11) NOT NULL,
  `event_type_id` int(11) NOT NULL,
  `outcome_id` int(11) DEFAULT NULL,
  `outcome_note` varchar(17408) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `refid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `refid` (`refid`),
  KEY `event_type_id` (`event_type_id`),
  KEY `outcome_id` (`outcome_id`),
  KEY `event_system_mtime_index` (`system_mtime`),
  KEY `event_user_mtime_index` (`user_mtime`),
  KEY `event_suppressed_index` (`suppressed`),
  KEY `repo_id` (`repo_id`),
  CONSTRAINT `event_ibfk_1` FOREIGN KEY (`event_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `event_ibfk_2` FOREIGN KEY (`outcome_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `event_ibfk_3` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event`
--

LOCK TABLES `event` WRITE;
/*!40000 ALTER TABLE `event` DISABLE KEYS */;
INSERT INTO `event` VALUES (1,0,1,0,1,295,NULL,NULL,'2026-04-01 20:40:12',NULL,NULL,'2026-04-01 20:40:12','2026-04-01 20:40:12','2026-04-01 20:40:12',NULL),(2,0,1,0,1,295,NULL,NULL,'2026-04-01 20:40:12',NULL,NULL,'2026-04-01 20:40:12','2026-04-01 20:40:12','2026-04-01 20:40:12',NULL);
/*!40000 ALTER TABLE `event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_link_rlshp`
--

DROP TABLE IF EXISTS `event_link_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_link_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `accession_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `digital_object_component_id` int(11) DEFAULT NULL,
  `agent_person_id` int(11) DEFAULT NULL,
  `agent_family_id` int(11) DEFAULT NULL,
  `agent_corporate_entity_id` int(11) DEFAULT NULL,
  `agent_software_id` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `role_id` int(11) DEFAULT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `top_container_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  KEY `event_link_rlshp_system_mtime_index` (`system_mtime`),
  KEY `event_link_rlshp_user_mtime_index` (`user_mtime`),
  KEY `accession_id` (`accession_id`),
  KEY `resource_id` (`resource_id`),
  KEY `archival_object_id` (`archival_object_id`),
  KEY `digital_object_id` (`digital_object_id`),
  KEY `agent_person_id` (`agent_person_id`),
  KEY `agent_family_id` (`agent_family_id`),
  KEY `agent_corporate_entity_id` (`agent_corporate_entity_id`),
  KEY `agent_software_id` (`agent_software_id`),
  KEY `event_id` (`event_id`),
  KEY `top_container_id` (`top_container_id`),
  CONSTRAINT `event_link_rlshp_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `event_link_rlshp_ibfk_10` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`),
  CONSTRAINT `event_link_rlshp_ibfk_11` FOREIGN KEY (`top_container_id`) REFERENCES `top_container` (`id`),
  CONSTRAINT `event_link_rlshp_ibfk_2` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `event_link_rlshp_ibfk_3` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `event_link_rlshp_ibfk_4` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`),
  CONSTRAINT `event_link_rlshp_ibfk_5` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `event_link_rlshp_ibfk_6` FOREIGN KEY (`agent_person_id`) REFERENCES `agent_person` (`id`),
  CONSTRAINT `event_link_rlshp_ibfk_7` FOREIGN KEY (`agent_family_id`) REFERENCES `agent_family` (`id`),
  CONSTRAINT `event_link_rlshp_ibfk_8` FOREIGN KEY (`agent_corporate_entity_id`) REFERENCES `agent_corporate_entity` (`id`),
  CONSTRAINT `event_link_rlshp_ibfk_9` FOREIGN KEY (`agent_software_id`) REFERENCES `agent_software` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_link_rlshp`
--

LOCK TABLES `event_link_rlshp` WRITE;
/*!40000 ALTER TABLE `event_link_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `event_link_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `extent`
--

DROP TABLE IF EXISTS `extent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `extent` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `deaccession_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `digital_object_component_id` int(11) DEFAULT NULL,
  `portion_id` int(11) NOT NULL,
  `number` varchar(255) NOT NULL,
  `extent_type_id` int(11) NOT NULL,
  `container_summary` text,
  `physical_details` text,
  `dimensions` varchar(255) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `extent_type_id` (`extent_type_id`),
  KEY `extent_system_mtime_index` (`system_mtime`),
  KEY `extent_user_mtime_index` (`user_mtime`),
  KEY `accession_id` (`accession_id`),
  KEY `archival_object_id` (`archival_object_id`),
  KEY `resource_id` (`resource_id`),
  KEY `deaccession_id` (`deaccession_id`),
  KEY `digital_object_id` (`digital_object_id`),
  KEY `digital_object_component_id` (`digital_object_component_id`),
  CONSTRAINT `extent_ibfk_1` FOREIGN KEY (`extent_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `extent_ibfk_2` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `extent_ibfk_3` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`),
  CONSTRAINT `extent_ibfk_4` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `extent_ibfk_5` FOREIGN KEY (`deaccession_id`) REFERENCES `deaccession` (`id`),
  CONSTRAINT `extent_ibfk_6` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `extent_ibfk_7` FOREIGN KEY (`digital_object_component_id`) REFERENCES `digital_object_component` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `extent`
--

LOCK TABLES `extent` WRITE;
/*!40000 ALTER TABLE `extent` DISABLE KEYS */;
/*!40000 ALTER TABLE `extent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `external_document`
--

DROP TABLE IF EXISTS `external_document`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_document` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `title` varchar(8704) NOT NULL,
  `location` varchar(8704) NOT NULL,
  `publish` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `location_sha1` varchar(255) DEFAULT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `subject_id` int(11) DEFAULT NULL,
  `agent_person_id` int(11) DEFAULT NULL,
  `agent_family_id` int(11) DEFAULT NULL,
  `agent_corporate_entity_id` int(11) DEFAULT NULL,
  `agent_software_id` int(11) DEFAULT NULL,
  `rights_statement_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `digital_object_component_id` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `identifier_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_exdoc_acc` (`accession_id`,`location_sha1`),
  UNIQUE KEY `uniq_exdoc_arc_obj` (`archival_object_id`,`location_sha1`),
  UNIQUE KEY `uniq_exdoc_res` (`resource_id`,`location_sha1`),
  UNIQUE KEY `uniq_exdoc_sub` (`subject_id`,`location_sha1`),
  UNIQUE KEY `uniq_exdoc_age_per` (`agent_person_id`,`location_sha1`),
  UNIQUE KEY `uniq_exdoc_age_fam` (`agent_family_id`,`location_sha1`),
  UNIQUE KEY `uniq_exdoc_age_cor_ent` (`agent_corporate_entity_id`,`location_sha1`),
  UNIQUE KEY `uniq_exdoc_age_sof` (`agent_software_id`,`location_sha1`),
  UNIQUE KEY `uniq_exdoc_rig_sta` (`rights_statement_id`,`location_sha1`),
  UNIQUE KEY `uniq_exdoc_dig_obj` (`digital_object_id`,`location_sha1`),
  UNIQUE KEY `uniq_exdoc_dig_obj_com` (`digital_object_component_id`,`location_sha1`),
  KEY `external_document_system_mtime_index` (`system_mtime`),
  KEY `external_document_user_mtime_index` (`user_mtime`),
  KEY `event_external_document_fk` (`event_id`),
  KEY `external_document_identifier_type_id_fk` (`identifier_type_id`),
  CONSTRAINT `event_external_document_fk` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`),
  CONSTRAINT `external_document_ibfk_1` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `external_document_ibfk_10` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `external_document_ibfk_11` FOREIGN KEY (`digital_object_component_id`) REFERENCES `digital_object_component` (`id`),
  CONSTRAINT `external_document_ibfk_2` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`),
  CONSTRAINT `external_document_ibfk_3` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `external_document_ibfk_4` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`),
  CONSTRAINT `external_document_ibfk_5` FOREIGN KEY (`agent_person_id`) REFERENCES `agent_person` (`id`),
  CONSTRAINT `external_document_ibfk_6` FOREIGN KEY (`agent_family_id`) REFERENCES `agent_family` (`id`),
  CONSTRAINT `external_document_ibfk_7` FOREIGN KEY (`agent_corporate_entity_id`) REFERENCES `agent_corporate_entity` (`id`),
  CONSTRAINT `external_document_ibfk_8` FOREIGN KEY (`agent_software_id`) REFERENCES `agent_software` (`id`),
  CONSTRAINT `external_document_ibfk_9` FOREIGN KEY (`rights_statement_id`) REFERENCES `rights_statement` (`id`),
  CONSTRAINT `external_document_identifier_type_id_fk` FOREIGN KEY (`identifier_type_id`) REFERENCES `enumeration_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `external_document`
--

LOCK TABLES `external_document` WRITE;
/*!40000 ALTER TABLE `external_document` DISABLE KEYS */;
/*!40000 ALTER TABLE `external_document` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `external_id`
--

DROP TABLE IF EXISTS `external_id`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_id` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `external_id` varchar(255) NOT NULL,
  `source` varchar(255) NOT NULL,
  `subject_id` int(11) DEFAULT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `collection_management_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `digital_object_component_id` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `external_id_system_mtime_index` (`system_mtime`),
  KEY `external_id_user_mtime_index` (`user_mtime`),
  KEY `subject_id` (`subject_id`),
  KEY `accession_id` (`accession_id`),
  KEY `archival_object_id` (`archival_object_id`),
  KEY `collection_management_id` (`collection_management_id`),
  KEY `digital_object_id` (`digital_object_id`),
  KEY `digital_object_component_id` (`digital_object_component_id`),
  KEY `event_id` (`event_id`),
  KEY `location_id` (`location_id`),
  KEY `resource_id` (`resource_id`),
  CONSTRAINT `external_id_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`),
  CONSTRAINT `external_id_ibfk_2` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `external_id_ibfk_3` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`),
  CONSTRAINT `external_id_ibfk_4` FOREIGN KEY (`collection_management_id`) REFERENCES `collection_management` (`id`),
  CONSTRAINT `external_id_ibfk_5` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `external_id_ibfk_6` FOREIGN KEY (`digital_object_component_id`) REFERENCES `digital_object_component` (`id`),
  CONSTRAINT `external_id_ibfk_7` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`),
  CONSTRAINT `external_id_ibfk_8` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`),
  CONSTRAINT `external_id_ibfk_9` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `external_id`
--

LOCK TABLES `external_id` WRITE;
/*!40000 ALTER TABLE `external_id` DISABLE KEYS */;
/*!40000 ALTER TABLE `external_id` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_version`
--

DROP TABLE IF EXISTS `file_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `file_version` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `digital_object_component_id` int(11) DEFAULT NULL,
  `use_statement_id` int(11) DEFAULT NULL,
  `checksum_method_id` int(11) DEFAULT NULL,
  `file_uri` varchar(17408) NOT NULL,
  `publish` int(11) DEFAULT NULL,
  `xlink_actuate_attribute_id` int(11) DEFAULT NULL,
  `xlink_show_attribute_id` int(11) DEFAULT NULL,
  `file_format_name_id` int(11) DEFAULT NULL,
  `file_format_version` varchar(255) DEFAULT NULL,
  `file_size_bytes` int(11) DEFAULT NULL,
  `checksum` varchar(255) DEFAULT NULL,
  `checksum_method` varchar(255) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `is_representative` int(11) DEFAULT NULL,
  `caption` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `digital_object_one_representative_file_version` (`is_representative`,`digital_object_id`),
  KEY `use_statement_id` (`use_statement_id`),
  KEY `checksum_method_id` (`checksum_method_id`),
  KEY `xlink_actuate_attribute_id` (`xlink_actuate_attribute_id`),
  KEY `xlink_show_attribute_id` (`xlink_show_attribute_id`),
  KEY `file_format_name_id` (`file_format_name_id`),
  KEY `file_version_system_mtime_index` (`system_mtime`),
  KEY `file_version_user_mtime_index` (`user_mtime`),
  KEY `digital_object_id` (`digital_object_id`),
  KEY `digital_object_component_id` (`digital_object_component_id`),
  CONSTRAINT `file_version_ibfk_1` FOREIGN KEY (`use_statement_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `file_version_ibfk_2` FOREIGN KEY (`checksum_method_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `file_version_ibfk_3` FOREIGN KEY (`xlink_actuate_attribute_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `file_version_ibfk_4` FOREIGN KEY (`xlink_show_attribute_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `file_version_ibfk_5` FOREIGN KEY (`file_format_name_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `file_version_ibfk_6` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `file_version_ibfk_7` FOREIGN KEY (`digital_object_component_id`) REFERENCES `digital_object_component` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_version`
--

LOCK TABLES `file_version` WRITE;
/*!40000 ALTER TABLE `file_version` DISABLE KEYS */;
/*!40000 ALTER TABLE `file_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group`
--

DROP TABLE IF EXISTS `group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `repo_id` int(11) NOT NULL,
  `group_code` varchar(255) NOT NULL,
  `group_code_norm` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_uniq` (`repo_id`,`group_code_norm`),
  KEY `group_system_mtime_index` (`system_mtime`),
  KEY `group_user_mtime_index` (`user_mtime`),
  CONSTRAINT `group_repo_id_fk` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group`
--

LOCK TABLES `group` WRITE;
/*!40000 ALTER TABLE `group` DISABLE KEYS */;
INSERT INTO `group` VALUES (1,0,1,1,'administrators','administrators','Administrators',NULL,NULL,'2026-04-01 20:40:12','2026-04-01 20:40:12','2026-04-01 20:40:12'),(2,0,1,1,'searchindex','searchindex','Search index',NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(3,0,1,1,'publicanonymous','publicanonymous','Public Anonymous',NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(4,0,1,1,'staffsystem','staffsystem','Staff System Group',NULL,NULL,'2026-04-01 20:40:14','2026-04-01 20:40:14','2026-04-01 20:40:14');
/*!40000 ALTER TABLE `group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_permission`
--

DROP TABLE IF EXISTS `group_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `permission_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_permission_permission_id_group_id_index` (`permission_id`,`group_id`),
  KEY `group_permission_permission_id_index` (`permission_id`),
  KEY `group_permission_group_id_index` (`group_id`),
  CONSTRAINT `group_permission_group_id_fk` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`) ON DELETE CASCADE,
  CONSTRAINT `group_permission_ibfk_1` FOREIGN KEY (`permission_id`) REFERENCES `permission` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_permission`
--

LOCK TABLES `group_permission` WRITE;
/*!40000 ALTER TABLE `group_permission` DISABLE KEYS */;
INSERT INTO `group_permission` VALUES (25,1,1),(26,2,1),(30,3,1),(1,4,1),(2,5,1),(3,6,1),(4,7,1),(43,7,2),(46,7,3),(5,8,1),(6,9,1),(7,10,1),(8,11,1),(44,11,2),(9,12,1),(10,13,1),(11,14,1),(12,15,1),(13,16,1),(14,17,1),(15,18,1),(16,19,1),(17,20,1),(18,21,1),(42,21,2),(19,22,1),(41,22,2),(45,22,3),(20,23,1),(21,24,1),(22,25,1),(47,25,4),(23,26,1),(24,27,1),(27,28,1),(28,29,1),(29,30,1),(31,31,1),(32,32,1),(33,33,1),(34,34,1),(35,35,1),(36,36,1),(37,37,1),(38,38,1),(39,39,1),(40,40,1);
/*!40000 ALTER TABLE `group_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_user`
--

DROP TABLE IF EXISTS `group_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `group_user_group_id_index` (`group_id`),
  KEY `group_user_user_id_index` (`user_id`),
  CONSTRAINT `group_user_group_id_fk` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`) ON DELETE CASCADE,
  CONSTRAINT `group_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_user`
--

LOCK TABLES `group_user` WRITE;
/*!40000 ALTER TABLE `group_user` DISABLE KEYS */;
INSERT INTO `group_user` VALUES (1,1,1),(2,2,2),(3,3,3),(4,4,4);
/*!40000 ALTER TABLE `group_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `instance`
--

DROP TABLE IF EXISTS `instance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `instance_type_id` int(11) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `is_representative` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_one_representative_instance` (`is_representative`,`resource_id`),
  UNIQUE KEY `component_one_representative_instance` (`is_representative`,`archival_object_id`),
  KEY `instance_type_id` (`instance_type_id`),
  KEY `instance_system_mtime_index` (`system_mtime`),
  KEY `instance_user_mtime_index` (`user_mtime`),
  KEY `resource_id` (`resource_id`),
  KEY `archival_object_id` (`archival_object_id`),
  KEY `accession_id` (`accession_id`),
  CONSTRAINT `instance_ibfk_1` FOREIGN KEY (`instance_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `instance_ibfk_2` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `instance_ibfk_3` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`),
  CONSTRAINT `instance_ibfk_4` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `instance`
--

LOCK TABLES `instance` WRITE;
/*!40000 ALTER TABLE `instance` DISABLE KEYS */;
/*!40000 ALTER TABLE `instance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `instance_do_link_rlshp`
--

DROP TABLE IF EXISTS `instance_do_link_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_do_link_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `digital_object_id` int(11) DEFAULT NULL,
  `instance_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `instance_do_link_rlshp_system_mtime_index` (`system_mtime`),
  KEY `instance_do_link_rlshp_user_mtime_index` (`user_mtime`),
  KEY `digital_object_id` (`digital_object_id`),
  KEY `instance_id` (`instance_id`),
  CONSTRAINT `instance_do_link_rlshp_ibfk_1` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `instance_do_link_rlshp_ibfk_2` FOREIGN KEY (`instance_id`) REFERENCES `instance` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `instance_do_link_rlshp`
--

LOCK TABLES `instance_do_link_rlshp` WRITE;
/*!40000 ALTER TABLE `instance_do_link_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `instance_do_link_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job`
--

DROP TABLE IF EXISTS `job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `repo_id` int(11) NOT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `job_blob` mediumblob NOT NULL,
  `time_submitted` datetime NOT NULL,
  `time_started` datetime DEFAULT NULL,
  `time_finished` datetime DEFAULT NULL,
  `owner_id` int(11) NOT NULL,
  `status` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `job_params` varchar(255) DEFAULT NULL,
  `job_type` varchar(255) NOT NULL DEFAULT 'unknown_job_type',
  PRIMARY KEY (`id`),
  KEY `job_system_mtime_index` (`system_mtime`),
  KEY `job_user_mtime_index` (`user_mtime`),
  KEY `job_status_idx` (`status`),
  KEY `job_repo_id_fk` (`repo_id`),
  KEY `job_owner_id_fk` (`owner_id`),
  CONSTRAINT `job_owner_id_fk` FOREIGN KEY (`owner_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `job_repo_id_fk` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job`
--

LOCK TABLES `job` WRITE;
/*!40000 ALTER TABLE `job` DISABLE KEYS */;
/*!40000 ALTER TABLE `job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_created_record`
--

DROP TABLE IF EXISTS `job_created_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_created_record` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `record_uri` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `job_created_record_system_mtime_index` (`system_mtime`),
  KEY `job_created_record_user_mtime_index` (`user_mtime`),
  KEY `job_created_record_job_id_fk` (`job_id`),
  CONSTRAINT `job_created_record_job_id_fk` FOREIGN KEY (`job_id`) REFERENCES `job` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_created_record`
--

LOCK TABLES `job_created_record` WRITE;
/*!40000 ALTER TABLE `job_created_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_created_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_input_file`
--

DROP TABLE IF EXISTS `job_input_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_input_file` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `job_input_file_job_id_fk` (`job_id`),
  CONSTRAINT `job_input_file_job_id_fk` FOREIGN KEY (`job_id`) REFERENCES `job` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_input_file`
--

LOCK TABLES `job_input_file` WRITE;
/*!40000 ALTER TABLE `job_input_file` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_input_file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_modified_record`
--

DROP TABLE IF EXISTS `job_modified_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_modified_record` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `record_uri` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `job_modified_record_system_mtime_index` (`system_mtime`),
  KEY `job_modified_record_user_mtime_index` (`user_mtime`),
  KEY `job_modified_record_job_id_fk` (`job_id`),
  CONSTRAINT `job_modified_record_job_id_fk` FOREIGN KEY (`job_id`) REFERENCES `job` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_modified_record`
--

LOCK TABLES `job_modified_record` WRITE;
/*!40000 ALTER TABLE `job_modified_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_modified_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `linked_agent_term`
--

DROP TABLE IF EXISTS `linked_agent_term`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `linked_agent_term` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `linked_agents_rlshp_id` int(11) NOT NULL,
  `term_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `term_id` (`term_id`),
  KEY `linked_agent_term_idx` (`linked_agents_rlshp_id`,`term_id`),
  CONSTRAINT `linked_agent_term_ibfk_1` FOREIGN KEY (`linked_agents_rlshp_id`) REFERENCES `linked_agents_rlshp` (`id`),
  CONSTRAINT `linked_agent_term_ibfk_2` FOREIGN KEY (`term_id`) REFERENCES `term` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `linked_agent_term`
--

LOCK TABLES `linked_agent_term` WRITE;
/*!40000 ALTER TABLE `linked_agent_term` DISABLE KEYS */;
/*!40000 ALTER TABLE `linked_agent_term` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `linked_agents_rlshp`
--

DROP TABLE IF EXISTS `linked_agents_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `linked_agents_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_person_id` int(11) DEFAULT NULL,
  `agent_software_id` int(11) DEFAULT NULL,
  `agent_family_id` int(11) DEFAULT NULL,
  `agent_corporate_entity_id` int(11) DEFAULT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `digital_object_component_id` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `role_id` int(11) DEFAULT NULL,
  `relator_id` int(11) DEFAULT NULL,
  `title` varchar(8704) DEFAULT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `rights_statement_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  KEY `relator_id` (`relator_id`),
  KEY `linked_agents_rlshp_system_mtime_index` (`system_mtime`),
  KEY `linked_agents_rlshp_user_mtime_index` (`user_mtime`),
  KEY `agent_person_id` (`agent_person_id`),
  KEY `agent_software_id` (`agent_software_id`),
  KEY `agent_family_id` (`agent_family_id`),
  KEY `agent_corporate_entity_id` (`agent_corporate_entity_id`),
  KEY `accession_id` (`accession_id`),
  KEY `archival_object_id` (`archival_object_id`),
  KEY `digital_object_id` (`digital_object_id`),
  KEY `digital_object_component_id` (`digital_object_component_id`),
  KEY `event_id` (`event_id`),
  KEY `resource_id` (`resource_id`),
  KEY `rights_statement_id` (`rights_statement_id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_10` FOREIGN KEY (`digital_object_component_id`) REFERENCES `digital_object_component` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_11` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_12` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_13` FOREIGN KEY (`rights_statement_id`) REFERENCES `rights_statement` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_2` FOREIGN KEY (`relator_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_3` FOREIGN KEY (`agent_person_id`) REFERENCES `agent_person` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_4` FOREIGN KEY (`agent_software_id`) REFERENCES `agent_software` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_5` FOREIGN KEY (`agent_family_id`) REFERENCES `agent_family` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_6` FOREIGN KEY (`agent_corporate_entity_id`) REFERENCES `agent_corporate_entity` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_7` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_8` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`),
  CONSTRAINT `linked_agents_rlshp_ibfk_9` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `linked_agents_rlshp`
--

LOCK TABLES `linked_agents_rlshp` WRITE;
/*!40000 ALTER TABLE `linked_agents_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `linked_agents_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `building` varchar(255) NOT NULL,
  `title` varchar(8704) DEFAULT NULL,
  `floor` varchar(255) DEFAULT NULL,
  `room` varchar(255) DEFAULT NULL,
  `area` varchar(255) DEFAULT NULL,
  `barcode` varchar(255) DEFAULT NULL,
  `classification` varchar(255) DEFAULT NULL,
  `coordinate_1_label` varchar(255) DEFAULT NULL,
  `coordinate_1_indicator` varchar(255) DEFAULT NULL,
  `coordinate_2_label` varchar(255) DEFAULT NULL,
  `coordinate_2_indicator` varchar(255) DEFAULT NULL,
  `coordinate_3_label` varchar(255) DEFAULT NULL,
  `coordinate_3_indicator` varchar(255) DEFAULT NULL,
  `temporary_id` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `temporary_id` (`temporary_id`),
  KEY `location_system_mtime_index` (`system_mtime`),
  KEY `location_user_mtime_index` (`user_mtime`),
  CONSTRAINT `location_ibfk_1` FOREIGN KEY (`temporary_id`) REFERENCES `enumeration_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location`
--

LOCK TABLES `location` WRITE;
/*!40000 ALTER TABLE `location` DISABLE KEYS */;
/*!40000 ALTER TABLE `location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location_function`
--

DROP TABLE IF EXISTS `location_function`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location_function` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `location_function_type_id` int(11) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `location_function_type_id` (`location_function_type_id`),
  KEY `location_function_system_mtime_index` (`system_mtime`),
  KEY `location_function_user_mtime_index` (`user_mtime`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `location_function_ibfk_1` FOREIGN KEY (`location_function_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `location_function_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location_function`
--

LOCK TABLES `location_function` WRITE;
/*!40000 ALTER TABLE `location_function` DISABLE KEYS */;
/*!40000 ALTER TABLE `location_function` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location_profile`
--

DROP TABLE IF EXISTS `location_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `dimension_units_id` int(11) DEFAULT NULL,
  `height` varchar(255) DEFAULT NULL,
  `width` varchar(255) DEFAULT NULL,
  `depth` varchar(255) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `location_profile_name_uniq` (`name`),
  KEY `dimension_units_id` (`dimension_units_id`),
  KEY `location_profile_system_mtime_index` (`system_mtime`),
  KEY `location_profile_user_mtime_index` (`user_mtime`),
  CONSTRAINT `location_profile_ibfk_1` FOREIGN KEY (`dimension_units_id`) REFERENCES `enumeration_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location_profile`
--

LOCK TABLES `location_profile` WRITE;
/*!40000 ALTER TABLE `location_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `location_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location_profile_rlshp`
--

DROP TABLE IF EXISTS `location_profile_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location_profile_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location_id` int(11) DEFAULT NULL,
  `location_profile_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `location_profile_rlshp_system_mtime_index` (`system_mtime`),
  KEY `location_profile_rlshp_user_mtime_index` (`user_mtime`),
  KEY `location_id` (`location_id`),
  KEY `location_profile_id` (`location_profile_id`),
  CONSTRAINT `location_profile_rlshp_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`),
  CONSTRAINT `location_profile_rlshp_ibfk_2` FOREIGN KEY (`location_profile_id`) REFERENCES `location_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location_profile_rlshp`
--

LOCK TABLES `location_profile_rlshp` WRITE;
/*!40000 ALTER TABLE `location_profile_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `location_profile_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `name_authority_id`
--

DROP TABLE IF EXISTS `name_authority_id`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `name_authority_id` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `name_person_id` int(11) DEFAULT NULL,
  `name_family_id` int(11) DEFAULT NULL,
  `name_software_id` int(11) DEFAULT NULL,
  `name_corporate_entity_id` int(11) DEFAULT NULL,
  `authority_id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `authority_id` (`authority_id`),
  KEY `name_authority_id_system_mtime_index` (`system_mtime`),
  KEY `name_authority_id_user_mtime_index` (`user_mtime`),
  KEY `name_person_id` (`name_person_id`),
  KEY `name_family_id` (`name_family_id`),
  KEY `name_software_id` (`name_software_id`),
  KEY `name_corporate_entity_id` (`name_corporate_entity_id`),
  CONSTRAINT `name_authority_id_ibfk_1` FOREIGN KEY (`name_person_id`) REFERENCES `name_person` (`id`),
  CONSTRAINT `name_authority_id_ibfk_2` FOREIGN KEY (`name_family_id`) REFERENCES `name_family` (`id`),
  CONSTRAINT `name_authority_id_ibfk_3` FOREIGN KEY (`name_software_id`) REFERENCES `name_software` (`id`),
  CONSTRAINT `name_authority_id_ibfk_4` FOREIGN KEY (`name_corporate_entity_id`) REFERENCES `name_corporate_entity` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `name_authority_id`
--

LOCK TABLES `name_authority_id` WRITE;
/*!40000 ALTER TABLE `name_authority_id` DISABLE KEYS */;
/*!40000 ALTER TABLE `name_authority_id` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `name_corporate_entity`
--

DROP TABLE IF EXISTS `name_corporate_entity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `name_corporate_entity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `agent_corporate_entity_id` int(11) NOT NULL,
  `primary_name` text NOT NULL,
  `subordinate_name_1` text,
  `subordinate_name_2` text,
  `number` varchar(255) DEFAULT NULL,
  `dates` varchar(255) DEFAULT NULL,
  `qualifier` text,
  `source_id` int(11) DEFAULT NULL,
  `rules_id` int(11) DEFAULT NULL,
  `sort_name` text NOT NULL,
  `sort_name_auto_generate` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `authorized` int(11) DEFAULT NULL,
  `is_display_name` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `corporate_entity_one_authorized` (`authorized`,`agent_corporate_entity_id`),
  UNIQUE KEY `corporate_entity_one_display_name` (`is_display_name`,`agent_corporate_entity_id`),
  KEY `source_id` (`source_id`),
  KEY `rules_id` (`rules_id`),
  KEY `name_corporate_entity_system_mtime_index` (`system_mtime`),
  KEY `name_corporate_entity_user_mtime_index` (`user_mtime`),
  KEY `agent_corporate_entity_id` (`agent_corporate_entity_id`),
  CONSTRAINT `name_corporate_entity_ibfk_1` FOREIGN KEY (`source_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `name_corporate_entity_ibfk_2` FOREIGN KEY (`rules_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `name_corporate_entity_ibfk_3` FOREIGN KEY (`agent_corporate_entity_id`) REFERENCES `agent_corporate_entity` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `name_corporate_entity`
--

LOCK TABLES `name_corporate_entity` WRITE;
/*!40000 ALTER TABLE `name_corporate_entity` DISABLE KEYS */;
/*!40000 ALTER TABLE `name_corporate_entity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `name_family`
--

DROP TABLE IF EXISTS `name_family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `name_family` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `agent_family_id` int(11) NOT NULL,
  `family_name` text NOT NULL,
  `prefix` text,
  `dates` varchar(255) DEFAULT NULL,
  `qualifier` text,
  `source_id` int(11) DEFAULT NULL,
  `rules_id` int(11) DEFAULT NULL,
  `sort_name` text NOT NULL,
  `sort_name_auto_generate` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `authorized` int(11) DEFAULT NULL,
  `is_display_name` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `family_one_authorized` (`authorized`,`agent_family_id`),
  UNIQUE KEY `family_one_display_name` (`is_display_name`,`agent_family_id`),
  KEY `source_id` (`source_id`),
  KEY `rules_id` (`rules_id`),
  KEY `name_family_system_mtime_index` (`system_mtime`),
  KEY `name_family_user_mtime_index` (`user_mtime`),
  KEY `agent_family_id` (`agent_family_id`),
  CONSTRAINT `name_family_ibfk_1` FOREIGN KEY (`source_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `name_family_ibfk_2` FOREIGN KEY (`rules_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `name_family_ibfk_3` FOREIGN KEY (`agent_family_id`) REFERENCES `agent_family` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `name_family`
--

LOCK TABLES `name_family` WRITE;
/*!40000 ALTER TABLE `name_family` DISABLE KEYS */;
/*!40000 ALTER TABLE `name_family` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `name_person`
--

DROP TABLE IF EXISTS `name_person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `name_person` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `agent_person_id` int(11) NOT NULL,
  `primary_name` varchar(255) NOT NULL,
  `name_order_id` int(11) NOT NULL,
  `title` varchar(8704) DEFAULT NULL,
  `prefix` text,
  `rest_of_name` text,
  `suffix` text,
  `fuller_form` text,
  `number` varchar(255) DEFAULT NULL,
  `dates` varchar(255) DEFAULT NULL,
  `qualifier` text,
  `source_id` int(11) DEFAULT NULL,
  `rules_id` int(11) DEFAULT NULL,
  `sort_name` text NOT NULL,
  `sort_name_auto_generate` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `authorized` int(11) DEFAULT NULL,
  `is_display_name` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_one_authorized` (`authorized`,`agent_person_id`),
  UNIQUE KEY `person_one_display_name` (`is_display_name`,`agent_person_id`),
  KEY `name_order_id` (`name_order_id`),
  KEY `source_id` (`source_id`),
  KEY `rules_id` (`rules_id`),
  KEY `name_person_system_mtime_index` (`system_mtime`),
  KEY `name_person_user_mtime_index` (`user_mtime`),
  KEY `agent_person_id` (`agent_person_id`),
  CONSTRAINT `name_person_ibfk_1` FOREIGN KEY (`name_order_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `name_person_ibfk_2` FOREIGN KEY (`source_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `name_person_ibfk_3` FOREIGN KEY (`rules_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `name_person_ibfk_4` FOREIGN KEY (`agent_person_id`) REFERENCES `agent_person` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `name_person`
--

LOCK TABLES `name_person` WRITE;
/*!40000 ALTER TABLE `name_person` DISABLE KEYS */;
INSERT INTO `name_person` VALUES (1,0,1,1,'Administrator',947,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,236,240,'Administrator',1,NULL,NULL,'2026-04-01 20:40:12','2026-04-01 20:40:12','2026-04-01 20:40:12',1,1);
/*!40000 ALTER TABLE `name_person` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `name_software`
--

DROP TABLE IF EXISTS `name_software`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `name_software` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `agent_software_id` int(11) NOT NULL,
  `software_name` text NOT NULL,
  `version` text,
  `manufacturer` text,
  `dates` varchar(255) DEFAULT NULL,
  `qualifier` text,
  `source_id` int(11) DEFAULT NULL,
  `rules_id` int(11) DEFAULT NULL,
  `sort_name` text NOT NULL,
  `sort_name_auto_generate` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `authorized` int(11) DEFAULT NULL,
  `is_display_name` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `software_one_authorized` (`authorized`,`agent_software_id`),
  UNIQUE KEY `software_one_display_name` (`is_display_name`,`agent_software_id`),
  KEY `source_id` (`source_id`),
  KEY `rules_id` (`rules_id`),
  KEY `name_software_system_mtime_index` (`system_mtime`),
  KEY `name_software_user_mtime_index` (`user_mtime`),
  KEY `agent_software_id` (`agent_software_id`),
  CONSTRAINT `name_software_ibfk_1` FOREIGN KEY (`source_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `name_software_ibfk_2` FOREIGN KEY (`rules_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `name_software_ibfk_3` FOREIGN KEY (`agent_software_id`) REFERENCES `agent_software` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `name_software`
--

LOCK TABLES `name_software` WRITE;
/*!40000 ALTER TABLE `name_software` DISABLE KEYS */;
INSERT INTO `name_software` VALUES (1,0,1,1,'ArchivesSpace','v2.6.0',NULL,NULL,NULL,236,240,'ArchivesSpace v2.6.0',1,NULL,NULL,'2026-04-01 20:40:12','2026-04-01 20:40:12','2026-04-01 20:40:12',1,1);
/*!40000 ALTER TABLE `name_software` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `note`
--

DROP TABLE IF EXISTS `note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `note` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '1',
  `resource_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `digital_object_component_id` int(11) DEFAULT NULL,
  `agent_person_id` int(11) DEFAULT NULL,
  `agent_corporate_entity_id` int(11) DEFAULT NULL,
  `agent_family_id` int(11) DEFAULT NULL,
  `agent_software_id` int(11) DEFAULT NULL,
  `publish` int(11) DEFAULT NULL,
  `notes_json_schema_version` int(11) NOT NULL,
  `notes` mediumblob NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `rights_statement_act_id` int(11) DEFAULT NULL,
  `rights_statement_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `note_system_mtime_index` (`system_mtime`),
  KEY `note_user_mtime_index` (`user_mtime`),
  KEY `resource_id` (`resource_id`),
  KEY `archival_object_id` (`archival_object_id`),
  KEY `digital_object_id` (`digital_object_id`),
  KEY `digital_object_component_id` (`digital_object_component_id`),
  KEY `agent_person_id` (`agent_person_id`),
  KEY `agent_corporate_entity_id` (`agent_corporate_entity_id`),
  KEY `agent_family_id` (`agent_family_id`),
  KEY `agent_software_id` (`agent_software_id`),
  KEY `rights_statement_act_id` (`rights_statement_act_id`),
  KEY `rights_statement_id` (`rights_statement_id`),
  CONSTRAINT `note_ibfk_1` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `note_ibfk_10` FOREIGN KEY (`rights_statement_id`) REFERENCES `rights_statement` (`id`),
  CONSTRAINT `note_ibfk_2` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`),
  CONSTRAINT `note_ibfk_3` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `note_ibfk_4` FOREIGN KEY (`digital_object_component_id`) REFERENCES `digital_object_component` (`id`),
  CONSTRAINT `note_ibfk_5` FOREIGN KEY (`agent_person_id`) REFERENCES `agent_person` (`id`),
  CONSTRAINT `note_ibfk_6` FOREIGN KEY (`agent_corporate_entity_id`) REFERENCES `agent_corporate_entity` (`id`),
  CONSTRAINT `note_ibfk_7` FOREIGN KEY (`agent_family_id`) REFERENCES `agent_family` (`id`),
  CONSTRAINT `note_ibfk_8` FOREIGN KEY (`agent_software_id`) REFERENCES `agent_software` (`id`),
  CONSTRAINT `note_ibfk_9` FOREIGN KEY (`rights_statement_act_id`) REFERENCES `rights_statement_act` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `note`
--

LOCK TABLES `note` WRITE;
/*!40000 ALTER TABLE `note` DISABLE KEYS */;
/*!40000 ALTER TABLE `note` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `note_persistent_id`
--

DROP TABLE IF EXISTS `note_persistent_id`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `note_persistent_id` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) NOT NULL,
  `persistent_id` varchar(255) NOT NULL,
  `parent_type` varchar(255) NOT NULL,
  `parent_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `note_id` (`note_id`),
  CONSTRAINT `note_persistent_id_ibfk_1` FOREIGN KEY (`note_id`) REFERENCES `note` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `note_persistent_id`
--

LOCK TABLES `note_persistent_id` WRITE;
/*!40000 ALTER TABLE `note_persistent_id` DISABLE KEYS */;
/*!40000 ALTER TABLE `note_persistent_id` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification`
--

DROP TABLE IF EXISTS `notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notification` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime NOT NULL,
  `code` varchar(255) NOT NULL,
  `params` blob NOT NULL,
  PRIMARY KEY (`id`),
  KEY `notification_time_index` (`time`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification`
--

LOCK TABLES `notification` WRITE;
/*!40000 ALTER TABLE `notification` DISABLE KEYS */;
INSERT INTO `notification` VALUES (1,'2026-04-01 20:40:14','REFRESH_ACLS',_binary '{}'),(2,'2026-04-01 20:40:14','REFRESH_PREFERENCES',_binary '{}'),(3,'2026-04-01 20:40:14','BACKEND_STARTED',_binary '{}'),(4,'2026-04-01 20:48:29','BACKEND_STARTED',_binary '{}');
/*!40000 ALTER TABLE `notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oai_config`
--

DROP TABLE IF EXISTS `oai_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oai_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `oai_repository_name` varchar(255) DEFAULT NULL,
  `oai_record_prefix` varchar(255) DEFAULT NULL,
  `oai_admin_email` varchar(255) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `system_mtime` datetime DEFAULT NULL,
  `user_mtime` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `repo_set_codes` text,
  `repo_set_description` varchar(255) DEFAULT NULL,
  `sponsor_set_names` text,
  `sponsor_set_description` varchar(255) DEFAULT NULL,
  `repo_set_name` varchar(255) DEFAULT NULL,
  `sponsor_set_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oai_config`
--

LOCK TABLES `oai_config` WRITE;
/*!40000 ALTER TABLE `oai_config` DISABLE KEYS */;
INSERT INTO `oai_config` VALUES (1,'ArchivesSpace OAI Provider','oai:archivesspace','admin@example.com','admin',NULL,'2026-04-01 20:40:01','2026-04-01 20:40:01','2026-04-01 20:40:01',0,'[]','','[]','','repository_set','sponsor_set');
/*!40000 ALTER TABLE `oai_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `owner_repo_rlshp`
--

DROP TABLE IF EXISTS `owner_repo_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `owner_repo_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location_id` int(11) DEFAULT NULL,
  `repository_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `owner_repo_rlshp_system_mtime_index` (`system_mtime`),
  KEY `owner_repo_rlshp_user_mtime_index` (`user_mtime`),
  KEY `location_id` (`location_id`),
  KEY `repository_id` (`repository_id`),
  CONSTRAINT `owner_repo_rlshp_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`),
  CONSTRAINT `owner_repo_rlshp_ibfk_2` FOREIGN KEY (`repository_id`) REFERENCES `repository` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `owner_repo_rlshp`
--

LOCK TABLES `owner_repo_rlshp` WRITE;
/*!40000 ALTER TABLE `owner_repo_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `owner_repo_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permission`
--

DROP TABLE IF EXISTS `permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `permission_code` varchar(255) DEFAULT NULL,
  `description` text NOT NULL,
  `level` varchar(255) DEFAULT 'repository',
  `system` int(11) NOT NULL DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permission_code` (`permission_code`),
  KEY `permission_system_mtime_index` (`system_mtime`),
  KEY `permission_user_mtime_index` (`user_mtime`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permission`
--

LOCK TABLES `permission` WRITE;
/*!40000 ALTER TABLE `permission` DISABLE KEYS */;
INSERT INTO `permission` VALUES (1,'create_job','The ability to create background jobs','repository',0,'admin','admin','2026-04-01 20:40:00','2026-04-01 20:40:00','2026-04-01 20:40:00'),(2,'cancel_job','The ability to cancel background jobs','repository',0,'admin','admin','2026-04-01 20:40:00','2026-04-01 20:40:00','2026-04-01 20:40:00'),(3,'manage_enumeration_record','The ability to create, modify and delete a controlled vocabulary list record','repository',0,'admin','admin','2026-04-01 20:40:01','2026-04-01 20:40:01','2026-04-01 20:40:01'),(4,'administer_system','The ability to act as a system administrator','global',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(5,'manage_users','The ability to manage user accounts while logged in','global',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(6,'become_user','The ability to masquerade as another user','global',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(7,'view_all_records','The ability to view any record in the system','global',1,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(8,'create_repository','The ability to create new repositories','global',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(9,'delete_repository','The ability to delete a repository','global',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(10,'transfer_repository','The ability to transfer the contents of a repository','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(11,'index_system','The ability to read any record for indexing','global',1,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(12,'manage_repository','The ability to manage a given repository','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(13,'update_accession_record','The ability to create and modify accessions records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(14,'update_resource_record','The ability to create and modify resources records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(15,'update_digital_object_record','The ability to create and modify digital objects records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(16,'update_event_record','The ability to create and modify event records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(17,'delete_event_record','The ability to delete event records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(18,'suppress_archival_record','The ability to suppress the major archival record types: accessions/resources/digital objects/components/collection management/events','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(19,'transfer_archival_record','The ability to transfer records between different repositories','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(20,'delete_archival_record','The ability to delete the major archival record types: accessions/resources/digital objects/components/collection management/events','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(21,'view_suppressed','The ability to view suppressed records in a given repository','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(22,'view_repository','The ability to view a given repository','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(23,'update_classification_record','The ability to create and modify classification records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(24,'delete_classification_record','The ability to delete classification records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(25,'mediate_edits','Track concurrent updates to records','global',1,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(26,'import_records','The ability to initiate an importer job','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(27,'cancel_importer_job','The ability to cancel a queued or running importer job','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(28,'manage_subject_record','The ability to create, modify and delete a subject record','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(29,'manage_agent_record','The ability to create, modify and delete an agent record','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(30,'manage_vocabulary_record','The ability to create, modify and delete a vocabulary record','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(31,'merge_agents_and_subjects','The ability to merge agent/subject records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(32,'merge_archival_record','The ability to merge archival records records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(33,'manage_rde_templates','The ability to create and delete RDE templates','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(34,'update_container_record','The ability to create and update container records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(35,'manage_container_record','The ability to delete and bulk update container records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(36,'manage_container_profile_record','The ability to create, modify and delete a container profile record','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(37,'manage_location_profile_record','The ability to create, modify and delete a location profile record','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(38,'update_assessment_record','The ability to create and modify assessment records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(39,'delete_assessment_record','The ability to delete assessment records','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(40,'manage_assessment_attributes','The ability to managae assessment attribute definitions','repository',0,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13');
/*!40000 ALTER TABLE `permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `preference`
--

DROP TABLE IF EXISTS `preference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `preference` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `repo_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_uniq` varchar(255) NOT NULL,
  `defaults` mediumblob NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `preference_uniq` (`repo_id`,`user_uniq`),
  KEY `preference_system_mtime_index` (`system_mtime`),
  KEY `preference_user_mtime_index` (`user_mtime`),
  KEY `preference_user_id_fk` (`user_id`),
  CONSTRAINT `preference_repo_id_fk` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`) ON DELETE CASCADE,
  CONSTRAINT `preference_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `preference`
--

LOCK TABLES `preference` WRITE;
/*!40000 ALTER TABLE `preference` DISABLE KEYS */;
INSERT INTO `preference` VALUES (1,0,1,1,NULL,'GLOBAL_USER',_binary '{}',NULL,NULL,'2026-04-01 20:40:14','2026-04-01 20:40:14','2026-04-01 20:40:14');
/*!40000 ALTER TABLE `preference` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rde_template`
--

DROP TABLE IF EXISTS `rde_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rde_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `record_type` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `order` blob,
  `visible` blob,
  `defaults` blob,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rde_template_system_mtime_index` (`system_mtime`),
  KEY `rde_template_user_mtime_index` (`user_mtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rde_template`
--

LOCK TABLES `rde_template` WRITE;
/*!40000 ALTER TABLE `rde_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `rde_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `related_accession_rlshp`
--

DROP TABLE IF EXISTS `related_accession_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `related_accession_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `accession_id_0` int(11) DEFAULT NULL,
  `accession_id_1` int(11) DEFAULT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `relator_id` int(11) NOT NULL,
  `relator_type_id` int(11) NOT NULL,
  `relationship_target_record_type` varchar(255) NOT NULL,
  `relationship_target_id` int(11) NOT NULL,
  `jsonmodel_type` varchar(255) NOT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `relator_id` (`relator_id`),
  KEY `relator_type_id` (`relator_type_id`),
  KEY `related_accession_rlshp_system_mtime_index` (`system_mtime`),
  KEY `related_accession_rlshp_user_mtime_index` (`user_mtime`),
  KEY `accession_id_0` (`accession_id_0`),
  KEY `accession_id_1` (`accession_id_1`),
  CONSTRAINT `related_accession_rlshp_ibfk_1` FOREIGN KEY (`relator_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `related_accession_rlshp_ibfk_2` FOREIGN KEY (`relator_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `related_accession_rlshp_ibfk_3` FOREIGN KEY (`accession_id_0`) REFERENCES `accession` (`id`),
  CONSTRAINT `related_accession_rlshp_ibfk_4` FOREIGN KEY (`accession_id_1`) REFERENCES `accession` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `related_accession_rlshp`
--

LOCK TABLES `related_accession_rlshp` WRITE;
/*!40000 ALTER TABLE `related_accession_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `related_accession_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `related_agents_rlshp`
--

DROP TABLE IF EXISTS `related_agents_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `related_agents_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_person_id_0` int(11) DEFAULT NULL,
  `agent_person_id_1` int(11) DEFAULT NULL,
  `agent_corporate_entity_id_0` int(11) DEFAULT NULL,
  `agent_corporate_entity_id_1` int(11) DEFAULT NULL,
  `agent_software_id_0` int(11) DEFAULT NULL,
  `agent_software_id_1` int(11) DEFAULT NULL,
  `agent_family_id_0` int(11) DEFAULT NULL,
  `agent_family_id_1` int(11) DEFAULT NULL,
  `relator` varchar(255) NOT NULL,
  `jsonmodel_type` varchar(255) NOT NULL,
  `description` text,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `relationship_target_record_type` varchar(255) NOT NULL,
  `relationship_target_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `related_agents_rlshp_system_mtime_index` (`system_mtime`),
  KEY `related_agents_rlshp_user_mtime_index` (`user_mtime`),
  KEY `agent_person_id_0` (`agent_person_id_0`),
  KEY `agent_person_id_1` (`agent_person_id_1`),
  KEY `agent_corporate_entity_id_0` (`agent_corporate_entity_id_0`),
  KEY `agent_corporate_entity_id_1` (`agent_corporate_entity_id_1`),
  KEY `agent_software_id_0` (`agent_software_id_0`),
  KEY `agent_software_id_1` (`agent_software_id_1`),
  KEY `agent_family_id_0` (`agent_family_id_0`),
  KEY `agent_family_id_1` (`agent_family_id_1`),
  CONSTRAINT `related_agents_rlshp_ibfk_1` FOREIGN KEY (`agent_person_id_0`) REFERENCES `agent_person` (`id`),
  CONSTRAINT `related_agents_rlshp_ibfk_2` FOREIGN KEY (`agent_person_id_1`) REFERENCES `agent_person` (`id`),
  CONSTRAINT `related_agents_rlshp_ibfk_3` FOREIGN KEY (`agent_corporate_entity_id_0`) REFERENCES `agent_corporate_entity` (`id`),
  CONSTRAINT `related_agents_rlshp_ibfk_4` FOREIGN KEY (`agent_corporate_entity_id_1`) REFERENCES `agent_corporate_entity` (`id`),
  CONSTRAINT `related_agents_rlshp_ibfk_5` FOREIGN KEY (`agent_software_id_0`) REFERENCES `agent_software` (`id`),
  CONSTRAINT `related_agents_rlshp_ibfk_6` FOREIGN KEY (`agent_software_id_1`) REFERENCES `agent_software` (`id`),
  CONSTRAINT `related_agents_rlshp_ibfk_7` FOREIGN KEY (`agent_family_id_0`) REFERENCES `agent_family` (`id`),
  CONSTRAINT `related_agents_rlshp_ibfk_8` FOREIGN KEY (`agent_family_id_1`) REFERENCES `agent_family` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `related_agents_rlshp`
--

LOCK TABLES `related_agents_rlshp` WRITE;
/*!40000 ALTER TABLE `related_agents_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `related_agents_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `repository`
--

DROP TABLE IF EXISTS `repository`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `repository` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `repo_code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `org_code` varchar(255) DEFAULT NULL,
  `parent_institution_name` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `contact_persons` text,
  `country_id` int(11) DEFAULT NULL,
  `agent_representation_id` int(11) DEFAULT NULL,
  `hidden` int(11) DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `publish` int(11) DEFAULT NULL,
  `description` text,
  `oai_is_disabled` int(11) DEFAULT '0',
  `oai_sets_available` text,
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `repo_code` (`repo_code`),
  KEY `country_id` (`country_id`),
  KEY `repository_system_mtime_index` (`system_mtime`),
  KEY `repository_user_mtime_index` (`user_mtime`),
  KEY `agent_representation_id` (`agent_representation_id`),
  CONSTRAINT `repository_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `repository_ibfk_2` FOREIGN KEY (`agent_representation_id`) REFERENCES `agent_corporate_entity` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `repository`
--

LOCK TABLES `repository` WRITE;
/*!40000 ALTER TABLE `repository` DISABLE KEYS */;
INSERT INTO `repository` VALUES (1,0,1,'_archivesspace','Global repository',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,'2026-04-01 20:40:12','2026-04-01 20:40:12','2026-04-01 20:40:12',NULL,NULL,0,NULL,'archivesspace',1);
/*!40000 ALTER TABLE `repository` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `required_fields`
--

DROP TABLE IF EXISTS `required_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `required_fields` (
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `id` varchar(255) NOT NULL,
  `blob` blob NOT NULL,
  `repo_id` int(11) NOT NULL,
  `record_type` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `required_fields_system_mtime_index` (`system_mtime`),
  KEY `required_fields_user_mtime_index` (`user_mtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `required_fields`
--

LOCK TABLES `required_fields` WRITE;
/*!40000 ALTER TABLE `required_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `required_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource`
--

DROP TABLE IF EXISTS `resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `repo_id` int(11) NOT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `title` varchar(8704) NOT NULL,
  `identifier` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `level_id` int(11) NOT NULL,
  `other_level` varchar(255) DEFAULT NULL,
  `resource_type_id` int(11) DEFAULT NULL,
  `publish` int(11) DEFAULT NULL,
  `restrictions` int(11) DEFAULT NULL,
  `repository_processing_note` text,
  `ead_id` varchar(255) DEFAULT NULL,
  `ead_location` varchar(255) DEFAULT NULL,
  `finding_aid_title` text,
  `finding_aid_filing_title` text,
  `finding_aid_date` varchar(255) DEFAULT NULL,
  `finding_aid_author` text,
  `finding_aid_description_rules_id` int(11) DEFAULT NULL,
  `finding_aid_language` varchar(255) DEFAULT NULL,
  `finding_aid_sponsor` text,
  `finding_aid_edition_statement` text,
  `finding_aid_series_statement` text,
  `finding_aid_status_id` int(11) DEFAULT NULL,
  `finding_aid_note` text,
  `system_generated` int(11) DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `finding_aid_subtitle` text,
  `finding_aid_sponsor_sha1` varchar(255) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_unique_identifier` (`repo_id`,`identifier`),
  UNIQUE KEY `resource_unique_ead_id` (`repo_id`,`ead_id`),
  KEY `language_id` (`language_id`),
  KEY `level_id` (`level_id`),
  KEY `resource_type_id` (`resource_type_id`),
  KEY `finding_aid_description_rules_id` (`finding_aid_description_rules_id`),
  KEY `finding_aid_status_id` (`finding_aid_status_id`),
  KEY `resource_system_mtime_index` (`system_mtime`),
  KEY `resource_user_mtime_index` (`user_mtime`),
  KEY `accession_id` (`accession_id`),
  CONSTRAINT `resource_ibfk_1` FOREIGN KEY (`language_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `resource_ibfk_2` FOREIGN KEY (`level_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `resource_ibfk_3` FOREIGN KEY (`resource_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `resource_ibfk_4` FOREIGN KEY (`finding_aid_description_rules_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `resource_ibfk_5` FOREIGN KEY (`finding_aid_status_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `resource_ibfk_6` FOREIGN KEY (`repo_id`) REFERENCES `repository` (`id`),
  CONSTRAINT `resource_ibfk_7` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource`
--

LOCK TABLES `resource` WRITE;
/*!40000 ALTER TABLE `resource` DISABLE KEYS */;
/*!40000 ALTER TABLE `resource` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `revision_statement`
--

DROP TABLE IF EXISTS `revision_statement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `revision_statement` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_id` int(11) DEFAULT NULL,
  `date` varchar(255) DEFAULT NULL,
  `description` text,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `publish` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `revision_statement_system_mtime_index` (`system_mtime`),
  KEY `revision_statement_user_mtime_index` (`user_mtime`),
  KEY `resource_id` (`resource_id`),
  CONSTRAINT `revision_statement_ibfk_1` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `revision_statement`
--

LOCK TABLES `revision_statement` WRITE;
/*!40000 ALTER TABLE `revision_statement` DISABLE KEYS */;
/*!40000 ALTER TABLE `revision_statement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rights_restriction`
--

DROP TABLE IF EXISTS `rights_restriction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rights_restriction` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `restriction_note_type` varchar(255) DEFAULT NULL,
  `begin` date DEFAULT NULL,
  `end` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `resource_id` (`resource_id`),
  KEY `archival_object_id` (`archival_object_id`),
  CONSTRAINT `rights_restriction_ibfk_1` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `rights_restriction_ibfk_2` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rights_restriction`
--

LOCK TABLES `rights_restriction` WRITE;
/*!40000 ALTER TABLE `rights_restriction` DISABLE KEYS */;
/*!40000 ALTER TABLE `rights_restriction` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rights_restriction_type`
--

DROP TABLE IF EXISTS `rights_restriction_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rights_restriction_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rights_restriction_id` int(11) NOT NULL,
  `restriction_type_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `restriction_type_id` (`restriction_type_id`),
  KEY `rights_restriction_id` (`rights_restriction_id`),
  CONSTRAINT `rights_restriction_type_ibfk_1` FOREIGN KEY (`restriction_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `rights_restriction_type_ibfk_2` FOREIGN KEY (`rights_restriction_id`) REFERENCES `rights_restriction` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rights_restriction_type`
--

LOCK TABLES `rights_restriction_type` WRITE;
/*!40000 ALTER TABLE `rights_restriction_type` DISABLE KEYS */;
/*!40000 ALTER TABLE `rights_restriction_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rights_statement`
--

DROP TABLE IF EXISTS `rights_statement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rights_statement` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `digital_object_component_id` int(11) DEFAULT NULL,
  `repo_id` int(11) DEFAULT NULL,
  `identifier` varchar(255) NOT NULL,
  `rights_type_id` int(11) NOT NULL,
  `statute_citation` varchar(255) DEFAULT NULL,
  `jurisdiction_id` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `status_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `determination_date` date DEFAULT NULL,
  `license_terms` varchar(255) DEFAULT NULL,
  `other_rights_basis_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `rights_type_id` (`rights_type_id`),
  KEY `jurisdiction_id` (`jurisdiction_id`),
  KEY `rights_statement_system_mtime_index` (`system_mtime`),
  KEY `rights_statement_user_mtime_index` (`user_mtime`),
  KEY `accession_id` (`accession_id`),
  KEY `archival_object_id` (`archival_object_id`),
  KEY `resource_id` (`resource_id`),
  KEY `digital_object_id` (`digital_object_id`),
  KEY `digital_object_component_id` (`digital_object_component_id`),
  KEY `rights_statement_status_id_fk` (`status_id`),
  KEY `rights_statement_other_rights_basis_id_fk` (`other_rights_basis_id`),
  CONSTRAINT `rights_statement_ibfk_1` FOREIGN KEY (`rights_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `rights_statement_ibfk_3` FOREIGN KEY (`jurisdiction_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `rights_statement_ibfk_4` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `rights_statement_ibfk_5` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`),
  CONSTRAINT `rights_statement_ibfk_6` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `rights_statement_ibfk_7` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `rights_statement_ibfk_8` FOREIGN KEY (`digital_object_component_id`) REFERENCES `digital_object_component` (`id`),
  CONSTRAINT `rights_statement_other_rights_basis_id_fk` FOREIGN KEY (`other_rights_basis_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `rights_statement_status_id_fk` FOREIGN KEY (`status_id`) REFERENCES `enumeration_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rights_statement`
--

LOCK TABLES `rights_statement` WRITE;
/*!40000 ALTER TABLE `rights_statement` DISABLE KEYS */;
/*!40000 ALTER TABLE `rights_statement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rights_statement_act`
--

DROP TABLE IF EXISTS `rights_statement_act`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rights_statement_act` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rights_statement_id` int(11) NOT NULL,
  `act_type_id` int(11) NOT NULL,
  `restriction_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `act_type_id` (`act_type_id`),
  KEY `restriction_id` (`restriction_id`),
  KEY `rights_statement_act_system_mtime_index` (`system_mtime`),
  KEY `rights_statement_act_user_mtime_index` (`user_mtime`),
  KEY `rights_statement_id` (`rights_statement_id`),
  CONSTRAINT `rights_statement_act_ibfk_1` FOREIGN KEY (`act_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `rights_statement_act_ibfk_2` FOREIGN KEY (`restriction_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `rights_statement_act_ibfk_3` FOREIGN KEY (`rights_statement_id`) REFERENCES `rights_statement` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rights_statement_act`
--

LOCK TABLES `rights_statement_act` WRITE;
/*!40000 ALTER TABLE `rights_statement_act` DISABLE KEYS */;
/*!40000 ALTER TABLE `rights_statement_act` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rights_statement_pre_088`
--

DROP TABLE IF EXISTS `rights_statement_pre_088`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rights_statement_pre_088` (
  `id` int(11) NOT NULL DEFAULT '0',
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `digital_object_component_id` int(11) DEFAULT NULL,
  `repo_id` int(11) DEFAULT NULL,
  `identifier` varchar(255) CHARACTER SET utf8 NOT NULL,
  `rights_type_id` int(11) NOT NULL,
  `active` int(11) DEFAULT NULL,
  `materials` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `ip_status_id` int(11) DEFAULT NULL,
  `ip_expiration_date` date DEFAULT NULL,
  `license_identifier_terms` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `statute_citation` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `jurisdiction_id` int(11) DEFAULT NULL,
  `type_note` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `permissions` text CHARACTER SET utf8,
  `restrictions` text CHARACTER SET utf8,
  `restriction_start_date` date DEFAULT NULL,
  `restriction_end_date` date DEFAULT NULL,
  `granted_note` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `created_by` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `last_modified_by` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `agent_person_id` int(11) DEFAULT NULL,
  `agent_family_id` int(11) DEFAULT NULL,
  `agent_corporate_entity_id` int(11) DEFAULT NULL,
  `agent_software_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rights_statement_pre_088`
--

LOCK TABLES `rights_statement_pre_088` WRITE;
/*!40000 ALTER TABLE `rights_statement_pre_088` DISABLE KEYS */;
/*!40000 ALTER TABLE `rights_statement_pre_088` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_info`
--

DROP TABLE IF EXISTS `schema_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_info` (
  `version` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_info`
--

LOCK TABLES `schema_info` WRITE;
/*!40000 ALTER TABLE `schema_info` DISABLE KEYS */;
INSERT INTO `schema_info` VALUES (120);
/*!40000 ALTER TABLE `schema_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sequence`
--

DROP TABLE IF EXISTS `sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sequence` (
  `sequence_name` varchar(255) NOT NULL,
  `value` int(11) NOT NULL,
  PRIMARY KEY (`sequence_name`),
  KEY `sequence_namevalue_idx` (`sequence_name`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sequence`
--

LOCK TABLES `sequence` WRITE;
/*!40000 ALTER TABLE `sequence` DISABLE KEYS */;
/*!40000 ALTER TABLE `sequence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `system_mtime` datetime NOT NULL,
  `expirable` int(11) DEFAULT '1',
  `session_data` blob,
  PRIMARY KEY (`id`),
  UNIQUE KEY `session_id` (`session_id`),
  KEY `session_system_mtime_index` (`system_mtime`)
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session`
--

LOCK TABLES `session` WRITE;
/*!40000 ALTER TABLE `session` DISABLE KEYS */;
INSERT INTO `session` VALUES (1,'1f31b4a54a5b5cbe76f2b5a70f24288f16424d14','2026-04-01 20:46:54',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A+bIxoQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(2,'3b6867e1f800e8acf539685803d625a512582c63','2026-04-01 20:40:24',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+ALhqBoQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(3,'280e850060496ffe6fa59ae9c67ba12347112e17','2026-04-01 20:47:09',0,_binary 'BAh7CDoJdXNlckkiEXN0YWZmX3N5c3RlbQY6BkVUOg9sb2dpbl90aW1lSXU6\nCVRpbWUNNIwfgFSbfaIIOg1zdWJtaWNybyIGADoLb2Zmc2V0aQA6CXpvbmVJ\nIghVVEMGOwZUOg5leHBpcmFibGVG\n'),(4,'e9a9e84a6ceee598d4fcaf321ed1f7782cf3b8ae','2026-04-01 20:40:49',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AvSrRogg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(5,'cd7ad1f2d3f8f3782795eeabca6af0255ce3a3c7','2026-04-01 20:46:49',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Av7wQowg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(6,'4b09a79c7f177e7984b93987b44551a30c453abb','2026-04-01 20:40:54',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AUQAkowg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(7,'0361a4c64ff87b65fcc27b53dd9099c868c29e2b','2026-04-01 20:40:59',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AzG92owg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(8,'580948801a017811aebf422b7fe8dc688e42da9a','2026-04-01 20:41:04',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A1s0IpAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(9,'c2d0acc91da3b4a1c1efc856429eebbc5db3b3e1','2026-04-01 20:41:09',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AzAZbpAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(10,'543bd5307b07410d2ac0aaaf0b3ab070e9f8bc18','2026-04-01 20:41:14',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+ACkmtpAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(11,'7823b843353071fe856e5e9ca790717927bb6f67','2026-04-01 20:41:19',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Ap0MApQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(12,'3a52cd0a4549c12c5c0384af1aaf3fe13e297a0c','2026-04-01 20:41:24',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AVZtSpQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(13,'52552a300262ef4840245d9a7a24e00352589f42','2026-04-01 20:41:29',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AhbekpQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(14,'7f93f7ccc56a872adf6f5112e7020fe210329def','2026-04-01 20:41:34',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AwvL2pQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(15,'3ac8f506099c294ab878f951cfbbbb2b5a427102','2026-04-01 20:41:39',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Ax2RJpgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(16,'a15164acb995033ba9128d0f8e01fd0d9b2a343e','2026-04-01 20:41:44',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Auvqbpgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(17,'aa611e493c88e8eb0262d83092443e68ac3dee79','2026-04-01 20:41:49',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AsmDupgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(18,'2e8fa061cdf658922146d08dec2505d1f0a85176','2026-04-01 20:41:54',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+ADldBpwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(19,'35a144dc5b837c6b2c2dfb4c87e9a47674a976e4','2026-04-01 20:41:59',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A03aTpwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(20,'e0942b47744fa792ef13b73e30538db7462606f7','2026-04-01 20:42:04',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AQ3ElqAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(21,'19dc99082d3e61244348bbb000d82f4b03e35780','2026-04-01 20:42:09',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+ADdh3qAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(22,'2bf07c889448796163b01a08e0f4beddaf2535d3','2026-04-01 20:42:14',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AuGTKqAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(23,'cb7401cbf3b8453609cf0c22ee862085af8a6a87','2026-04-01 20:42:19',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A40kcqQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(24,'aa65fb25e1ce64d8c282590f6ee922212941815e','2026-04-01 20:42:24',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AKyduqQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(25,'e7294b3a57b14e36db320384c42f8f8c4d7466a2','2026-04-01 20:42:29',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AR+TAqQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(26,'ec41a1a0f913309f0051bf36fa856bc3c337beb1','2026-04-01 20:42:34',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AOwkTqgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(27,'7d438e52dfaab3e45d37b4662ff2432adf43d914','2026-04-01 20:42:39',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AEBdlqgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(28,'f59b06374f79d32825b6ce42efcd9048565606e6','2026-04-01 20:42:44',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AL0S3qgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(29,'87f19e13e7756b0746a1a74bb17fe69d6fcf9ecb','2026-04-01 20:42:49',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AwEYJqwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(30,'6d1143ca3aff42e8a6c93c45fb8c1defedd3aebd','2026-04-01 20:42:54',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AcDpbqwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(31,'b9bdd48e313f515022002a46642fe0ddd66c29e7','2026-04-01 20:42:59',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Ahz6tqwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(32,'41873a54fd156d9ef0608fc5d72bcd6bb0a74e38','2026-04-01 20:43:04',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+ACQFArAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(33,'136dff71f3824eeae20946daf768737c48c16322','2026-04-01 20:43:09',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AUO2RrAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(34,'61555ad138b43f9e6e36adaccfcb5ea5e9020528','2026-04-01 20:43:14',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AKADkrAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(35,'309cfc2faccd0455d74b86f2074ad1c8711e680b','2026-04-01 20:43:19',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+ABQo2rQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(36,'99726cdefcf3a5a77e1d66b2d78a7034597d9749','2026-04-01 20:43:24',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AGeuHrQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(37,'2c4121071b6ed41529f1df24c3705a645afc48d2','2026-04-01 20:43:29',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+ARhjarQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(38,'9d05f6cdce7d6c713bac9f2d45877a32b8ca1229','2026-04-01 20:43:39',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AffUrrgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(39,'04b18cedaa666fa2560906dac70b07f2b5fe0c5b','2026-04-01 20:43:44',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AkNN9rgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(40,'c95de127dfb55f1e32679848413b7323b8c3913b','2026-04-01 20:43:49',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AaXfQrgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(41,'abbc0fa516d6904eeb5436133602b4de999e3a03','2026-04-01 20:43:54',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AOWwirwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(42,'a162a6680ced6d7353356f13d4638d101c85fd31','2026-04-01 20:43:59',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+ALVx0rwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(43,'cbbb95c849e9d236b494aca16ad982abbd173196','2026-04-01 20:44:04',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AZDIGsAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(44,'a9fc072b2b60751ebc73b9666ba4920434aff560','2026-04-01 20:44:09',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AdBdYsAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(45,'36b5742f554cda81c343fef3b7b6e84ed5e5e78c','2026-04-01 20:44:14',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AABuqsAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(46,'5a15ce0d63c714201b523ed53072771d4b2bcfb0','2026-04-01 20:44:19',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A+GP8sAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(47,'50c9de89b9a892e9229d33e11bb820237ea1670a','2026-04-01 20:44:24',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A8TxOsQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(48,'556e34fcc2d6e0b9200c31cbd3da19975cbc2df9','2026-04-01 20:44:29',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+ARQOhsQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(49,'009f48484ad7dc43b4277a587c8ab641df05fc9e','2026-04-01 20:44:34',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AVtzysQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(50,'41ca04f921a37d7b4828b618c1ffeb38e1cbc0b6','2026-04-01 20:44:39',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AUr9Esgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(51,'639381eedd55a547ad40f7ac678715ce87d70de8','2026-04-01 20:44:44',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+APtKWsgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(52,'d132d8e5e0eb82c54adf030b86b15c8b7bffed73','2026-04-01 20:44:49',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AmW7psgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(53,'aa76c2637863448c97c0555231d27a510d345487','2026-04-01 20:44:54',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A96g7swg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(54,'702c5b901d9f2561b11c6d583d541147da6a8c91','2026-04-01 20:44:59',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A15+Nswg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(55,'34fadc9c7a87e72059ab372f167b3c5e49fe09aa','2026-04-01 20:45:04',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AC0ogtAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(56,'2c79b060311a460d6498dd7d4454c5bdf4bc83d0','2026-04-01 20:45:09',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A3F5ytAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(57,'b4ae8215a1ebc8a99e4d296a88bcc92f349979cd','2026-04-01 20:45:14',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A4yzEtAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(58,'38b97658a4a216447dad321a4fc5ab498acefeeb','2026-04-01 20:45:19',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AoPEVtQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(59,'d3b49e46db497fa1a4e9dfee7b1939352ba0a52d','2026-04-01 20:45:24',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AHK1ntQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(60,'4c9e51d96661c04a0a397a75271d0f7854649e23','2026-04-01 20:45:29',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Af3K5tQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(61,'883d50421556bc1de3fe56c0deee930e5e7d09a0','2026-04-01 20:45:34',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A6G8Ltgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(62,'9004474256ba05e1de509f0f02b3abd09e1430cb','2026-04-01 20:45:39',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AdjVdtgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(63,'18fa1e33b5b5557a9681dbc3bd4646d7214ea4cd','2026-04-01 20:45:44',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AaAKvtgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(64,'f78628bade1af81f3e621a6c40f0c20037ba7a1f','2026-04-01 20:45:49',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+ARX4Btwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(65,'d96c1aa364ff0ee0089ee6e6708c8ed680c9a8b9','2026-04-01 20:45:54',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AMD5Ttwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(66,'f71d7cde81e314ac7489a895a4f24f161f3454ae','2026-04-01 20:45:59',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Avwiltwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(67,'d95ec75d64df8ade0c51e79e948dcf11e1107eee','2026-04-01 20:46:04',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AL9g2uAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(68,'7cd33a3a5c1a20b4d8d2a830aed88fabbd247a2e','2026-04-01 20:46:09',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AgY2IuAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(69,'ee581f40be57769a4e20b1c07a2085246836f30b','2026-04-01 20:46:14',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+ABVzauAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(70,'fd606ac6e917f9ba049799dd977dbc52eed28c20','2026-04-01 20:46:19',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AnDYsuQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(71,'6167d83d984025635ffdb30561568f78deb9dbe0','2026-04-01 20:46:24',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AIvx9uQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(72,'a9173800728ebe1c83d3517bad29c20efb1d4efe','2026-04-01 20:46:29',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+An7HQuQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(73,'7c59f795aa88133695b298abc7c26e93491ed9c2','2026-04-01 20:46:34',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A3Isiugg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(74,'bdcb5888bd5917947342e7bd4b27321866582895','2026-04-01 20:46:39',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AYk90ugg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(75,'1aae0d66396da8946d4b27d192165cc68d3e302f','2026-04-01 20:46:44',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AKBbGugg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(76,'b63d1d4b29f03af72a4f8df602f6c9fe777346d1','2026-04-01 20:46:49',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+APuwXuwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(77,'5ac962f07198345956b47b56e6a95e2c3df13e56','2026-04-01 20:46:54',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A86Vpuwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(78,'440c04126e2eb92b02c53a11605b90bc711d9b56','2026-04-01 20:46:59',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Adna7uwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(79,'f9e495bc881843992adfcb484f8851381cae1627','2026-04-01 20:47:04',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AVTRNvAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(80,'8a32444fa15938c4b33a644f37ab551d3f0a0019','2026-04-01 20:47:09',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AkOeevAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(81,'cb6704084f9b354feabc1e8b3703681cc1a0e613','2026-04-01 20:49:34',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Auw8mwgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(82,'ad1939692cc6e969b1773c478e4d18bab724e0f3','2026-04-01 20:48:39',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AanJ1wgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(83,'7bad980d6d06871e278d8f63e70ffef92ec9f95a','2026-04-01 20:49:34',0,_binary 'BAh7CDoJdXNlckkiEXN0YWZmX3N5c3RlbQY6BkVUOg9sb2dpbl90aW1lSXU6\nCVRpbWUNNIwfgN4ta8MIOg1zdWJtaWNybyIGADoLb2Zmc2V0aQA6CXpvbmVJ\nIghVVEMGOwZUOg5leHBpcmFibGVG\n'),(84,'77e5e6bfd48414c86317031bd30eeff4c8fe5396','2026-04-01 20:49:04',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Az2q+wwg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(85,'0999f8ccbae17b0b6a061c804025f14b864fdce4','2026-04-01 20:49:34',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AFUJFxAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(86,'c70fcb7620a9c5f4915743988497e11a8efb6b79','2026-04-01 20:49:09',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A7MdRxAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(87,'00466049a3a905da6968e314026d84b476afe436','2026-04-01 20:49:14',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AvlWkxAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(88,'0869e53aa9557864c522d58873289e58b2d5fd71','2026-04-01 20:49:19',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Aftj2xAg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(89,'94ebc8d5449f0603dc8b288cd655e378adc8ea8e','2026-04-01 20:49:24',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AmUtJxQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(90,'02ec3d13d7a7c6eb128662ebf56ae63864fe1957','2026-04-01 20:49:29',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+Aw7KbxQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(91,'21b4194d1ddfec5991b260103a04d91ef7598a29','2026-04-01 20:49:34',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+A4O7txQg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n'),(92,'2427d26958ce5a7447504b4cacdf165ba0a5df29','2026-04-01 20:49:36',0,_binary 'BAh7CDoJdXNlckkiE3NlYXJjaF9pbmRleGVyBjoGRVQ6D2xvZ2luX3RpbWVJ\ndToJVGltZQ00jB+AqfpAxgg6DXN1Ym1pY3JvIgYAOgtvZmZzZXRpADoJem9u\nZUkiCFVUQwY7BlQ6DmV4cGlyYWJsZUY=\n');
/*!40000 ALTER TABLE `session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `spawned_rlshp`
--

DROP TABLE IF EXISTS `spawned_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spawned_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `accession_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `spawned_rlshp_system_mtime_index` (`system_mtime`),
  KEY `spawned_rlshp_user_mtime_index` (`user_mtime`),
  KEY `accession_id` (`accession_id`),
  KEY `resource_id` (`resource_id`),
  CONSTRAINT `spawned_rlshp_ibfk_1` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `spawned_rlshp_ibfk_2` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `spawned_rlshp`
--

LOCK TABLES `spawned_rlshp` WRITE;
/*!40000 ALTER TABLE `spawned_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `spawned_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sub_container`
--

DROP TABLE IF EXISTS `sub_container`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sub_container` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `instance_id` int(11) DEFAULT NULL,
  `type_2_id` int(11) DEFAULT NULL,
  `indicator_2` varchar(255) DEFAULT NULL,
  `type_3_id` int(11) DEFAULT NULL,
  `indicator_3` varchar(255) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `type_2_id` (`type_2_id`),
  KEY `type_3_id` (`type_3_id`),
  KEY `sub_container_system_mtime_index` (`system_mtime`),
  KEY `sub_container_user_mtime_index` (`user_mtime`),
  KEY `instance_id` (`instance_id`),
  CONSTRAINT `sub_container_ibfk_1` FOREIGN KEY (`type_2_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `sub_container_ibfk_2` FOREIGN KEY (`type_3_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `sub_container_ibfk_3` FOREIGN KEY (`instance_id`) REFERENCES `instance` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sub_container`
--

LOCK TABLES `sub_container` WRITE;
/*!40000 ALTER TABLE `sub_container` DISABLE KEYS */;
/*!40000 ALTER TABLE `sub_container` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subject`
--

DROP TABLE IF EXISTS `subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subject` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `vocab_id` int(11) NOT NULL,
  `title` varchar(8704) DEFAULT NULL,
  `terms_sha1` varchar(255) NOT NULL,
  `authority_id` varchar(255) DEFAULT NULL,
  `scope_note` text,
  `source_id` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `is_slug_auto` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `subj_auth_source_uniq` (`vocab_id`,`authority_id`,`source_id`),
  UNIQUE KEY `subj_terms_uniq` (`vocab_id`,`terms_sha1`,`source_id`),
  KEY `source_id` (`source_id`),
  KEY `subject_terms_sha1_index` (`terms_sha1`),
  KEY `subject_system_mtime_index` (`system_mtime`),
  KEY `subject_user_mtime_index` (`user_mtime`),
  CONSTRAINT `subject_ibfk_1` FOREIGN KEY (`source_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `subject_ibfk_2` FOREIGN KEY (`vocab_id`) REFERENCES `vocabulary` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subject`
--

LOCK TABLES `subject` WRITE;
/*!40000 ALTER TABLE `subject` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subject_rlshp`
--

DROP TABLE IF EXISTS `subject_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subject_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `accession_id` int(11) DEFAULT NULL,
  `archival_object_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `digital_object_component_id` int(11) DEFAULT NULL,
  `subject_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `subject_rlshp_system_mtime_index` (`system_mtime`),
  KEY `subject_rlshp_user_mtime_index` (`user_mtime`),
  KEY `accession_id` (`accession_id`),
  KEY `archival_object_id` (`archival_object_id`),
  KEY `resource_id` (`resource_id`),
  KEY `digital_object_id` (`digital_object_id`),
  KEY `digital_object_component_id` (`digital_object_component_id`),
  KEY `subject_id` (`subject_id`),
  CONSTRAINT `subject_rlshp_ibfk_1` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `subject_rlshp_ibfk_2` FOREIGN KEY (`archival_object_id`) REFERENCES `archival_object` (`id`),
  CONSTRAINT `subject_rlshp_ibfk_3` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `subject_rlshp_ibfk_4` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `subject_rlshp_ibfk_5` FOREIGN KEY (`digital_object_component_id`) REFERENCES `digital_object_component` (`id`),
  CONSTRAINT `subject_rlshp_ibfk_6` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subject_rlshp`
--

LOCK TABLES `subject_rlshp` WRITE;
/*!40000 ALTER TABLE `subject_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subject_term`
--

DROP TABLE IF EXISTS `subject_term`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subject_term` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject_id` int(11) NOT NULL,
  `term_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `term_id` (`term_id`),
  KEY `subject_term_idx` (`subject_id`,`term_id`),
  CONSTRAINT `subject_term_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`),
  CONSTRAINT `subject_term_ibfk_2` FOREIGN KEY (`term_id`) REFERENCES `term` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subject_term`
--

LOCK TABLES `subject_term` WRITE;
/*!40000 ALTER TABLE `subject_term` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject_term` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subnote_metadata`
--

DROP TABLE IF EXISTS `subnote_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subnote_metadata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) NOT NULL,
  `guid` varchar(255) NOT NULL,
  `publish` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `note_id` (`note_id`),
  CONSTRAINT `subnote_metadata_ibfk_1` FOREIGN KEY (`note_id`) REFERENCES `note` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subnote_metadata`
--

LOCK TABLES `subnote_metadata` WRITE;
/*!40000 ALTER TABLE `subnote_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `subnote_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `surveyed_by_rlshp`
--

DROP TABLE IF EXISTS `surveyed_by_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `surveyed_by_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assessment_id` int(11) NOT NULL,
  `agent_person_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `surveyed_by_rlshp_system_mtime_index` (`system_mtime`),
  KEY `surveyed_by_rlshp_user_mtime_index` (`user_mtime`),
  KEY `assessment_id` (`assessment_id`),
  KEY `agent_person_id` (`agent_person_id`),
  CONSTRAINT `surveyed_by_rlshp_ibfk_1` FOREIGN KEY (`assessment_id`) REFERENCES `assessment` (`id`),
  CONSTRAINT `surveyed_by_rlshp_ibfk_2` FOREIGN KEY (`agent_person_id`) REFERENCES `agent_person` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `surveyed_by_rlshp`
--

LOCK TABLES `surveyed_by_rlshp` WRITE;
/*!40000 ALTER TABLE `surveyed_by_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `surveyed_by_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_event`
--

DROP TABLE IF EXISTS `system_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `time` datetime NOT NULL,
  `message` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `system_event_time_index` (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_event`
--

LOCK TABLES `system_event` WRITE;
/*!40000 ALTER TABLE `system_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `telephone`
--

DROP TABLE IF EXISTS `telephone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `telephone` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_contact_id` int(11) DEFAULT NULL,
  `number` text NOT NULL,
  `ext` text,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `number_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `telephone_system_mtime_index` (`system_mtime`),
  KEY `telephone_user_mtime_index` (`user_mtime`),
  KEY `agent_contact_id` (`agent_contact_id`),
  KEY `number_type_id` (`number_type_id`),
  CONSTRAINT `telephone_ibfk_1` FOREIGN KEY (`agent_contact_id`) REFERENCES `agent_contact` (`id`),
  CONSTRAINT `telephone_ibfk_2` FOREIGN KEY (`number_type_id`) REFERENCES `enumeration_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `telephone`
--

LOCK TABLES `telephone` WRITE;
/*!40000 ALTER TABLE `telephone` DISABLE KEYS */;
/*!40000 ALTER TABLE `telephone` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `term`
--

DROP TABLE IF EXISTS `term`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `term` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `vocab_id` int(11) NOT NULL,
  `term` varchar(255) NOT NULL,
  `term_type_id` int(11) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `term_vocab_id_term_term_type_id_index` (`vocab_id`,`term`,`term_type_id`),
  KEY `term_type_id` (`term_type_id`),
  KEY `term_system_mtime_index` (`system_mtime`),
  KEY `term_user_mtime_index` (`user_mtime`),
  CONSTRAINT `term_ibfk_1` FOREIGN KEY (`term_type_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `term_ibfk_2` FOREIGN KEY (`vocab_id`) REFERENCES `vocabulary` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `term`
--

LOCK TABLES `term` WRITE;
/*!40000 ALTER TABLE `term` DISABLE KEYS */;
/*!40000 ALTER TABLE `term` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_container`
--

DROP TABLE IF EXISTS `top_container`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_container` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `repo_id` int(11) NOT NULL,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `barcode` varchar(255) DEFAULT NULL,
  `ils_holding_id` varchar(255) DEFAULT NULL,
  `ils_item_id` varchar(255) DEFAULT NULL,
  `exported_to_ils` datetime DEFAULT NULL,
  `indicator` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `type_id` int(11) DEFAULT NULL,
  `created_for_collection` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `top_container_uniq_barcode` (`repo_id`,`barcode`),
  KEY `top_container_indicator_index` (`indicator`),
  KEY `top_container_system_mtime_index` (`system_mtime`),
  KEY `top_container_user_mtime_index` (`user_mtime`),
  KEY `top_container_type_fk` (`type_id`),
  CONSTRAINT `top_container_type_fk` FOREIGN KEY (`type_id`) REFERENCES `enumeration_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_container`
--

LOCK TABLES `top_container` WRITE;
/*!40000 ALTER TABLE `top_container` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_container` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_container_housed_at_rlshp`
--

DROP TABLE IF EXISTS `top_container_housed_at_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_container_housed_at_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `top_container_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `jsonmodel_type` varchar(255) NOT NULL DEFAULT 'container_location',
  `status` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `top_container_housed_at_rlshp_system_mtime_index` (`system_mtime`),
  KEY `top_container_housed_at_rlshp_user_mtime_index` (`user_mtime`),
  KEY `top_container_id` (`top_container_id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `top_container_housed_at_rlshp_ibfk_1` FOREIGN KEY (`top_container_id`) REFERENCES `top_container` (`id`),
  CONSTRAINT `top_container_housed_at_rlshp_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_container_housed_at_rlshp`
--

LOCK TABLES `top_container_housed_at_rlshp` WRITE;
/*!40000 ALTER TABLE `top_container_housed_at_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_container_housed_at_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_container_link_rlshp`
--

DROP TABLE IF EXISTS `top_container_link_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_container_link_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `top_container_id` int(11) DEFAULT NULL,
  `sub_container_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `top_container_link_rlshp_system_mtime_index` (`system_mtime`),
  KEY `top_container_link_rlshp_user_mtime_index` (`user_mtime`),
  KEY `top_container_id` (`top_container_id`),
  KEY `sub_container_id` (`sub_container_id`),
  CONSTRAINT `top_container_link_rlshp_ibfk_1` FOREIGN KEY (`top_container_id`) REFERENCES `top_container` (`id`),
  CONSTRAINT `top_container_link_rlshp_ibfk_2` FOREIGN KEY (`sub_container_id`) REFERENCES `sub_container` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_container_link_rlshp`
--

LOCK TABLES `top_container_link_rlshp` WRITE;
/*!40000 ALTER TABLE `top_container_link_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_container_link_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_container_profile_rlshp`
--

DROP TABLE IF EXISTS `top_container_profile_rlshp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_container_profile_rlshp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `top_container_id` int(11) DEFAULT NULL,
  `container_profile_id` int(11) DEFAULT NULL,
  `aspace_relationship_position` int(11) DEFAULT NULL,
  `suppressed` int(11) NOT NULL DEFAULT '0',
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `top_container_profile_rlshp_system_mtime_index` (`system_mtime`),
  KEY `top_container_profile_rlshp_user_mtime_index` (`user_mtime`),
  KEY `top_container_id` (`top_container_id`),
  KEY `container_profile_id` (`container_profile_id`),
  CONSTRAINT `top_container_profile_rlshp_ibfk_1` FOREIGN KEY (`top_container_id`) REFERENCES `top_container` (`id`),
  CONSTRAINT `top_container_profile_rlshp_ibfk_2` FOREIGN KEY (`container_profile_id`) REFERENCES `container_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_container_profile_rlshp`
--

LOCK TABLES `top_container_profile_rlshp` WRITE;
/*!40000 ALTER TABLE `top_container_profile_rlshp` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_container_profile_rlshp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `source` varchar(255) DEFAULT NULL,
  `agent_record_id` int(11) DEFAULT NULL,
  `agent_record_type` varchar(255) DEFAULT NULL,
  `is_system_user` int(11) NOT NULL DEFAULT '0',
  `is_hidden_user` int(11) NOT NULL DEFAULT '0',
  `email` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `telephone` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  `additional_contact` text,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `user_system_mtime_index` (`system_mtime`),
  KEY `user_user_mtime_index` (`user_mtime`),
  KEY `agent_record_id` (`agent_record_id`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`agent_record_id`) REFERENCES `agent_person` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,0,1,'admin','Administrator','local',1,'agent_person',1,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-04-01 20:40:12','2026-04-01 20:40:12','2026-04-01 20:40:12'),(2,90,1,'search_indexer','Search Indexer','DBAuth',NULL,NULL,1,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:49:36','2026-04-01 20:49:36'),(3,0,1,'public_anonymous','Public Interface Anonymous','local',NULL,NULL,1,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-04-01 20:40:13','2026-04-01 20:40:13','2026-04-01 20:40:13'),(4,2,1,'staff_system','Staff System User','DBAuth',NULL,NULL,1,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-04-01 20:40:14','2026-04-01 20:48:54','2026-04-01 20:48:54');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_defined`
--

DROP TABLE IF EXISTS `user_defined`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_defined` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `json_schema_version` int(11) NOT NULL,
  `accession_id` int(11) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `digital_object_id` int(11) DEFAULT NULL,
  `boolean_1` int(11) DEFAULT NULL,
  `boolean_2` int(11) DEFAULT NULL,
  `boolean_3` int(11) DEFAULT NULL,
  `integer_1` varchar(255) DEFAULT NULL,
  `integer_2` varchar(255) DEFAULT NULL,
  `integer_3` varchar(255) DEFAULT NULL,
  `real_1` varchar(255) DEFAULT NULL,
  `real_2` varchar(255) DEFAULT NULL,
  `real_3` varchar(255) DEFAULT NULL,
  `string_1` varchar(255) DEFAULT NULL,
  `string_2` varchar(255) DEFAULT NULL,
  `string_3` varchar(255) DEFAULT NULL,
  `string_4` varchar(255) DEFAULT NULL,
  `text_1` text,
  `text_2` text,
  `text_3` text,
  `text_4` text,
  `text_5` text,
  `date_1` date DEFAULT NULL,
  `date_2` date DEFAULT NULL,
  `date_3` date DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  `enum_1_id` int(11) DEFAULT NULL,
  `enum_2_id` int(11) DEFAULT NULL,
  `enum_3_id` int(11) DEFAULT NULL,
  `enum_4_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_defined_system_mtime_index` (`system_mtime`),
  KEY `user_defined_user_mtime_index` (`user_mtime`),
  KEY `accession_id` (`accession_id`),
  KEY `resource_id` (`resource_id`),
  KEY `digital_object_id` (`digital_object_id`),
  KEY `enum_1_id` (`enum_1_id`),
  KEY `enum_2_id` (`enum_2_id`),
  KEY `enum_3_id` (`enum_3_id`),
  KEY `enum_4_id` (`enum_4_id`),
  CONSTRAINT `user_defined_ibfk_1` FOREIGN KEY (`accession_id`) REFERENCES `accession` (`id`),
  CONSTRAINT `user_defined_ibfk_2` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`),
  CONSTRAINT `user_defined_ibfk_3` FOREIGN KEY (`digital_object_id`) REFERENCES `digital_object` (`id`),
  CONSTRAINT `user_defined_ibfk_4` FOREIGN KEY (`enum_1_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `user_defined_ibfk_5` FOREIGN KEY (`enum_2_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `user_defined_ibfk_6` FOREIGN KEY (`enum_3_id`) REFERENCES `enumeration_value` (`id`),
  CONSTRAINT `user_defined_ibfk_7` FOREIGN KEY (`enum_4_id`) REFERENCES `enumeration_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_defined`
--

LOCK TABLES `user_defined` WRITE;
/*!40000 ALTER TABLE `user_defined` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_defined` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vocabulary`
--

DROP TABLE IF EXISTS `vocabulary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vocabulary` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `ref_id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `last_modified_by` varchar(255) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `system_mtime` datetime NOT NULL,
  `user_mtime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `ref_id` (`ref_id`),
  KEY `vocabulary_system_mtime_index` (`system_mtime`),
  KEY `vocabulary_user_mtime_index` (`user_mtime`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vocabulary`
--

LOCK TABLES `vocabulary` WRITE;
/*!40000 ALTER TABLE `vocabulary` DISABLE KEYS */;
INSERT INTO `vocabulary` VALUES (1,0,'global','global',NULL,NULL,'2026-04-01 20:39:50','2026-04-01 20:40:01','2026-04-01 20:39:50');
/*!40000 ALTER TABLE `vocabulary` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-01 20:49:39
