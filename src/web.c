/*
    TE4 - T-Engine 4
    Copyright (C) 2009 - 2014 Nicolas Casalini

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

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "core_lua.h"
#include "tSDL.h"
#include "types.h"
#include "main.h"
#include "te4web.h"
#include "web/web-external.h"
#include "lua_externs.h"

/*
 * Grab web browser methods -- availabe only here
 */
static bool webcore = FALSE;
static void (*te4_web_setup)(int argc, char **argv);
static void (*te4_web_initialize)();
static void (*te4_web_do_update)(void (*cb)(WebEvent*));
static void (*te4_web_new)(web_view_type *view, const char *url, int w, int h);
static bool (*te4_web_close)(web_view_type *view);
static void (*te4_web_toscreen)(web_view_type *view, int x, int y, int w, int h);
static bool (*te4_web_loading)(web_view_type *view);
static void (*te4_web_focus)(web_view_type *view, bool focus);
static void (*te4_web_inject_mouse_move)(web_view_type *view, int x, int y);
static void (*te4_web_inject_mouse_wheel)(web_view_type *view, int x, int y);
static void (*te4_web_inject_mouse_button)(web_view_type *view, int kind, bool up);
static void (*te4_web_inject_key)(web_view_type *view, int scancode, bool up);
static void (*te4_web_download_action)(web_view_type *view, long id, const char *path);

void te4_web_load() {
	void *web = SDL_LoadObject("libte4-web.so");
	printf("Loading web core: %s\n", web ? "loaded!" : SDL_GetError());

	if (web) {
		webcore = TRUE;
		te4_web_setup = (void (*)(int, char**)) SDL_LoadFunction(web, "te4_web_setup");
		te4_web_initialize = (void (*)()) SDL_LoadFunction(web, "te4_web_initialize");
		te4_web_do_update = (void (*)(void (*cb)(WebEvent*))) SDL_LoadFunction(web, "te4_web_do_update");
		te4_web_new = (void (*)(web_view_type *view, const char *url, int w, int h)) SDL_LoadFunction(web, "te4_web_new");
		te4_web_close = (bool (*)(web_view_type *view)) SDL_LoadFunction(web, "te4_web_close");
		te4_web_toscreen = (void (*)(web_view_type *view, int x, int y, int w, int h)) SDL_LoadFunction(web, "te4_web_toscreen");
		te4_web_loading = (bool (*)(web_view_type *view)) SDL_LoadFunction(web, "te4_web_loading");
		te4_web_focus = (void (*)(web_view_type *view, bool focus)) SDL_LoadFunction(web, "te4_web_focus");
		te4_web_inject_mouse_move = (void (*)(web_view_type *view, int x, int y)) SDL_LoadFunction(web, "te4_web_inject_mouse_move");
		te4_web_inject_mouse_wheel = (void (*)(web_view_type *view, int x, int y)) SDL_LoadFunction(web, "te4_web_inject_mouse_wheel");
		te4_web_inject_mouse_button = (void (*)(web_view_type *view, int kind, bool up)) SDL_LoadFunction(web, "te4_web_inject_mouse_button");
		te4_web_inject_key = (void (*)(web_view_type *view, int scancode, bool up)) SDL_LoadFunction(web, "te4_web_inject_key");
		te4_web_download_action = (void (*)(web_view_type *view, long id, const char *path)) SDL_LoadFunction(web, "te4_web_download_action");

		te4_web_setup(g_argc, g_argv);
	}
}

static int lua_web_new(lua_State *L) {
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
	const char* url = luaL_checkstring(L, 3);

	web_view_type *view = (web_view_type*)lua_newuserdata(L, sizeof(web_view_type));
	auxiliar_setclass(L, "web{view}", -1);

	lua_pushvalue(L, 4);
	view->handlers = luaL_ref(L, LUA_REGISTRYINDEX);

	te4_web_new(view, url, w, h);

	return 1;
}

static int lua_web_close(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (!te4_web_close(view)) {
		luaL_unref(L, LUA_REGISTRYINDEX, view->handlers);
	}
	return 0;
}

static int lua_web_toscreen(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int w = -1;
	int h = -1;
	if (lua_isnumber(L, 4)) w = lua_tonumber(L, 4);
	if (lua_isnumber(L, 5)) h = lua_tonumber(L, 5);

	te4_web_toscreen(view, x, y, w, h);
	return 0;
}

static int lua_web_loading(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);

	lua_pushboolean(L, te4_web_loading(view));
	return 1;
}

static int lua_web_focus(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	te4_web_focus(view, lua_toboolean(L, 2));
	return 0;
}

static int lua_web_inject_mouse_move(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);

	te4_web_inject_mouse_move(view, x, y);
	return 0;
}

static int lua_web_inject_mouse_wheel(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);

	te4_web_inject_mouse_wheel(view, x, y);
	return 0;
}

static int lua_web_inject_mouse_button(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	bool up = lua_toboolean(L, 2);
	int kind = luaL_checknumber(L, 3);

	te4_web_inject_mouse_button(view, kind, up);
	return 0;
}

static int lua_web_inject_key(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	bool up = lua_toboolean(L, 2);
	int scancode = lua_tonumber(L, 3);

	te4_web_inject_key(view, scancode, up);
	return 0;
}

static int lua_web_download_action(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	long id = lua_tonumber(L, 2);
	if (lua_isstring(L, 3)) te4_web_download_action(view, id, lua_tostring(L, 3));
	else te4_web_download_action(view, id, NULL);
	return 0;
}

static const struct luaL_Reg view_reg[] =
{
	{"__gc", lua_web_close},
	{"downloadAction", lua_web_download_action},
	{"toScreen", lua_web_toscreen},
	{"focus", lua_web_focus},
	{"loading", lua_web_loading},
	{"injectMouseMove", lua_web_inject_mouse_move},
	{"injectMouseWheel", lua_web_inject_mouse_wheel},
	{"injectMouseButton", lua_web_inject_mouse_button},
	{"injectKey", lua_web_inject_key},
//	{"setMethod", lua_web_set_method},
	{NULL, NULL},
};

static const struct luaL_Reg weblib[] =
{
	{"new", lua_web_new},
	{NULL, NULL},
};

static lua_State *he_L;
static void handle_event(WebEvent *event) {
	switch (event->kind) {
		case TE4_WEB_EVENT_TITLE_CHANGE:
			lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
			lua_pushstring(he_L, "on_title");
			lua_gettable(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
				lua_pushstring(he_L, event->data.title);
				docall(he_L, 2, 0);
			} else lua_pop(he_L, 1);
			
			free((void*)event->data.title);
			break;

		case TE4_WEB_EVENT_REQUEST_POPUP_URL:
			lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
			lua_pushstring(he_L, "on_popup");
			lua_gettable(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
				lua_pushstring(he_L, event->data.popup.url);
				lua_pushnumber(he_L, event->data.popup.w);
				lua_pushnumber(he_L, event->data.popup.h);
				docall(he_L, 4, 0);
			} else lua_pop(he_L, 1);
			
			free((void*)event->data.popup.url);
			break;

		case TE4_WEB_EVENT_DOWNLOAD_REQUEST:
			lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
			lua_pushstring(he_L, "on_download_request");
			lua_gettable(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
				lua_pushnumber(he_L, event->data.download_request.id);
				lua_pushstring(he_L, event->data.download_request.url);
				lua_pushstring(he_L, event->data.download_request.name);
				lua_pushstring(he_L, event->data.download_request.mime);
				docall(he_L, 5, 0);
			} else lua_pop(he_L, 1);
			
			free((void*)event->data.download_request.url);
			free((void*)event->data.download_request.name);
			free((void*)event->data.download_request.mime);
			break;

		case TE4_WEB_EVENT_DOWNLOAD_UPDATE:
			lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
			lua_pushstring(he_L, "on_download_update");
			lua_gettable(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
				lua_pushnumber(he_L, event->data.download_update.id);
				lua_pushnumber(he_L, event->data.download_update.got);
				lua_pushnumber(he_L, event->data.download_update.total);
				lua_pushnumber(he_L, event->data.download_update.percent);
				lua_pushnumber(he_L, event->data.download_update.speed);
				docall(he_L, 6, 0);
			} else lua_pop(he_L, 1);
			break;
	}
}

void te4_web_update(lua_State *L) {
	if (webcore) {
		he_L = L;
		te4_web_do_update(handle_event);
	}
}

void te4_web_init(lua_State *L) {
	if (!webcore) return;

	te4_web_initialize();

	auxiliar_newclass(L, "web{view}", view_reg);
//	auxiliar_newclass(L, "web{downloader}", downloader_reg);
	luaL_openlib(L, "core.webview", weblib, 0);
	lua_settop(L, 0);
}