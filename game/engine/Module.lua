-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"
local lanes = require "lanes"

--- Handles dialog windows
module(..., package.seeall, class.make)

--- List all available modules
-- Static
function _M:listModules()
	local ms = {}
	fs.mount(engine.homepath, "/")
--	print("Search Path: ") for k,e in ipairs(fs.getSearchPath()) do print("*",k,e) end

	for i, short_name in ipairs(fs.list("/modules/")) do
--print("!!", short_name)
		local dir = "/modules/"..short_name
		if fs.exists(dir.."/init.lua") then
			local mod = self:loadDefinition(dir)
			if mod then
				table.insert(ms, mod)
				ms[mod.short_name] = mod
			end
		elseif short_name:find(".team$") then
			fs.mount(fs.getRealPath(dir), "/testload", false)
			if fs.exists("/testload/mod/init.lua") then
				local mod = self:loadDefinition("/testload", dir)
				if mod then
					table.insert(ms, mod)
					ms[mod.short_name] = mod
				end
			end
			fs.umount(fs.getRealPath(dir))
		end
	end

	table.sort(ms, function(a, b)
		if a.short_name == "tome" then return 1
		elseif b.short_name == "tome" then return nil
		else return a.name < b.name
		end
	end)
--	fs.umount(engine.homepath)

	return ms
end

--- Get a module definition from the module init.lua file
function _M:loadDefinition(dir, team)
	local mod_def = loadfile(team and (dir.."/mod/init.lua") or (dir.."/init.lua"))
	if mod_def then
		-- Call the file body inside its own private environment
		local mod = {}
		setfenv(mod_def, mod)
		mod_def()

		if not mod.long_name or not mod.name or not mod.short_name or not mod.version or not mod.starter then return end

		-- Test engine version
		if mod.engine[1] * 1000000 + mod.engine[2] * 1000 + mod.engine[3] > engine.version[1] * 1000000 + engine.version[2] * 1000 + engine.version[3] then
			print("Module mismatch engine version", mod.short_name, mod.engine[1] * 1000000 + mod.engine[2] * 1000 + mod.engine[3], engine.version[1] * 1000000 + engine.version[2] * 1000 + engine.version[3])
			return
		end

		-- Make a function to activate it
		mod.load = function()
			core.display.setWindowTitle(mod.long_name)
			self:setupWrite(mod)
			if not team then
				fs.mount(fs.getRealPath(dir), "/mod", false)
				fs.mount(fs.getRealPath(dir).."/data/", "/data", false)
				if fs.exists(dir.."/engine") then fs.mount(fs.getRealPath(dir).."/engine/", "/engine", false) end
			else
				local src = fs.getRealPath(team)

				fs.mount(src, "/", false)
			end
			profile:loadModuleProfile(mod.short_name)
			local m = require(mod.starter)
			print("[MODULE LOADER] loading module", mod.long_name, "["..mod.starter.."]", "::", m[1] and m[1].__CLASSNAME, m[2] and m[2].__CLASSNAME)
			return m[1], m[2]
		end

		return mod
	end
end

--- List all available savefiles
-- Static
function _M:listSavefiles()
--	fs.mount(engine.homepath, "/tmp/listsaves")

	local mods = self:listModules()
	for _, mod in ipairs(mods) do
		local lss = {}
		for i, short_name in ipairs(fs.list("/"..mod.short_name.."/save/")) do
			local dir = "/"..mod.short_name.."/save/"..short_name
			if fs.exists(dir.."/game.teag") then
				local def = self:loadSavefileDescription(dir)
				if def then
					table.insert(lss, def)
				end
			end
		end
		mod.savefiles = lss

		table.sort(lss, function(a, b)
			return a.name < b.name
		end)
	end

--	fs.umount(engine.homepath)

	return mods
end

--- Setup write dir for a module
-- Static
function _M:setupWrite(mod)
	-- Create module directory
	fs.setWritePath(engine.homepath)
	fs.mkdir(mod.short_name)

	-- Enter module directory
	local base = engine.homepath .. fs.getPathSeparator() .. mod.short_name
	fs.setWritePath(base)
	fs.mount(base, "/", false)
end

--- Get a savefile description from the savefile desc.lua file
function _M:loadSavefileDescription(dir)
	local ls_def = loadfile(dir.."/desc.lua")
	if ls_def then
		-- Call the file body inside its own private environment
		local ls = {}
		setfenv(ls_def, ls)
		ls_def()

		if not ls.name or not ls.description then return end
		ls.dir = dir
		return ls
	end
end

--- Loads a list of modules from te4.org/modules.lualist
-- Calling this function starts a background thread, which can be waited on by the returned lina object
-- @param src the url to load the list from, if nil it will default to te4.org
-- @return a linda object (see lua lanes documentation) which should be waited upon like this <code>local mylist = l:receive("moduleslist")</code>. Also returns a thread handle
function _M:loadRemoteList(src)
	local l = lanes.linda()

	function list_handler(src)
		local http = require "socket.http"
		local ltn12 = require "ltn12"

		local t = {}
		print("Downloading modules list from", src)
		http.request{url = src, sink = ltn12.sink.table(t)}
		local f, err = loadstring(table.concat(t))
		if err then
			print("Could not load modules list from ", src, ":", err)
			l:send("moduleslist", {})
			return
		end

		local list = {}
		local dmods = {}
		dmods.installableModule = function (t)
			local ok = true

			if not t.name or not t.long_name or not t.short_name or not t.author then ok = false end

			if ok then
				list[#list+1] = t
			end
		end
		setfenv(f, dmods)
		local ok, err = pcall(f)
		if not ok and err then
			print("Could not read modules list from ", src, ":", err)
			l:send("moduleslist", {})
			return
		end

		for k, e in ipairs(list) do print("[INSTALLABLE MODULE] ", e.name) end

		l:send("moduleslist", list)
	end

	local h = lanes.gen("*", list_handler)(src or "http://te4.org/modules.lualist")
	return l, h
end
