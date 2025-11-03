-- Roblox Lua Şifreli Kod
-- Şifreleme Tarihi: 03.11.2025 21:49:52

local encoded = "LS0gVGVzdCBpw6dpbiBiYXNpdCBiaXIgUm9ibG94IGtvZHUKcHJpbnQoIvCflKcgVGVzdCBiYcWfbMSxeW9yLi4uIikKCi0tIERlxJ9pxZ9rZW5sZXIKbG9jYWwgb3l1bmN1QWRpID0gIlRlc3RPeXVuY3UiCmxvY2FsIHNldml5ZSA9IDEwCmxvY2FsIGNhbiA9IDEwMAoKLS0gRm9ua3NpeW9ubGFyCmZ1bmN0aW9uIHNlbGFtVmVyKGFkKQogICAgcmV0dXJuICJNZXJoYWJhLCAiIC4uIGFkIC4uICIhIgplbmQKCmZ1bmN0aW9uIGhhc2FwbGEoeCwgeSkKICAgIHJldHVybiB4ICogeSArIHggLyB5CmVuZAoKLS0gRMO2bmfDvGxlcgpmb3IgaSA9IDEsIDMgZG8KICAgIHByaW50KCJEw7ZuZ8O8ICIgLi4gaSkKZW5kCgotLSBLb8WfdWxsYXIKaWYgc2V2aXllID4gNSB0aGVuCiAgICBwcmludCgiVGVicmlrbGVyISBTZXZpeWUgNSdpIGdlw6d0aW4uIikKZWxzZQogICAgcHJpbnQoIkRldmFtIGV0LCBzZXZpeWUgNSdlIHlha2xhxZ90xLFuLiIpCmVuZAoKLS0gVGFibG9sYXIKbG9jYWwgZXN5YWxhciA9IHsiS8SxbMSxw6ciLCAiS2Fsa2FuIiwgIlrEsXJoIn0KZm9yIF8sIGVzeWEgaW4gcGFpcnMoZXN5YWxhcikgZG8KICAgIHByaW50KCJFxZ95YTogIiAuLiBlc3lhKQplbmQKCnByaW50KCLinIUgVGVzdCB0YW1hbWxhbmTEsSEiKQ=="

-- Base64 decode fonksiyonu (Roblox uyumlu)
local function base64_decode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Kod çözme ve çalıştırma
local decoded = base64_decode(encoded)
local func, err = loadstring(decoded)

if func then
    func()
else
    warn("Şifre çözme hatası: " .. tostring(err))
end
