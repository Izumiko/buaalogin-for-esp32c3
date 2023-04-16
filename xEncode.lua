-- convert bytes to string
local function bytes2str(bytes, start)
    local str = ""
    for i = start, #bytes do
        str = str .. string.char(bytes[i])
    end
    return str
end

-- trash base64
local function trashBase64(str)
    local base64N = "LVoJPiCN2R8G90yg+hmFHuacZ1OWMnrsSTXkYpUq/3dlbfKwv6xztjI7DeBE45QA"
    local a = #str
    local ln = math.floor(a / 3) * 4
    if ln % 3 ~= 0 then
        ln = ln + 4
    end
    local u = {}
    local r = string.byte('=')
    local ui = 0
    -- log.info("trashBase64", "str", str)
    for o = 0, a - 1, 3 do
        local p = {}
        p[2] = string.byte(string.sub(str, o + 1, o + 1))
        if o + 2 <= a then
            p[1] = string.byte(string.sub(str, o + 2, o + 2))
        else
            p[1] = 0
        end
        if o + 3 <= a then
            p[0] = string.byte(string.sub(str, o + 3, o + 3))
        else
            p[0] = 0
        end
        local h = p[2] << 16 | p[1] << 8 | p[0]
        for i = 0, 3 do
            if o * 8 + i * 6 > a * 8 then
                u[ui] = r
            else
                local idx = h >> 6 * (3 - i) & 63
                u[ui] = string.byte(string.sub(base64N, idx + 1, idx + 1))
            end
            ui = ui + 1
        end
    end
    return bytes2str(u, 0)
end

local function s(a, b)
    local c = #a
    local v = {}
    local count = math.floor((c + 3) / 4) - 1
    for i = 0, count do
        v[i] = 0
    end
    for i = 0, c - 1, 4 do
        for j = 0, 3 do
            if i + j >= c then
                break
            end
            -- log.info("s", i, j, a)
            -- log.info("s", string.sub(a,i + j + 1, i + j + 1))
            v[i >> 2] = v[i >> 2]| string.byte(string.sub(a, i + j + 1, i + j + 1)) << (j * 8)
        end
    end
    if b then
        table.insert(v, c)
    end
    return v
end

local function l(a, b)
    local d = #a
    local c = (d - 1) << 2
    if b then
        local m = a[d - 1]
        if m < c - 3 or m > c then
            return nil
        end
        c = m
    end
    local tmp = {}
    for i = 0, d do
        table.insert(tmp, a[i] & 255)
        table.insert(tmp, a[i] >> 8 & 255)
        table.insert(tmp, a[i] >> 16 & 255)
        table.insert(tmp, a[i] >> 24 & 255)
    end
    local str = bytes2str(tmp, 1)
    if b then
        return string.sub(str, 1, c + 1)
    else
        return str
    end
end

local function xEncode(info, token)
    if info == nil or #info == 0 then
        return ""
    end
    local v = s(info, true)
    local k = s(token, false)
    local n = #v
    local z = v[n]
    local y = v[0]
    local d = 0
    local count = math.floor(6 + 52 / (n + 1))
    for q = count, 1, -1 do
        d = d + 0x9e3779b9
        local e = d >> 2 & 3
        for p = 0, n do
            if p < n then
                y = v[p + 1]
            else
                y = v[0]
            end
            local m = ((z >> 5) ~ (y << 2)) & 0xffffffff
            m = m + (((y >> 3) ~ (z << 4)) ~ (d ~ y)) & 0xffffffff
            m = m + ((k[(p & 3) ~ e] ~ z)) & 0xffffffff
            v[p] = (v[p] + m) & 0xffffffff
            z = v[p]
        end
    end
    return l(v, false)
end

local function getEncodedInfo(info, token)
    -- log.info("getEncodedInfo", info, token)
    local encodedInfo = xEncode(info, token)
    local base64Info = trashBase64(encodedInfo)
    return "{SRBX1}" .. base64Info
end

local function getEncodedPassword(password, token)
    local md5 = crypto.hmac_md5(password, token)
    return string.lower(md5)
end

local function getEncodedChkstr(chkstr)
    local sha1 = crypto.sha1(chkstr)
    return string.lower(sha1)
end

local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
    if url == nil then
        return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w _ %- . ~])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
end

return {
    getEncodedInfo = getEncodedInfo,
    getEncodedPassword = getEncodedPassword,
    getEncodedChkstr = getEncodedChkstr,
    urlencode = urlencode
}
