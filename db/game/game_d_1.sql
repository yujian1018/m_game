/*
SQLyog Ultimate v12.4.1 (64 bit)
MySQL - 5.7.18-log : Database - game_d_1
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`game_d_1` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

USE `game_d_1`;

/*Table structure for table `active` */

CREATE TABLE `active` (
  `uid` int(11) NOT NULL,
  `active_id` int(11) NOT NULL,
  `progress` int(11) DEFAULT '0' COMMENT '进度',
  `prize` varchar(1024) CHARACTER SET utf8 DEFAULT '' COMMENT '活动奖励 已领',
  PRIMARY KEY (`uid`,`active_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `attr` */

CREATE TABLE `attr` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '平台昵称',
  `sex` int(11) DEFAULT '0' COMMENT '1男0女',
  `icon` varchar(1024) CHARACTER SET utf8 DEFAULT '' COMMENT '头像',
  `gold` bigint(20) DEFAULT '0' COMMENT '金币',
  `diamond` int(11) DEFAULT '0' COMMENT '钻石',
  `lv` int(11) DEFAULT '1' COMMENT '等级',
  `exp` int(11) DEFAULT '0' COMMENT '经验值',
  `address` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '地址',
  `c_times` int(11) DEFAULT '0' COMMENT '角色创建时间',
  `channel_id` int(11) DEFAULT '0',
  `refresh_times` int(11) DEFAULT '0' COMMENT '刷新时间',
  `offline_times` int(11) DEFAULT '0' COMMENT '最后一次下线时间',
  `gmt_offset` int(11) DEFAULT '28800' COMMENT '时区偏移量,默认东八区',
  `client_setting` varchar(1024) CHARACTER SET utf8 DEFAULT '' COMMENT '客户端设置信息',
  `active_point` int(11) DEFAULT '0' COMMENT '活跃点数',
  `active_rewards` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '活跃点领奖',
  `vip_lv` int(11) DEFAULT '0' COMMENT 'vip等级',
  `vip_exp` int(11) DEFAULT '0' COMMENT 'vip经验值',
  PRIMARY KEY (`uid`),
  KEY `offline_times` (`offline_times`),
  KEY `c_times` (`c_times`,`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `item` */

CREATE TABLE `item` (
  `uid` int(11) NOT NULL DEFAULT '0',
  `item_id` int(11) NOT NULL DEFAULT '0',
  `num` int(11) DEFAULT '0',
  `c_times` int(11) DEFAULT '0' COMMENT '道具创建时间戳',
  PRIMARY KEY (`uid`,`item_id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `log_online` */

CREATE TABLE `log_online` (
  `times` int(11) NOT NULL COMMENT '当前时间戳',
  `uid` int(11) NOT NULL COMMENT '玩家ID',
  `time` int(11) DEFAULT '0' COMMENT '在线时间',
  PRIMARY KEY (`times`,`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `mail` */

CREATE TABLE `mail` (
  `uid` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `from_uid` int(11) DEFAULT NULL,
  `c_times` int(11) DEFAULT NULL,
  `mail_id` int(11) DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8 DEFAULT '',
  `content` varchar(1024) CHARACTER SET utf8 DEFAULT '',
  `attachment` varchar(1024) CHARACTER SET utf8 DEFAULT '',
  `status` int(11) DEFAULT '0' COMMENT '1:阅读 2:领取',
  PRIMARY KEY (`uid`,`auto_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `mail_link` */

CREATE TABLE `mail_link` (
  `uid` int(11) NOT NULL,
  `mail_id` int(11) NOT NULL,
  PRIMARY KEY (`uid`,`mail_id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `roles` */

CREATE TABLE `roles` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `uin` int(11) DEFAULT NULL,
  PRIMARY KEY (`uid`),
  KEY `uin` (`uin`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `task` */

CREATE TABLE `task` (
  `uid` int(11) NOT NULL,
  `chain_id` int(11) NOT NULL COMMENT '任务链id',
  `index` int(11) DEFAULT '1' COMMENT '任务索引',
  `progress` int(11) DEFAULT NULL COMMENT '完成进度',
  `complete` int(11) DEFAULT '0' COMMENT '是否任务链完成',
  `prize` varchar(1024) CHARACTER SET utf8 DEFAULT NULL,
  PRIMARY KEY (`uid`,`chain_id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='新手引导\r\n';

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
