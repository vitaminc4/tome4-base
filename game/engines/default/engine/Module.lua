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
local Dialog = require "engine.ui.Dialog"
local Savefile = require "engine.Savefile"
require "engine.PlayerProfile"

--- Handles dialog windows
module(..., package.seeall, class.make)

--- Create a version string for the module version
-- Static
function _M:versionString(mod)
	return ("%s-%d.%d.%d"):format(mod.short_name, mod.version[1], mod.version[2], mod.version[3])
end

--- List all available modules
-- Static
function _M:listModules()
	local ms = {}
	fs.mount(engine.homepath, "/")
--	print("Search Path: ") for k,e in ipairs(fs.getSearchPath()) do print("*",k,e) end

	local knowns = {}
	for i, short_name in ipairs(fs.list("/modules/")) do
		local mod = self:createModule(short_name)
		if mod then
			if not knowns[mod.short_name] then
				table.insert(ms, {short_name=mod.short_name, name=mod.name, versions={}})
				knowns[mod.short_name] = ms[#ms]
			end
			local v = knowns[mod.short_name].versions
			v[#v+1] = mod
		end
	end

	table.sort(ms, function(a, b)
	print(a.short_name,b.short_name)
		if a.short_name == "tome" then return 1
		elseif b.short_name == "tome" then return nil
		else return a.name < b.name
		end
	end)

	for i, m in ipairs(ms) do
		table.sort(m.versions, function(b, a)
			return a.version[1] * 1000000 + a.version[2] * 1000 + a.version[3] * 1 < b.version[1] * 1000000 + b.version[2] * 1000 + b.version[3] * 1
		end)
		print("* Module: "..m.short_name)
		for i, mod in ipairs(m.versions) do
			print(" ** "..mod.version[1].."."..mod.version[2].."."..mod.version[3])
			ms[mod.version_string] = mod
		end
		ms[m.short_name] = m.versions[1]
	end
--	fs.umount(engine.homepath)

	return ms
end

function _M:createModule(short_name)
	local dir = "/modules/"..short_name
	print("Creating module", short_name, ":: (as dir)", fs.exists(dir.."/init.lua"), ":: (as team)", short_name:find(".team$"), "")
	if fs.exists(dir.."/init.lua") then
		local mod = self:loadDefinition(dir)
		if mod and mod.short_name then
			return mod
		end
	elseif short_name:find(".team$") then
		fs.mount(fs.getRealPath(dir), "/testload", false)
		local mod
		if fs.exists("/testload/mod/init.lua") then
			mod = self:loadDefinition("/testload", dir)
		end
		fs.umount(fs.getRealPath(dir))
		if mod and mod.short_name then return mod end
	end
end

--- Get a module definition from the module init.lua file
function _M:loadDefinition(dir, team)
	local mod_def = loadfile(team and (dir.."/mod/init.lua") or (dir.."/init.lua"))
--	print("Loading module definition from", team and (dir.."/mod/init.lua") or (dir.."/init.lua"))
	if mod_def then
		-- Call the file body inside its own private environment
		local mod = {}
		setfenv(mod_def, mod)
		mod_def()

		if not mod.long_name or not mod.name or not mod.short_name or not mod.version or not mod.starter then
			print("Bad module definition", mod.long_name, mod.name, mod.short_name, mod.version, mod.starter)
			return
		end

		-- Test engine version
		local eng_req = engine.version_string(mod.engine)
		mod.version_string = self:versionString(mod)
		if not __available_engines.__byname[eng_req] then
			print("Module mismatch engine version "..mod.version_string.." using engine "..eng_req)
			return
		end

		-- Make a function to activate it
		mod.load = function(mode)
			if mode == "setup" then
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
			elseif mode == "init" then
				local m = require(mod.starter)
				m[1].__session_time_played_start = os.time()
				m[1].__mod_info = mod
				print("[MODULE LOADER] loading module", mod.long_name, "["..mod.starter.."]", "::", m[1] and m[1].__CLASSNAME, m[2] and m[2].__CLASSNAME)
				return m[1], m[2]
			end
		end

		print("Loaded module definition for "..mod.version_string.." using engine "..eng_req)
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

--- Instanciate the given module, loading it and creating a new game / loading an existing one
-- @param mod the module definition as given by Module:loadDefinition()
-- @param name the savefile name
-- @param new_game true if the game must be created (aka new character)
function _M:instanciate(mod, name, new_game, no_reboot)
	if not no_reboot then
		local popup = Dialog:simplePopup("Loading module", "Please wait while loading "..mod.long_name.."...", nil, true)
		popup.__showup = nil
		core.display.forceRedraw()

		util.showMainMenu(false, mod.engine[4], ("%d.%d.%d"):format(mod.engine[1], mod.engine[2], mod.engine[3]), mod.version_string, name, new_game)
		return
	end

	if mod.short_name == "boot" then profile.hash_valid = true end

	mod.version_name = ("%s-%d.%d.%d"):format(mod.short_name, mod.version[1], mod.version[2], mod.version[3])

	profile.generic.modules_loaded = profile.generic.modules_loaded or {}
	profile.generic.modules_loaded[mod.short_name] = (profile.generic.modules_loaded[mod.short_name] or 0) + 1

	profile:saveGenericProfile("modules_loaded", profile.generic.modules_loaded)

	-- Turn based by default
	core.game.setRealtime(0)

	-- Init the module directories
	mod.load("setup")

	-- Check MD5sum with the server
	local md5 = require "md5"
	local md5s = {}
	local function fp(dir)
		for i, file in ipairs(fs.list(dir)) do
			local f = dir.."/"..file
			if fs.isdir(f) then
				fp(f)
			elseif f:find("%.lua$") then
				local fff = fs.open(f, "r")
				if fff then
					local data = fff:read(10485760)
					md5s[#md5s+1] = f..":"..md5.sumhexa(data)
					fff:close()
				end
			end
		end
	end
	local t = core.game.getTime()
	fp("/mod")
	fp("/data")
	fp("/engine")
	table.sort(md5s)
	local fmd5 = md5.sumhexa(table.concat(md5s))
	print("[MODULE LOADER] module MD5", fmd5, "computed in ", core.game.getTime() - t)
	local hash_valid, hash_err = profile:checkModuleHash(mod.version_name, fmd5)

	-- If bad hash, switch to dev profile
	if not hash_valid then
		print("[PROFILE] switching to dev profile")
		_G.profile = engine.PlayerProfile.new("dev")
	end
	profile:loadModuleProfile(mod.short_name)

	-- Init the module code
	local M, W = mod.load("init")
	_G.game = M.new()
	_G.game:setPlayerName(name)

	-- Load the world, or make a new one
	if W then
		local save = Savefile.new("")
		_G.world = save:loadWorld()
		save:close()
		if not _G.world then
			_G.world = W.new()
		end
		_G.world:run()
	end

	-- Load the savefile if it exists, or create a new one if not (or if requested)
	local save = engine.Savefile.new(_G.game.save_name)
	if save:check() and not new_game then
		_G.game = save:loadGame()
	else
		save:delete()
	end
	save:close()

	-- And now run it!
	_G.game:run()

	-- Disable the profile if ungood
	if mod.short_name ~= "boot" then
		if not hash_valid then
			game.log("#LIGHT_RED#Profile disabled(switching to development profile) due to %s.", hash_err)
		end
	end
end

--- Setup write dir for a module
-- Static
function _M:setupWrite(mod)
	-- Create module directory
	fs.setWritePath(engine.homepath)
	fs.mkdir(mod.short_name)
	fs.mkdir(mod.short_name.."/save")

	-- Enter module directory
	local base = engine.homepath .. fs.getPathSeparator() .. mod.short_name
	fs.setWritePath(base)
	fs.mount(base, "/", false)
	return base
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
