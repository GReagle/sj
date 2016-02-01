#!/usr/bin/env lua
require('strict')
local posix = require('posix')
local lom = require('lxp.lom')

-- main
local pid = posix.getpid().pid
local sj_dir = assert(os.getenv('SJ_DIR'))
local path_out = sj_dir .. '/in'
local file_out = assert(io.open(path_out, 'w'))

local s_out = string.format(
	[[<iq type='get' id='roster-%d'><query xmlns='jabber:iq:roster'/></iq>]],
	pid)
file_out:write(s_out)
file_out:close()

posix.sleep(1)

--pid = 777
local path_in = sj_dir .. '/roster-' .. pid

local file_in = assert(io.open(path_in, 'r'))
local contents = assert(file_in:read('*a'))
assert(file_in:close())
-- assert(posix.unlink(path_in))

local tab = lom.parse(contents)
--print(table.tostringFull(tab))
assert(tab.tag == 'iq' and tab[1].tag == 'query')
for i = 1, #tab[1] do
	assert(tab[1][i].tag == 'item')
	local buddy = tab[1][i].attr
	local jid = buddy.jid
	local sub = buddy.subscription
	local name = buddy.name or ""
	print(string.format('%-30s  %-6s  %s', jid, sub, name))
end
