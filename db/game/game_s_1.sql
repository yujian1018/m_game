/*
SQLyog Ultimate v12.4.1 (64 bit)
MySQL - 5.7.18-log : Database - game_s_1
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`game_s_1` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

USE `game_s_1`;

/*Table structure for table `config_tabs` */

CREATE TABLE `config_tabs` (
  `tab_name` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `obj_server` varchar(255) CHARACTER SET utf8 DEFAULT '',
  `fight_server` varchar(255) CHARACTER SET utf8 DEFAULT '',
  PRIMARY KEY (`tab_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `err_code_cn` */

CREATE TABLE `err_code_cn` (
  `err_id` int(11) NOT NULL,
  `alert` int(1) DEFAULT '0' COMMENT '0:不提示 1:弹框 2:漂浮文字',
  `language` varchar(1024) CHARACTER SET utf8 DEFAULT NULL,
  PRIMARY KEY (`err_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `global_active` */

CREATE TABLE `global_active` (
  `id` int(11) NOT NULL,
  `comment` varchar(1024) CHARACTER SET utf8 DEFAULT '' COMMENT '描述',
  `time_type` int(11) DEFAULT '0' COMMENT '0:时限活动 1:一次性活动 2:每日活动',
  `progress_type` int(11) DEFAULT '1' COMMENT '1:奖励活动 2:累计礼包活动 3:条件礼包活动 101特殊情况，累计充值获取最大奖励',
  `prize_type` int(11) DEFAULT '0' COMMENT '0:服务端发放 1:客户端领取',
  `s_times` int(11) DEFAULT '0',
  `e_times` int(11) DEFAULT '0',
  `op_state` int(11) DEFAULT '0' COMMENT '是否发布',
  `client_icon` varchar(255) CHARACTER SET utf8 DEFAULT '0',
  `client_title` varchar(255) CHARACTER SET utf8 DEFAULT '',
  `client_des` varchar(1024) CHARACTER SET utf8 DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `global_active_gift` */

CREATE TABLE `global_active_gift` (
  `gift_id` int(11) NOT NULL,
  `comment` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `active_id` int(11) DEFAULT NULL,
  `limit` varchar(255) CHARACTER SET utf8 DEFAULT '',
  `prize_id` int(11) DEFAULT '0',
  `ex_id` int(11) DEFAULT '0' COMMENT '扩展字段，标识一次性任务的id',
  PRIMARY KEY (`gift_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `global_active_prize` */

CREATE TABLE `global_active_prize` (
  `active_id` int(11) NOT NULL COMMENT '活动id',
  `comment` varchar(255) CHARACTER SET utf8 DEFAULT '',
  `privilege_type` int(11) DEFAULT '1' COMMENT '特权id 1:特权期间资源+ 2:特权期间享受的额外功能 3:特权期间享受的额外功能次数 4:特权期间每日奖励',
  `prize_id` varchar(255) CHARACTER SET utf8 DEFAULT '-1',
  `asset_type` int(11) DEFAULT '0' COMMENT 'attr:1 item:2 eip:4 buff:5',
  `asset_id` varchar(255) CHARACTER SET utf8 DEFAULT '0' COMMENT '资产id',
  `all_type` int(11) DEFAULT '0' COMMENT '奖励类型 1:加数值 2:乘数值 3:赋值',
  `all_v` int(11) DEFAULT '0',
  `client_icon` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '图标',
  `client_title` varchar(255) CHARACTER SET utf8 DEFAULT '',
  PRIMARY KEY (`active_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `global_config` */

CREATE TABLE `global_config` (
  `k1` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `k2` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `v` varchar(1024) CHARACTER SET utf8 DEFAULT NULL,
  `comment` varchar(1024) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `global_cost` */

CREATE TABLE `global_cost` (
  `cost_id` int(11) NOT NULL,
  `cost` varchar(1024) CHARACTER SET utf8 DEFAULT NULL COMMENT '[{type:1属性，2:道具,id, 数量}]',
  `comment` varchar(1024) CHARACTER SET utf8 DEFAULT NULL COMMENT '描述信息',
  PRIMARY KEY (`cost_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `global_cron` */

CREATE TABLE `global_cron` (
  `id` int(11) NOT NULL,
  `event` int(11) NOT NULL DEFAULT '1' COMMENT '1:开始 0:结束',
  `comment` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '注释',
  `type` int(11) DEFAULT '0' COMMENT '0:事件 1:活动',
  `week` varchar(1) CHARACTER SET utf8 DEFAULT '*' COMMENT '周',
  `year` varchar(6) CHARACTER SET utf8 DEFAULT '*' COMMENT '年',
  `month` varchar(2) CHARACTER SET utf8 DEFAULT '*' COMMENT '月',
  `day` varchar(2) CHARACTER SET utf8 DEFAULT '*' COMMENT '日',
  `hour` varchar(2) CHARACTER SET utf8 DEFAULT '*' COMMENT '时',
  `minite` varchar(2) CHARACTER SET utf8 DEFAULT '*' COMMENT '分',
  PRIMARY KEY (`id`,`event`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `global_mail` */

CREATE TABLE `global_mail` (
  `id` int(11) NOT NULL,
  `comment` varchar(255) DEFAULT '',
  `title` varchar(255) CHARACTER SET utf8 DEFAULT '',
  `content` varchar(1024) CHARACTER SET utf8 DEFAULT '',
  `prize_id` int(11) DEFAULT '0' COMMENT '附件',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `global_mail_mng` */

CREATE TABLE `global_mail_mng` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_id` int(11) DEFAULT NULL,
  `a_times` int(11) DEFAULT '0' COMMENT '激活群发时间',
  `e_times` int(11) DEFAULT '0' COMMENT '该邮件超时时间，0表示永不超时',
  `expires` int(11) DEFAULT '0' COMMENT '下发邮件过期天数， 0表示永不过期',
  `mail_id` int(11) DEFAULT '0' COMMENT 'global_mail_id',
  `limit` varchar(255) DEFAULT '' COMMENT '[[1,3,">",5]]',
  `op_state` int(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

/*Table structure for table `global_marquee` */

CREATE TABLE `global_marquee` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_id` int(11) DEFAULT '-999',
  `s_times` int(11) DEFAULT '0' COMMENT '时间戳',
  `e_times` int(11) DEFAULT '0' COMMENT '时间戳',
  `interval` int(11) DEFAULT '300' COMMENT '跑马灯间隔时间(秒数)',
  `content` varchar(2048) CHARACTER SET utf8 DEFAULT NULL COMMENT '跑马灯内容',
  `op_state` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='跑马灯';

/*Table structure for table `global_prize` */

CREATE TABLE `global_prize` (
  `prize_id` int(11) NOT NULL,
  `prize` varchar(1024) DEFAULT NULL COMMENT '奖励信息[对应的表::1.config_attr 2.config_item 3.config_skin, 对应表的id, 数量]',
  `comment` varchar(1024) DEFAULT NULL COMMENT '描述信息',
  PRIMARY KEY (`prize_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `global_task` */

CREATE TABLE `global_task` (
  `id` int(11) NOT NULL COMMENT '1:新手任务',
  `chain_id` int(11) DEFAULT NULL,
  `prize_id` int(11) DEFAULT NULL COMMENT '奖励信息',
  `limit` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '限制条件',
  `completion` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '完成条件',
  `client_set` int(11) DEFAULT '0' COMMENT '允许客户端设置',
  `title` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '描述',
  `content` varchar(1024) CHARACTER SET utf8 DEFAULT '' COMMENT '描述信息',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `global_task_chain` */

CREATE TABLE `global_task_chain` (
  `chain_id` int(11) NOT NULL,
  `comment` varchar(1024) CHARACTER SET utf8 DEFAULT NULL,
  PRIMARY KEY (`chain_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `server_client` */

CREATE TABLE `server_client` (
  `s_node` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `s_name` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '名称',
  `url` varchar(1024) CHARACTER SET utf8 DEFAULT '' COMMENT '链接地址',
  `port` int(11) DEFAULT '0',
  `s_type` int(11) DEFAULT '0' COMMENT '1:web服 2:网关服 3:游戏服 4:战斗服 5:db服 6:节点管理服 11:gm工具服',
  `s_version` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '服务端版本号',
  `status` int(11) DEFAULT '0' COMMENT '0:未启动 1:启动',
  PRIMARY KEY (`s_node`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
