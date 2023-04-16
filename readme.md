# 北航联网自动认证脚本 ESP32C3版

本Lua脚本可以实现基于ESP32C3开发板的无线路由自动联网认证，免去隔段时间手动登录认证的麻烦。

## 使用方法

0. 购买esp32c3开发板，合宙官方淘宝店9.9包邮
1. 下载烧录工具[LuaTools](https://wiki.luatos.com/pages/tools.html)
2. 使用usb数据线连接开发板到电脑，打开LuaTools，选择对应com口，打开串口
3. 打开本项目的main.lua，编辑里面的认证信息、WiFi信息，保存
4. 点击LuaTools右侧的`项目管理测试`按钮，在新窗口中左下角点击创建项目
5. 右上角选择文件，目标是LuaTools目录下的`resource\esp32c3_lua_lod\core_V1004\LuatOS-SoC_V1004_ESP32C3.soc` （core的版本选自动更新的最新版即可）
6. 右侧`增加脚本或资源文件`，选择本项目的三个lua文件
7. 点击`下载底层和脚本`按钮，完成设置

之后只要开发板保持通电，就能让无线路由保持联网了。板子的供电可以使用usb，也可以使用dc直流电源。

## 其他项目

- [Izumiko/beihangLogin](https://github.com/Izumiko/beihangLogin)：Go语言写的北航联网认证工具，无外部依赖。本修改版增加了detect命令检测登录状态，方便设置定时任务。
- [Izumiko/buaalogin](https://github.com/Izumiko/buaalogin)：Nim语言写的北航联网认证工具，功能同上，体积较小，但依赖外部的ssl库，可放在openwrt路由器中使用。
- [Synlvejo/buaalogin](https://github.com/Synlvejo/buaalogin)：Shell版本的北航联网认证工具，体积最小，依赖bash和curl。
