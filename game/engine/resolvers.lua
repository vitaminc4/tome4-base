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

resolvers = {}
resolvers.calc = {}

--- Resolves a rng range
function resolvers.rngrange(x, y)
	return {__resolver="rngrange", x, y}
end
function resolvers.calc.rngrange(t)
	return rng.range(t[1], t[2])
end

--- Average random
function resolvers.rngavg(x, y)
	return {__resolver="rngavg", x, y}
end
function resolvers.calc.rngavg(t)
	return rng.avg(t[1], t[2])
end

--- Random bonus based on level
resolvers.current_level = 1
function resolvers.mbonus(max, add)
	return {__resolver="mbonus", max, add}
end
function resolvers.calc.mbonus(t)
	return rng.mbonus(t[1], resolvers.current_level, 50) + (t[2] or 0)
end

--- Talents resolver
function resolvers.talents(list)
	return {__resolver="talents", list}
end
function resolvers.calc.talents(t, e)
	for tid, level in pairs(t[1]) do e:learnTalent(tid, true, level) end
	return nil
end

--- Talents masteries
function resolvers.tmasteries(list)
	return {__resolver="tmasteries", list}
end
function resolvers.calc.tmasteries(t, e)
	local ts = {}
	for tt, level in pairs(t[1]) do
		assert(e.talents_types_def[tt], "unknown talent type "..tt)
		e.talents_types[tt] = true
		e.talents_types_mastery[tt] = level
	end
	return nil
end

--- Generic resolver, takes a function
function resolvers.generic(fct)
	return {__resolver="generic", fct}
end
function resolvers.calc.generic(t, e)
	return t[1](e)
end
