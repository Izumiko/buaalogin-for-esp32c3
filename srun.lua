xencode = require("xEncode")

local baseUrl = "https://gw.buaa.edu.cn/cgi-bin/"
local callbackName = "autologin"
local cookieUrl = "https://gw.buaa.edu.cn/index_1.html?ad_check=1"

local function getResponse(reqType, params)
    local reqUrl = baseUrl
    local p = params
    local switch = {
        ["challenge"] = "get_challenge",
        ["login"] = "srun_portal",
        ["logout"] = "srun_portal",
        ["status"] = "rad_user_info"
    }
    reqUrl = reqUrl .. switch[reqType]
    p["callback"] = callbackName
    p["_"] = tostring(os.time()) .. "000"
    -- p["ad_check"] = "1"
    local i = 0
    for k, v in pairs(p) do
        if i == 0 then
            reqUrl = reqUrl .. "?" .. k .. "=" .. xencode.urlencode(v)
        else
            reqUrl = reqUrl .. "&" .. k .. "=" .. xencode.urlencode(v)
        end
        i = i + 1
    end
    -- log.info("reqUrl", reqUrl)
    -- http header
    local req_headers = {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:96.0) Gecko/20100101 Firefox/96.0",
        ["Accept"] = "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01",
        ["Accept-Language"] = "zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3",
        ["Referer"] = "https://gw.buaa.edu.cn/srun_portal_pc?ac_id=1&theme=buaa&url=www.buaa.edu.cn",
        ["Cookie"] = "lang=zh-CN; AD_VALUE=5c0e4450; cookie=0"
    }
    local code, headers, body = http.request("GET", cookieUrl, req_headers).wait()
    -- log.info("code: ", code)
    -- log.info("headers: ", headers["Set-Cookie"])
    if headers["Set-Cookie"] then
        req_headers["Cookie"] = headers["Set-Cookie"] .. "; cookie=0"
    end
    local code, headers, body = http.request("GET", reqUrl, req_headers).wait()
    if body == nil then
        return nil
    end
    local jsonstr = string.sub(body, #callbackName + 2, #body - 1)
    local res = json.decode(jsonstr)
    -- log.info("code: ", code)
    -- log.info("body: ", jsonstr)
    return res
end

local function getLoginParams(username, password, ac_id, ip, enc_ver, n, Type, os, name, double_stack, token)
    local infoJson = {
        username = username,
        password = password,
        ac_id = ac_id,
        ip = ip,
        enc_ver = enc_ver
    }
    local info = xencode.getEncodedInfo(json.encode(infoJson), token)
    local pwd = xencode.getEncodedPassword(password, token)
    local chkstr = token ..
        username .. token .. pwd .. token .. ac_id .. token .. ip .. token .. n .. token .. Type .. token .. info
    local chksum = xencode.getEncodedChkstr(chkstr)
    local params = {
        action = "login",
        username = username,
        password = "{MD5}" .. pwd,
        ac_id = ac_id,
        ip = ip,
        n = n,
        type = Type,
        double_stack = double_stack,
        info = info,
        chksum = chksum
    }
    return params
end

local function login(username, password)
    local ac_id = "1"
    local enc_ver = "srun_bx1"
    local n = "200"
    local Type = "1"
    local os = "Windows 10"
    local name = "Windows"
    local double_stack = "0"

    local challenge = getResponse("challenge", { username = username })
    local token = challenge["challenge"]
    local ip = challenge["client_ip"]
    -- log.info("login", token, ip)

    local params = getLoginParams(username, password, ac_id, ip, enc_ver, n, Type, os, name, double_stack, token)
    local resp = getResponse("login", params)
    local status = resp["error"]

    if status == "ok" then
        log.info("login", resp["suc_msg"])
        return true
    else
        log.info("login", resp["error_msg"])
        return false
    end
end

local function detect(username, password)
    local resp = getResponse("status", {})
    local status = resp["error"]
    if status == nil then
        log.warn("detect", "Network error")
    elseif status == "ok" then
        log.info("detect", "Already logged in")
    else
        log.info("detect", "Not logged in, trying to login")
        -- try to login for 3 times
        for i = 1, 3 do
            if login(username, password) then
                break
            else
                log.warn("detect", "Login failed, retrying")
                sys.wait(2000)
            end
        end
    end
end

return {
    detect = detect
}
