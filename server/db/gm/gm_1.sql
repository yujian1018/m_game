/*
SQLyog Ultimate v12.4.1 (64 bit)
MySQL - 5.7.18-log : Database - dz_gm
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`dz_gm` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `dz_gm`;

/*Table structure for table `gm_account` */

CREATE TABLE `gm_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` varchar(24) DEFAULT NULL,
  `pwd` varchar(32) DEFAULT NULL,
  `pms_role_id` int(11) DEFAULT '2',
  `c_times` int(11) DEFAULT '0',
  `token` varchar(32) DEFAULT '',
  `token_c_times` int(11) DEFAULT '0',
  `packet_id` int(11) DEFAULT '-1',
  `channel_id` int(11) DEFAULT '-1',
  `name` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_id` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

/*Table structure for table `pms_all` */

CREATE TABLE `pms_all` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `top_id` int(11) DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `url` varchar(1024) DEFAULT '',
  `tab` varchar(255) DEFAULT '' COMMENT '该权限关联的表',
  `pms_op` varchar(255) DEFAULT '' COMMENT '9:状态修改 10：过滤数据',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10089 DEFAULT CHARSET=utf8;

/*Table structure for table `pms_role` */

CREATE TABLE `pms_role` (
  `role_id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

/*Table structure for table `pms_role_permission` */

CREATE TABLE `pms_role_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) DEFAULT NULL,
  `pms_id` int(11) DEFAULT NULL,
  `pms_op` varchar(255) DEFAULT '' COMMENT '1,2,3,4,5',
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1930 DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
