#[游戏服务端架构](https://github.com/yujian1018/m_game/blob/master/game/README.md)

## 游戏架构
![game_des](https://raw.githubusercontent.com/yujian1018/m_game/master/doc/%E9%A1%B9%E7%9B%AE%E6%96%87%E6%A1%A3/game_%E6%A1%86%E6%9E%B6.png)

# 小技巧

##关于优化

###协议

> * 数据下发。一个协议中涉及到的所有需要下发的数据可以整合到一起，统一由一次gen_tcp:send下发
> * 执行时间。每个协议的执行时间最好少于50毫秒



------


## 关于编码

> * 能够独立的功能，尽量独立成一个单独的系统

> * 为了避免编码问题，尽量使用binary表示中文


## mysql驱动

> * 插入到mysql的字符串需要先转换成binary
