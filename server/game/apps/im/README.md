# im

im服务器

# 签名方式
+ sign = string.to_lower(md5(app_id+"."+app_secret))

# API

## 上传文件
功能            | url
--------------- | ---------------------------------------------------------
上传文件        | /file/upload?app_id=${app_id}&i_id=${i_id}&token=${token}

### 服务器调用api
功能     | url
----------------| -----------------------------------------------------
注册账户        | /user/create?app_id=${app_id}&i_id=${i_id}&sign=${sign}
创建聊天室      | /chat/create?app_id=${app_id}&tid=${tid}&member=${member}&sign=${sign}
加入聊天室      | /chat/add?app_id=&tid=&i_id=&sign=
踢出聊天室      | /chat/kick?app_id=&tid=&i_id=&sign=
注销聊天室      | /chat/logout?app_id=&tid=&sign

## http返回值

+ {"code":"200", "msg":"msg"}
