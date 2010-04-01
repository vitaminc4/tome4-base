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

quickEntity('b', {show_tooltip=true, name='blue mountains', display='^', color=colors.LIGHT_BLUE, image="terrain/mountain.png", block_move=true})
quickEntity('m', {show_tooltip=true, name='misty mountains', display='^', color=colors.UMBER, image="terrain/mountain.png", block_move=true})
quickEntity('g', {show_tooltip=true, name='grey mountains', display='^', color=colors.SLATE, image="terrain/mountain.png", block_move=true})
quickEntity('u', {show_tooltip=true, name='deep forest', display='#', color=colors.GREEN, image="terrain/tree.png", block_move=true})
quickEntity('t', {show_tooltip=true, name='forest', display='#', color=colors.LIGHT_GREEN, image="terrain/tree.png", block_move=true})
quickEntity('v', {show_tooltip=true, name='old forest', display='#', color=colors.GREEN, image="terrain/tree_dark1.png", block_move=true})
quickEntity('i', {show_tooltip=true, name='iron mountains', display='^', color=colors.SLATE, image="terrain/mountain.png", block_move=true})
quickEntity('=', {show_tooltip=true, name='the great sea', display='~', color=colors.BLUE, image="terrain/river.png", block_move=true})
quickEntity('.', {show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png", equilibrium_level=-10})
quickEntity('g', {show_tooltip=true, name='Forodwaith, the cold lands', display='.', color=colors.LIGHT_BLUE, equilibrium_level=-10})
quickEntity('q', {show_tooltip=true, name='Icebay of Forochel', display=';', color=colors.LIGHT_BLUE, equilibrium_level=-10})
quickEntity('w', {show_tooltip=true, name='ash', display='.', color=colors.WHITE})
quickEntity('&', {show_tooltip=true, name='hills', display='^', color=colors.GREEN, image="terrain/hills.png", equilibrium_level=-10})
quickEntity('h', {show_tooltip=true, name='low hills', display='^', color=colors.GREEN, image="terrain/hills.png", equilibrium_level=-10})
quickEntity(' ', {show_tooltip=true, name='sea of Rhun', display='~', color=colors.BLUE, image="terrain/river.png", block_move=true})
quickEntity('_', {show_tooltip=true, name='river', display='~', color={r=0, g=80, b=255}, image="terrain/river.png", equilibrium_level=-10})
quickEntity('~', {show_tooltip=true, name='Anduin river', display='~', color={r=0, g=30, b=255}, image="terrain/river.png", equilibrium_level=-10})
quickEntity('-', {show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png", equilibrium_level=-10})
quickEntity('|', {show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png", equilibrium_level=-10})
quickEntity('x', {show_tooltip=true, name='plains', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png", equilibrium_level=-10})

quickEntity('A', {show_tooltip=true, name="Caves below the tower of Amon Sûl", 	display='>', color={r=0, g=255, b=255}, change_level=1, change_zone="tower-amon-sul"})
quickEntity('B', {show_tooltip=true, name="Passageway into the Trollshaws", 	display='>', color={r=0, g=255, b=0}, change_level=1, change_zone="trollshaws"})
quickEntity('C', {show_tooltip=true, name="A gate into a maze", 			display='>', color={r=0, g=255, b=255}, change_level=1, change_zone="maze"})
quickEntity('D', {show_tooltip=true, name="A path into the Old Forest", 		display='>', color={r=0, g=255, b=155}, change_level=1, change_zone="old-forest"})
quickEntity('E', {show_tooltip=true, name="A mysterious hole in the beach", 	display='>', color={r=200, g=255, b=55}, change_level=1, change_zone="sandworm-lair"})
quickEntity('F', {show_tooltip=true, name="The entry to the old tower of Tol Falas",display='>', color={r=0, g=255, b=255}, change_level=1, change_zone="tol-falas"})

quickEntity('1', {show_tooltip=true, name="Bree (Town)", desc="A quiet town at the crossroads of the north", display='*', color={r=255, g=255, b=255}, change_level=1, change_zone="town-bree"})
quickEntity('2', {show_tooltip=true, name="Minas Tirith (Town)", desc="Captical city of the Reunited-Kingdom and Gondor ruled by High King Eldarion", display='*', color={r=255, g=255, b=255}, change_level=1, change_zone="town-minas-tirith"})

return {
[[========q=qqqqqqqqqgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[=========q=qq=qqqqggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[==========qq=q=qqqqgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[==============qqq=qqggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[===============q=q=q=gwwwwgggwwwwwgggggggggwwwwwwwwwwggggwwwwwwwwwwwwwggggwwwwwwwwggggwwwwwwwwwgggg]],
[[====================qwwwwwwwwwwwwwwwwggggggggwwwwwwwwwwwwwwwwwwwwwwwwwwggwwwwwwwwwwwwwwwwwwwwwwuuuu]],
[[======================wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww.uuuuuuuu]],
[[========================wwwwwwww...wwwwwwwwww..........wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww.uuuuuuuuuuu]],
[[========================..www....wwwwwwww................wwwwffffwwwwwwww......wwwww.uuuuuuuuuuuuuu]],
[[==========.......======.........hhhh..................fffffffwwwdwwww.........wwww.utuuuutuuuuuutuu]],
[[========......bb..===.........hhhhhhhh..&&&&&...&..fffffffffffff.................tuuututuututtuuuut]],
[[=======......bb..===............hhhh.......&&&&&&ff.._._...........................tttttttttttttttt]],
[[======...._.bb._..._............................m....._._uuu................ii........ttttttttttttt]],
[[=======.._..bb.._.._..hhhh................&....&mm~~~~.uu_uuuu..........i.....iii........tttttt^^^^]],
[[======.._...bb..._._..hhh.......hhhhhh.....&&&&._mm..~.uuu_u_uu..^l......iiiiii..............ttt^^^]],
[[=====.._..ubbb...._._..h.=....hhh.hh..........__.mm__~.uuuu_h_uu.l8........_.....................^^]],
[[===...._....bb....._..hh.=_....h............__...mm..~.uuuuuu_uu.=........_........................]],
[[====.._...bbbb...._....hhhh__..........A..._.....mm..~.uuuuuu____........._........................]],
[[=====.._..uubb..._........._......h......._Btt...mm..~6uuuuu&&&u._........._.......................]],
[[====...__..ubbb._......hh.._.......hh...._.t^^^._mm..~..uuu&f&&&u._........._......................]],
[[=====..._.....__......hho.-_......1hh......._L...mm..~..uuuuuuuuu._........_.......................]],
[[======..==..=__....h....h..._.hh..ih....._..^^^._m...~..uuuuuuuuuu._........_......................]],
[[=============.....hhh......._.vvD.h......_.._.._mmm...~..uuuuuuuuu.._........_....................t]],
[[======........bb...h........._vvv.hh...._.._...mm.....~..uuuuuuuu...._......_....................tt]],
[[=====E........bb............._.v...h...._._..mmmmm.s._~..uuuuuuuu....._......_..................ttt]],
[[=====.........bb............._........._.._..mmmm___s.~~.uuuuuuuu......_.._._..................tttt]],
[[======........bb...Cb......._.........._._...mmmm.....~~.uuuuu.u........._.._.................ttttt]],
[[=======.....ubbb..bbbb....._..........._....mmmmm....~~...uuuu.............._...............ttttttt]],
[[==========..ubbbu........._..........._.....mmmm.....~~...uuuu..............._...._.......ttttttttt]],
[[==========..uuubbubb....._........ss__.....hmmmm....~~....uuuuuuu............._.__._ ...ttttttttttt]],
[[==========...uubuu......_........___ss_....mmmmm....~~..uuuuuuuuuu............._....  ...t  ttttttt]],
[[==========.....u.u....._........_.....______mm___...~~.uuuuuuuuuu...................        ttttttt]],
[[===========.=........._........_...........mmmm_!!!~~..uu&uuuuuuu..................         ttttttt]],
[[================....__........_..ttt......mmmm._!!!~~..uuuuuuuuu...................         ...tttt]],
[[=================.==t........_....tt.....ttmmm.!!!!~.....uuuuu..................^^.        ......tt]],
[[===================tt........._.........ttmmm.......~~.........................^^^^.       .......t]],
[[===================t==......._..........ttmmmttttt._..~~~~~~....................^^^.  ...  .......t]],
[[===================t==......_...........t&mmmmtttt_s_.....~~~..................^^^^^. ... ........t]],
[[=====================......_.ttt........t&mmmtttttt..__s~~~~...................^^^^^^.............t]],
[[=====================.....=_.tt.........&&mmmttttt.....~...........................^^.............t]],
[[======================...==..ttt........&&_&&&.._.......~~........................................t]],
[[=======================.===..............^_^....._........~.......................................t]],
[[===========================..............._........_.....~........................................t]],
[[==========================.tt......._._.._........_....h=hh...SSS.................................t]],
[[==========================.tt._.._t_...__.........._..h===h.SSSS.................................tt]],
[[==========================..__.__._._._..&&&b....._....h=hh..SS.a.a.............................ttt]],
[[============================....._..._.__.&&&......_....~~.....aakaaa..a..aa..a..a..aa...a.....tttt]],
[[===========================.............._&&&^^....._....~~s...ddvvaaaaaaaaaaaaaaaaaaaaaaaaaaaaJttt]],
[[===========================.......^.&.^^&&&&&&&......__.~~sss...ddvvvvvvvavvvavaa_"""_""""""..aaatt]],
[[===========================.....^^.&.&_&^&.&^&_&&&9...._..~~ss..ddvvmvvvvvvvvvva_"""""_""""""...aat]],
[[===========================....^....__^^...^^^._^&&........~~.c.ddvvmmvvvvvvvaa_"""""""_"""".....aa]],
[[===========================..^^^_.._.......^^._.^^&&&........~~.ddvvvvvvvvvvaa""_""""""_"""""""....]],
[[============================.^t_.__._........_&^^^.&&&&&......e.ddvaavaaavvv"""""_""""_""""""".....]],
[[============================.t^_..._....hh.._&&&^^.._&&&&.&...~.ddd""a"a""""""""=="""_""""""""""...]],
[[============================.t^._.hhhhhhhh...__...._^&^&&&&&.~..dd""""""""""""======_"""""""""""aaa]],
[[===========================.^^._...h.h........._.._.^&^^._^2.~..dd"""_"_"""""=====""""""""""""aaadd]],
[[==========================..^^.._.....===.=====_._&^...._...^.~.dd"__"_"__======"""""aa""""aaaadddd]],
[[==========================.h...._...=====F=====_&&^...._._...~~.dd_""""""""""""_""a"aaaaaaaaddddddd]],
[[========================.hhh=...=_.==========&^^^^.._._..._.~~..ddd""ddd""d"""dd_ddaadddddddddddddd]],
[[======================....=====.==============^.^._=._.....~~...ddddddddddddddddddddddddddddddddddd]],
[[==============================================.^^^==....~~~~....................ddddddddddddddddddd]],
[[===============================================..====~~~p................dddddddddddddddddddddddddd]],
[[===============================================.==^==_............ddddddddddddddddddddddddddddddddd]],
[[=================================================^^===........ddddddddddddddddddddddddddddddddddddd]],
}
