local OffsetService = {}
OffsetService.__index = OffsetService

local http = game:GetService("HttpService")

function OffsetService.new()
    local self = setmetatable({}, OffsetService)

    local ok, response = pcall(function() 
        return game:HttpGet("https://offsets.imtheo.lol/offsets.json") 
    end)

    if not ok or not response then 
        return self
    end

    local data = http:JSONDecode(response)
    self.data = data and data.Offsets or {}
    return self
end

function OffsetService:GetPointer(address, offset)
    if not address then return end
    if not offset then return end

    return memory_read("uintptr_t", address + offset)
end

function OffsetService:GetStringLength(address, offset)
    if not address then return end
    if not offset then return end

    local offsetLen = self.data.Misc.StringLength
    return memory_read("int", address + offset + offsetLen)
end

function OffsetService:GetString(address, offset)
    if not address then return end
    if not offset then return end

    local addr = address + offset
    local str  = memory_read("string", addr)
    local len  = self:GetStringLength(address, offset)

    if len <= 0 or len >= 2000 then return "" end

    if len >= 16 then
        local ptr = self:GetPointer(address, offset)
        if not ptr then return "" end -- invalid ptr

        str = memory_read("string", ptr)
    end

    return str
end

_G.OffsetService = OffsetService
return OffsetService
