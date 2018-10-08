/*
SQLyog Ultimate v12.4.1 (64 bit)
MySQL - 5.7.18-log : Database - game_user
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`game_user` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

USE `game_user`;

/*Table structure for table `bulletin_board` */

CREATE TABLE `bulletin_board` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_id` int(11) DEFAULT '-999' COMMENT '渠道',
  `s_times` int(11) DEFAULT NULL COMMENT '开始时间戳',
  `e_times` int(11) DEFAULT NULL COMMENT '结束时间戳',
  `icon` varchar(255) CHARACTER SET utf8 DEFAULT '""' COMMENT 'icon',
  `title` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8 COMMENT '内容',
  `sort` int(11) DEFAULT '1' COMMENT '显示权重,越大显示在越前面',
  `op_state` int(2) DEFAULT '0' COMMENT '操作状态, 0不生效 1生效',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4;

/*Table structure for table `channel` */

CREATE TABLE `channel` (
  `channel_id` int(11) NOT NULL COMMENT '渠道id',
  `channel_name` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT '渠道描述',
  `call_mod` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`channel_id`),
  UNIQUE KEY `channel_id` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `channel_recharge` */

CREATE TABLE `channel_recharge` (
  `channel_id` int(11) NOT NULL,
  `recharge_id` int(11) NOT NULL,
  `recharge_name` varchar(255) DEFAULT NULL,
  `call_mod` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`channel_id`,`recharge_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `client_version` */

CREATE TABLE `client_version` (
  `channel_id` int(11) NOT NULL,
  `version` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '' COMMENT '小于等于该版本',
  `comment` varchar(255) DEFAULT NULL,
  `goto_link` varchar(1024) CHARACTER SET utf8 DEFAULT '',
  `s_url` varchar(1024) CHARACTER SET utf8 DEFAULT '',
  `s_port` int(11) DEFAULT '0',
  `op_state` int(11) DEFAULT '0' COMMENT '操作状态, 0不生效 1生效',
  PRIMARY KEY (`channel_id`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='配置某个发行版本是强更还是分流到渠道服';

/*Table structure for table `config` */

CREATE TABLE `config` (
  `k` int(11) NOT NULL,
  `comment` varchar(255) CHARACTER SET utf8 DEFAULT '',
  `v` varchar(2048) CHARACTER SET utf8 DEFAULT '',
  `op_state` int(11) DEFAULT '0',
  PRIMARY KEY (`k`),
  UNIQUE KEY `k` (`k`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `feedback` */

CREATE TABLE `feedback` (
  `uid` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `channel_id` int(11) DEFAULT '-999',
  `version` varchar(32) CHARACTER SET utf8 DEFAULT NULL,
  `udid` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `ip` varchar(32) CHARACTER SET utf8 DEFAULT NULL,
  `c_times` int(11) DEFAULT NULL,
  `u_times` int(11) DEFAULT '0',
  `msg` varchar(1024) CHARACTER SET utf8 DEFAULT NULL,
  `contact` varchar(32) CHARACTER SET utf8 DEFAULT NULL,
  `status` int(11) DEFAULT '0' COMMENT '0:已反馈 1:已查看 2:已处理 3:玩家删除',
  PRIMARY KEY (`uid`,`auto_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `orders` */

CREATE TABLE `orders` (
  `order_id` varchar(64) CHARACTER SET utf8 NOT NULL COMMENT '游戏订单号',
  `c_times` int(11) NOT NULL COMMENT '创建时间戳',
  `e_times` int(11) DEFAULT NULL COMMENT '完成时间戳',
  `uid` int(11) NOT NULL COMMENT '角色id',
  `channel_id` int(11) DEFAULT NULL COMMENT '渠道',
  `recharge_id` int(11) DEFAULT NULL COMMENT '支付平台',
  `goods_id` int(11) NOT NULL COMMENT '道具id',
  `goods_num` int(11) DEFAULT '1' COMMENT '道具数量',
  `amount` int(11) DEFAULT '0' COMMENT '金额 单位:分',
  `currency` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT '货币类型',
  `status` int(11) DEFAULT '0' COMMENT '0:已创建 1:通知到服务器 2:充值成功 4:放弃充值 5:充值失败',
  `is_pro` int(1) DEFAULT '0' COMMENT '0:测试环境 1:生产环境',
  `order_num` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT '平台订单号',
  `out_order` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT '第三方平台订单号',
  `out_order_info` varchar(2048) DEFAULT NULL COMMENT '订单相信信息',
  PRIMARY KEY (`order_id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `orders_err` */

CREATE TABLE `orders_err` (
  `order_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `msg` varchar(2048) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Table structure for table `switch` */

CREATE TABLE `switch` (
  `channel_id` int(11) NOT NULL DEFAULT '-999',
  `comment` varchar(1024) CHARACTER SET utf8 DEFAULT NULL,
  `switchs` varchar(1024) CHARACTER SET utf8 DEFAULT NULL COMMENT '放入该列表的功能表示需要关闭',
  `op_state` int(11) DEFAULT '0',
  PRIMARY KEY (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `user` */

CREATE TABLE `user` (
  `uin` int(11) NOT NULL AUTO_INCREMENT,
  `c_times` int(11) DEFAULT NULL COMMENT '账号创建时间戳',
  `user_name` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `pwd` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `channel_id` int(11) DEFAULT '-999' COMMENT '渠道',
  `sdk_openid` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT '第三方平台的openid',
  `sdk_token` varchar(1024) CHARACTER SET utf8 DEFAULT NULL,
  `udid` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT '设备号',
  `ins` varchar(8) CHARACTER SET utf8 DEFAULT NULL COMMENT '国际编码',
  `tel` varchar(32) CHARACTER SET utf8 DEFAULT NULL COMMENT '手机号',
  `login_type` int(1) DEFAULT NULL COMMENT '1:游客登陆 2:账户登陆 3:sdk登陆 4:手机号登陆',
  `ban_times` int(11) DEFAULT NULL COMMENT '封号截至时间',
  PRIMARY KEY (`uin`),
  UNIQUE KEY `tel` (`tel`),
  UNIQUE KEY `user_name` (`user_name`),
  UNIQUE KEY `udid` (`channel_id`,`udid`),
  UNIQUE KEY `sdk_openid` (`channel_id`,`sdk_openid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `user_band` */

CREATE TABLE `user_band` (
  `channel_id` int(11) NOT NULL,
  `open_id` varchar(255) CHARACTER SET utf8 NOT NULL COMMENT '账号绑定功能',
  `uin` int(11) DEFAULT NULL,
  PRIMARY KEY (`channel_id`,`open_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Table structure for table `user_info` */

CREATE TABLE `user_info` (
  `uin` int(11) NOT NULL,
  `token` varchar(32) DEFAULT '',
  `gmt_offset` int(11) DEFAULT '28800' COMMENT '时差',
  `nick` varchar(255) CHARACTER SET utf8 DEFAULT '' COMMENT '用户昵称',
  `sex` int(11) DEFAULT '0' COMMENT '性别',
  `head_img` varchar(1024) CHARACTER SET utf8 DEFAULT '' COMMENT '头像',
  `address` varchar(1024) CHARACTER SET utf8 DEFAULT '' COMMENT '地址',
  PRIMARY KEY (`uin`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
