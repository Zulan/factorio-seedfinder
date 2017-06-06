--[[--
Simple logger by Dark
--]]--

local _M = {}
local Logger = {prefix='log_'}
Logger.__index = Logger

function Logger:log(str)
  self.log_buffer[#self.log_buffer + 1] = str
end

function Logger:dump(file_name)
  if #self.log_buffer == 0 then return false end
  file_name = file_name or "logs/"..self.prefix..game.tick..".log"
  game.write_file(file_name, table.concat(self.log_buffer))
  self.log_buffer = {}
  return true
end


function _M.new_logger()
  local temp = {log_buffer = {}}
  return setmetatable(temp, Logger)
end
return _M