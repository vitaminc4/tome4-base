-- ToME - Tales of Middle-Earth
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

setStatusAll{no_teleport=true}

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

startx = 0
starty = 5

defineTile(' ', "FLOOR")
defineTile('^', "FLOOR", nil, nil, {random_filter={add_levels=5}})
defineTile('+', "DOOR")
defineTile('#', "HARDWALL")

defineTile('a', 'FLOOR', nil, {random_filter={name='hill orc archer', add_levels=15}})
defineTile('i', 'FLOOR', nil, {random_filter={name='icy wyrmic uruk-hai', add_levels=10}}) -- will be generated with escorts, so leave some space free
defineTile('f', 'FLOOR', nil, {random_filter={name='fiery wyrmic uruk-hai', add_levels=10}}) -- will be generated with escorts, so leave some space free
defineTile('o', 'FLOOR', nil, {random_filter={name='uruk-hai', add_levels=10}})
defineTile('O', 'FLOOR', nil, {random_filter={name='uruk-hai', add_levels=20}})
defineTile('n', 'FLOOR', nil, {random_filter={name='orc master assassin', add_levels=10}})
defineTile('N', 'FLOOR', nil, {random_filter={name='orc grand master assassin', add_levels=15}})

defineTile('m', 'FLOOR', {random_filter={type='weapon', subtype='mace', add_levels=10}})
defineTile('M', 'FLOOR', {random_filter={type='weapon', subtype='greatmaul', add_levels=10}})

defineTile('x', 'FLOOR', {random_filter={type='weapon', subtype='axe', add_levels=10}})
defineTile('X', 'FLOOR', {random_filter={type='weapon', subtype='battleaxe', add_levels=10}})

defineTile('s', 'FLOOR', {random_filter={type='weapon', subtype='sword', add_levels=10}})
defineTile('S', 'FLOOR', {random_filter={type='weapon', subtype='greatsword', add_levels=10}})

defineTile('b', 'FLOOR', {random_filter={type='weapon', subtype='longbow', add_levels=10}})
defineTile('B', 'FLOOR', {random_filter={type='ammo', subtype='arrow', add_levels=10}})

defineTile('w', 'FLOOR', {random_filter={type='weapon', subtype='sling', add_levels=10}})
defineTile('W', 'FLOOR', {random_filter={type='ammo', subtype='shot', add_levels=10}})

defineTile('k', 'FLOOR', {random_filter={type='weapon', subtype='knife', add_levels=10}})

defineTile('t', 'FLOOR', {random_filter={type='weapon', subtype='mace', add_levels=10}}, {random_filter={type='giant', subtype='troll', add_levels=10}})
defineTile('T', 'FLOOR', {random_filter={type='weapon', subtype='greatmaul', add_levels=10}}, {random_filter={type='giant', subtype='troll', add_levels=15}})

return {

[[#########################]],
[[##aa#ooo+xx#BBBB#OOO#knk#]],
[[##  #oOo#xx###bb+ f #nNn#]],
[[##  #oOo#XXXX#bb#   #knk#]],
[[##^^##+###########+###+##]],
[[+ ^^                   ^#]],
[[##^^##+###########+###+##]],
[[##  #OoO#SSSS#ww#   #TtT#]],
[[##  #ooo#ss###ww+ i #ttt#]],
[[##aa#ooo+ss#WWWW#OOO#TtT#]],
[[#########################]],

}
