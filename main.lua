-- LuaTools需要PROJECT和VERSION这两个信息
PROJECT = "BUAALogin"
VERSION = "1.0.0"

-- 认证信息
local username = "填写学号"
local password = "填写密码"

-- WiFi 信息
local ssid = "WiFi名称"
local wifipwd = "WiFi密码"

-- 检测间隔（毫秒）
local interval = 600000 -- 10 minutes

_G.sys = require("sys")
_G.sysplus = require("sysplus")
gw = require("srun")

-- if wdt then
--     wdt.init(15000)--初始化watchdog设置为15s
--     sys.timerLoopStart(wdt.feed, 10000)--10s喂一次狗
-- end

-- sys.subscribe("NTP_UPDATE", function()
--     log.info("sntp", "time", os.date())
-- end)

sys.taskInit(function()
    if rtos.bsp():startsWith("ESP32") then
        log.info("wifi", ssid, wifipwd)
        LED = gpio.setup(12, 0, gpio.PULLUP)
        wlan.init()
        wlan.setMode(wlan.STATION)
        wlan.connect(ssid, wifipwd, 1)
        local result, data = sys.waitUntil("IP_READY", 30000)
        log.info("wlan", "IP_READY", result, data)
        device_id = wlan.getMac()
    else
        log.error("platform", "Unsupported platform")
        return
    end

    socket.sntp("ntp.tuna.tsinghua.edu.cn", "ntp.ntsc.ac.cn", "ntp1.aliyun.com")

    sys.waitUntil("NTP_UPDATE", 10000)

    while true do
        gw.detect(username, password)
        sys.wait(interval)
    end
end)

sys.run()
