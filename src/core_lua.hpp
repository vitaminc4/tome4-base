/*
	TE4 - T-Engine 4
	Copyright (C) 2009 - 2018 Nicolas Casalini

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	Nicolas Casalini "DarkGod"
	darkgod@te4.org
*/
#ifndef _CORELUA_H_
#define _CORELUA_H_

extern "C" {
#include "tgl.h"
#include "tSDL.h"
}

typedef struct
{
	GLuint fbo;
	GLuint *textures;
	GLenum *buffers;
	int nbt;
	int w, h;
} lua_fbo;

typedef struct
{
	int nb, size;
	GLfloat *vertices;
	GLfloat *colors;
	GLfloat *textures;
} lua_vertexes;

extern int luaopen_core_gamepad(lua_State *L);
extern int luaopen_core_mouse(lua_State *L);
extern int luaopen_core(lua_State *L);
extern int init_blank_surface();
extern void mouse_draw_drag();
extern GLenum sdl_gl_texture_format(SDL_Surface *s);

#endif
