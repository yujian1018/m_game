/*
SQLyog Ultimate v12.4.1 (64 bit)
MySQL - 5.7.18-log : Database - im
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`im` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `im`;

/*Table structure for table `account` */

CREATE TABLE `account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `apps_id` int(11) DEFAULT NULL,
  `i_id` varchar(32) DEFAULT NULL,
  `c_times` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_id` (`apps_id`,`i_id`)
) ENGINE=MyISAM AUTO_INCREMENT=155 DEFAULT CHARSET=utf8;

/*Table structure for table `apps` */

CREATE TABLE `apps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_id` varchar(32) DEFAULT NULL,
  `app_secret` varchar(32) DEFAULT NULL,
  `c_times` int(11) DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `des` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_id` (`app_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
