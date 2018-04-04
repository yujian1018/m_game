# web

web服务器：登录，支付，公告，版本验证，开关功能，公共可访问的功能

# 签名方式

+ 数据传输方式：http get请求
+ 签名：http get请求中加入两个字段 date,sign
+ date表示当前请求时间
+ sign=md5("date="+date+"&key=约定好的字符串")

# API

## 登录API

功能            | url
--------------- | ---------------------------------------------------------
游客登录        | /login/guest?通用参数&gmt_offset=28800
帐号密码登录    | /login/account?通用参数&account_name=1&account_pwd=2&gmt_offset=28800
sdk登录接口     | /login/sdk?通用参数&open_id=sdk的openid&token=验证token&gmt_offset=28800
帐号绑定        | /login/account_bind?通用参数&uin=uin&local_token=uin当前的token

### 通用参数
参数             | 注释
----------------| -----------------------------------------------------
date            | 1476495339615 时间戳
sign            | 670ac979a50468fdf8ab33ad599942b5 签名
packet_id       | 包名称
channel_id      | 登录方式 0:测试渠道,-1:Apple store登录,-2:桌面版登录
udid            | 设备唯一号
device_pf       | 设备平台 ios,androd,wp,桌面版(web)

## 支付回调API

功能     | url
--------------------- | -----------------------------------------------------
支付回调            | /pay_cb/sdk?通用参数&platform_id=支付平台id post order_id=游戏订单号&out_order=支付平台订单号&sdk_order=sdk订单号&money=金额（分）&currency=rmb&attach=附加参数
apple支付回调       | /pay_cb/sdk?通用参数&platform_id=支付平台id post order_id=OrderId&goodsOrderId-data=AppleOrderId&goodsPrice-data=Price&receipt-data=ReceiptData


## 公共接口API
功能              | url
----------------- | -----------------------------------------------------
活动公告          | /api/campaign json:{"list":[{"stime", "etime", "title", "icon", "content"}]},switchs:[]
強更、获取服务器  | /api/server_list?通用参数&channel_id=1&version=1.0.0&ip=192.168.2.51&port=8087 || {"return":"error", "err_code":6, "err_msg":"http://www.game2us.cn/down", "s_version":"1.1.1"}
強更、获取服务器  | /api/get_server?date=日期&sign=签名&channel_id=1&version=1.0.0  {"return":"ok","ip":"192.168.2.51",port:3306} || {"return":"error", "err_code":6, "err_msg":"http://www.game2us.cn/down", "s_version":"1.1.1"}


## http返回值

+ {"return":"ok", "uid":"1", "token":"670ac979a50468fdf8ab33ad599942b5uid"}
+ {"return":"error", "err_code":-1, "err_msg":"密码不正确"}

## 错误码
沿用游戏中的错误码
5       最多只能输入15个数字、字母或者下划线
51      参数不正确
52      密码不正确
53      签名不正确
12      版本不一致
2       游戏服务器维护中（读取err_msg字段）

3001    登录失败
3101    支付地址，验证失败
3102    支付失败