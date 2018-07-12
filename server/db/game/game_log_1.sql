/*
SQLyog Ultimate v12.4.1 (64 bit)
MySQL - 5.7.18-log : Database - game_log_1
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`game_log_1` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

USE `game_log_1`;

/*Table structure for table `log_attr_id_3` */

CREATE TABLE `log_attr_id_3` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL COMMENT '时间戳',
  `uid` int(11) DEFAULT NULL,
  `asset_id` int(11) DEFAULT NULL,
  `v` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `times` (`c_times`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `log_attr_lv` */

CREATE TABLE `log_attr_lv` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `lv` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Table structure for table `log_device` */

CREATE TABLE `log_device` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL,
  `udid` varchar(255) DEFAULT NULL COMMENT '设备号',
  `uin` int(11) DEFAULT NULL,
  `device_pf` varchar(64) DEFAULT NULL COMMENT '渠道',
  `ip` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `c_times` (`c_times`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `log_gm_op` */

CREATE TABLE `log_gm_op` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL,
  `cmd` varchar(64) DEFAULT NULL,
  `uid` varchar(22) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `log_item_id_101001` */

CREATE TABLE `log_item_id_101001` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `asset_id` int(11) DEFAULT NULL,
  `v` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Table structure for table `log_location` */

CREATE TABLE `log_location` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uin` int(11) DEFAULT NULL,
  `ip` int(11) DEFAULT NULL,
  `gps` int(11) DEFAULT NULL,
  `location` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `log_login_log` */

CREATE TABLE `log_login_log` (
  `udid` varchar(128) NOT NULL,
  `version` varchar(32) NOT NULL DEFAULT '',
  `channel_id` varchar(32) NOT NULL DEFAULT '',
  `uid` int(11) DEFAULT NULL,
  `ip` varchar(32) DEFAULT NULL,
  `t0_times` int(11) DEFAULT NULL COMMENT '启动应用',
  `t1_times` int(11) DEFAULT NULL COMMENT '强更完成',
  `t2_times` int(11) DEFAULT NULL COMMENT '热更完成',
  `t3_times` int(11) DEFAULT NULL COMMENT '加载资源完成',
  `t4_times` int(11) DEFAULT NULL COMMENT '登录界面打开完成',
  `t5_times` int(11) DEFAULT NULL COMMENT '点击fb按钮',
  `t6_times` int(11) DEFAULT NULL COMMENT '点击游客按钮',
  `t51_times` int(11) DEFAULT NULL COMMENT '链接服务器完成',
  `t52_times` int(11) DEFAULT NULL COMMENT '获取静态表完成',
  `t53_times` int(11) DEFAULT NULL COMMENT '登录游戏服完成',
  `t54_times` int(11) DEFAULT NULL COMMENT '获取动态表完成',
  `t101_times` int(11) DEFAULT NULL COMMENT '进入到主界面完成',
  PRIMARY KEY (`udid`,`version`,`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `log_login_op` */

CREATE TABLE `log_login_op` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL COMMENT '0:登陆 1：登出',
  `layer_id` int(11) DEFAULT NULL COMMENT '登出停留界面',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `log_online` */

CREATE TABLE `log_online` (
  `c_times` int(11) DEFAULT NULL COMMENT '当前时间戳',
  `uid` int(11) DEFAULT NULL COMMENT '玩家ID',
  `online_time` int(11) DEFAULT '1' COMMENT '在线时间',
  UNIQUE KEY `times` (`c_times`,`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `log_role_op` */

CREATE TABLE `log_role_op` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) DEFAULT NULL,
  `op` varchar(2048) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `log_s_count` */

CREATE TABLE `log_s_count` (
  `c_times` int(11) DEFAULT NULL COMMENT '每隔多少时间统计在线量',
  `server_id` int(11) DEFAULT NULL COMMENT '服务器id',
  `num` int(11) DEFAULT NULL COMMENT '当前时间的服务器在线人数'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `log_send_mail` */

CREATE TABLE `log_send_mail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) DEFAULT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT '0' COMMENT '0:普通邮件 1:福利邮件 2:补偿邮件',
  `c_times` int(11) DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `content` varchar(3071) CHARACTER SET utf8 DEFAULT NULL,
  `appendix` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `c_times` (`c_times`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `log_task` */

CREATE TABLE `log_task` (
  `uid` int(11) DEFAULT NULL,
  `chain_id` int(11) DEFAULT '0',
  `index` int(11) DEFAULT '0' COMMENT '-1:跳过',
  `u_times` int(11) DEFAULT NULL COMMENT '更新时间',
  UNIQUE KEY `uid` (`uid`,`chain_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/*Table structure for table `report_asset` */

CREATE TABLE `report_asset` (
  `times` int(11) NOT NULL,
  `gold_prize` int(11) DEFAULT NULL COMMENT '金币产出',
  `gold_cost` int(11) DEFAULT NULL COMMENT '金币消耗',
  PRIMARY KEY (`times`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `report_asset_diamond` */

CREATE TABLE `report_asset_diamond` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `asset_id` int(11) DEFAULT NULL,
  `v` bigint(20) DEFAULT NULL,
  `count_roles` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/*Table structure for table `report_asset_gold` */

CREATE TABLE `report_asset_gold` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `asset_id` int(11) DEFAULT NULL,
  `v` bigint(20) DEFAULT NULL,
  `count_roles` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `report_asset_item` */

CREATE TABLE `report_asset_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `asset_id` int(11) DEFAULT NULL,
  `v` bigint(20) DEFAULT NULL,
  `count_roles` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `report_asset_item_cost` */

CREATE TABLE `report_asset_item_cost` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `asset_id` int(11) DEFAULT NULL,
  `v` bigint(20) DEFAULT NULL,
  `count_roles` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `report_data_center` */

CREATE TABLE `report_data_center` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `times` int(11) DEFAULT NULL COMMENT '时间戳',
  `channel_id` int(11) DEFAULT NULL COMMENT '渠道平台',
  `c_roles` int(11) DEFAULT NULL COMMENT '角色数量',
  `c_devices` int(11) DEFAULT NULL COMMENT '新注册设备数',
  `c_accounts` int(11) DEFAULT NULL COMMENT '帐号注册数',
  `c_guests` int(11) DEFAULT NULL COMMENT '游客注册数',
  `login_roles` int(11) DEFAULT NULL COMMENT '登陆角色数',
  `login_count` int(11) DEFAULT NULL COMMENT '登陆次数',
  `recharge_amount` int(11) DEFAULT NULL COMMENT '充值金额',
  `recharge_accounts` int(11) DEFAULT NULL COMMENT '充值用户数',
  `recharge_count` int(11) DEFAULT NULL COMMENT '充值次数',
  `new_recharge_accounts` int(11) DEFAULT NULL COMMENT '每日新付费用户数',
  `new_recharge_amount` int(11) DEFAULT NULL COMMENT '每日新用户充值金额',
  `pcu` int(11) DEFAULT NULL COMMENT '最高在线人数',
  `pcu_date` int(11) DEFAULT NULL COMMENT '最高在线时间',
  `acu` int(11) DEFAULT NULL COMMENT '平均在线人数',
  `acu_duration` int(11) DEFAULT NULL COMMENT '平均在线时长',
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `report_data_ltv` */

CREATE TABLE `report_data_ltv` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `times` int(11) DEFAULT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `count_roles` int(11) DEFAULT NULL,
  `ltv_1` int(11) DEFAULT NULL,
  `ltv_2` int(11) DEFAULT NULL,
  `ltv_3` int(11) DEFAULT NULL,
  `ltv_4` int(11) DEFAULT NULL,
  `ltv_5` int(11) DEFAULT NULL,
  `ltv_6` int(11) DEFAULT NULL,
  `ltv_15` int(11) DEFAULT NULL,
  `ltv_30` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Table structure for table `report_login_out` */

CREATE TABLE `report_login_out` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `layer_id` int(11) DEFAULT NULL,
  `v` int(11) DEFAULT NULL,
  `count_roles` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `report_lv` */

CREATE TABLE `report_lv` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) NOT NULL COMMENT '时间戳',
  `channel_id` int(11) DEFAULT NULL,
  `lv` int(11) DEFAULT NULL COMMENT '等级',
  `count_num` int(11) DEFAULT NULL COMMENT '等级人数',
  PRIMARY KEY (`id`),
  KEY `times` (`c_times`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `report_retain` */

CREATE TABLE `report_retain` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `times` int(11) DEFAULT NULL,
  `channel_id` int(11) DEFAULT NULL COMMENT '渠道平台',
  `count_roles` int(11) DEFAULT '0' COMMENT '创建角色数量',
  `re_1` int(11) DEFAULT '0' COMMENT '次日留存数',
  `re_2` int(11) DEFAULT '0' COMMENT '2日留存数',
  `re_3` int(11) DEFAULT '0' COMMENT '3日留存数',
  `re_4` int(11) DEFAULT '0' COMMENT '4日留存数',
  `re_5` int(11) DEFAULT '0' COMMENT '5日留存数',
  `re_6` int(11) DEFAULT '0' COMMENT '6日留存数',
  `re_15` int(11) DEFAULT '0',
  `re_30` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `times` (`times`,`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `report_retain_udid` */

CREATE TABLE `report_retain_udid` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `times` int(11) DEFAULT NULL,
  `channel_id` int(11) DEFAULT NULL COMMENT '渠道平台',
  `count_roles` int(11) DEFAULT '0' COMMENT '创建设备数',
  `re_1` int(11) DEFAULT '0' COMMENT '次日留存数',
  `re_2` int(11) DEFAULT '0' COMMENT '2日留存数',
  `re_3` int(11) DEFAULT '0' COMMENT '3日留存数',
  `re_4` int(11) DEFAULT '0' COMMENT '4日留存数',
  `re_5` int(11) DEFAULT '0' COMMENT '5日留存数',
  `re_6` int(11) DEFAULT '0' COMMENT '6日留存数',
  `re_15` int(11) DEFAULT '0',
  `re_30` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `times` (`times`,`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `report_task` */

CREATE TABLE `report_task` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_id` int(11) DEFAULT NULL,
  `c_times` int(11) DEFAULT NULL,
  `task_id` int(11) DEFAULT NULL,
  `num` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Table structure for table `report_vip` */

CREATE TABLE `report_vip` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) NOT NULL COMMENT '时间戳',
  `channel_id` int(11) DEFAULT NULL,
  `lv` int(11) DEFAULT NULL COMMENT 'vip等级',
  `count_num` int(11) DEFAULT NULL COMMENT 'vip等级人数',
  PRIMARY KEY (`id`),
  KEY `c_times` (`c_times`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
