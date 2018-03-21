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

extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "display.h"
#include "types.h"
#include "physfs.h"
#include "physfsrwops.h"
#include "main.h"
}
int donb = 0;
#include "renderer-moderngl/Renderer.hpp"
#include "renderer-moderngl/Physic.hpp"
#include "tinyobjloader/tiny_obj_loader.h"
#include <string>

// Lol or what ? Mingw64 on windows seems to not find it ..
#ifndef M_PI
#define M_PI                3.14159265358979323846
#endif

#define DEBUG_CHECKPARENTS

/*************************************************************************
 ** DisplayObject
 *************************************************************************/
int DisplayObject::weak_registry_ref = LUA_NOREF;
bool DisplayObject::pixel_perfect = true;

DisplayObject::DisplayObject() {
	donb++;
	// printf("+DOs %d\n", donb);
	model = mat4(); color.r = 1; color.g = 1; color.b = 1; color.a = 1;
}
DisplayObject::~DisplayObject() {
	donb--;
	// printf("-DOs %d\n", donb);
	removeFromParent();
	refcleaner(&lua_ref);
	if (tweener) delete tweener;
	tweener = NULL;
	for (int pid = 0; pid < physics.size(); pid++) delete physics[pid];
	physics.clear();
}

void DisplayObject::removeFromParent() {
	if (!parent) return;
	DORContainer *p = dynamic_cast<DORContainer*>(parent);
	if (p) p->remove(this);
}

void DisplayObject::setParent(DisplayObject *parent) {
#ifdef DEBUG_CHECKPARENTS
	if (parent && this->parent && L) {
		lua_pushstring(L, "Setting DO parent when already set");
		lua_error(L);
		return;
	}
#endif
	this->parent = parent;
};

void DisplayObject::setChanged(bool force) {
	DisplayObject *p = this;
	while (p) {
		if (p->stop_parent_recursing) {
			p->changed_children = true;
			if (force) p->changed = true;
			break;
		} else {
			// if (p->changed && !force) return; // Dont bother, the rest of the parents are already marked
			p->changed = true;
		}
		p = p->parent;
#ifdef DEBUG_CHECKPARENTS
		if (p == this && L) {
			lua_pushstring(L, "setChanged recursing in loop");
			lua_error(L);
			return;
		}
#endif
	}
}

void DisplayObject::setSortingChanged() {
	DisplayObject *p = parent;
	while (p) {
		if (p->stop_parent_recursing){
			p->setSortingChanged();
			break;
		}
		p = p->parent;
	}
}

	// printf("%f, %f, %f, %f\n", model[0][0], model[0][1], model[0][2], model[0][3]);
	// printf("%f, %f, %f, %f\n", model[1][0], model[1][1], model[1][2], model[1][3]);
	// printf("%f, %f, %f, %f\n", model[2][0], model[2][1], model[2][2], model[2][3]);
	// printf("%f, %f, %f, %f\n", model[3][0], model[3][1], model[3][2], model[3][3]);

void DisplayObject::recomputeModelMatrix() {
	model = mat4();
	if (pixel_perfect) {
		model = glm::translate(model, glm::vec3(floor(x), floor(y), floor(z)));
	} else {
		model = glm::translate(model, glm::vec3(x, y, z));
	}
	model = glm::rotate(model, rot_x, glm::vec3(1, 0, 0));
	model = glm::rotate(model, rot_y, glm::vec3(0, 1, 0));
	model = glm::rotate(model, rot_z, glm::vec3(0, 0, 1));
	model = glm::scale(model, glm::vec3(scale_x, scale_y, scale_z));
	
	setChanged();
}

recomputematrix DisplayObject::computeParentCompositeMatrix(DisplayObject *stop_at, recomputematrix cur) {
	if (!parent || this == stop_at) return cur;
	recomputematrix p = parent->computeParentCompositeMatrix(stop_at, cur);
	cur.model = p.model * model;
	cur.color = p.color * color;
	cur.visible = p.visible && visible;
	return cur;
}

int DisplayObject::enablePhysic() {
	physics.push_back(new DORPhysic(this));
}

DORPhysic *DisplayObject::getPhysic(int pid) {
	if (!physics.size()) return NULL;
	if (pid < 0 or pid > physics.size()) pid = 0;
	return physics[pid];
}

void DisplayObject::destroyPhysic(int pid) {
	if (pid == -1) {
		for (auto it : physics) delete it;
		physics.clear();
	} else {
		delete physics[pid];
		physics.erase(physics.begin() + pid);
	}
}

void DisplayObject::shown(bool v) {
	if (visible == v) return;
	visible = v;
	setChanged(true);
}

void DisplayObject::setColor(float r, float g, float b, float a) {
	if (r != -1) color.r = r;
	if (g != -1) color.g = g;
	if (b != -1) color.b = b;
	if (a != -1) color.a = a;
	setChanged(true);
}

void DisplayObject::resetModelMatrix() {
	if (z) setSortingChanged();
	x = y = z = 0;
	rot_x = rot_y = rot_z = 0;
	scale_x = scale_y = scale_z = 1;
	recomputeModelMatrix();
}

DORTweener::DORTweener(DisplayObject *d) {
	who = d;
	for (short slot = 0; slot < TweenSlot::MAX; slot++) {
		auto &t = tweens[slot];
		t.time = 0;
		t.on_end_ref = LUA_NOREF;
		t.on_change_ref = LUA_NOREF;
	}
}
DORTweener::~DORTweener() {
	for (short slot = 0; slot < TweenSlot::MAX; slot++) {
		auto &t = tweens[slot];
		refcleaner(&t.on_end_ref);
		refcleaner(&t.on_change_ref);
	}
}

void DORTweener::onKeyframe(float nb_keyframes) {
	if (!nb_keyframes) return;

	bool mat = false, changed = false;
	int nb_tweening = 0;
	for (short slot = 0; slot < TweenSlot::MAX; slot++) {
		auto &t = tweens[slot];
		if (t.time) {
			nb_tweening++;
			t.cur += nb_keyframes / (float)NORMALIZED_FPS;
			if (t.cur > t.time) t.cur = t.time;
			GLfloat val = t.easing(t.from, t.to, t.cur / t.time);
			// printf("=== %f => %f over %f / %f == %f\n", t.from, t.to, t.cur, t.time, val);
			switch (slot) {
				case TweenSlot::TX:
					who->x = val; mat = true;
					break;
				case TweenSlot::TY:
					who->y = val; mat = true;
					break;
				case TweenSlot::TZ:
					who->z = val; mat = true;
					who->setSortingChanged();
					break;
				case TweenSlot::RX:
					who->rot_x = val; mat = true;
					break;
				case TweenSlot::RY:
					who->rot_y = val; mat = true;
					break;
				case TweenSlot::RZ:
					who->rot_z = val; mat = true;
					break;
				case TweenSlot::SX:
					who->scale_x = val; mat = true;
					break;
				case TweenSlot::SY:
					who->scale_y = val; mat = true;
					break;
				case TweenSlot::SZ:
					who->scale_z = val; mat = true;
					break;
				case TweenSlot::R:
					who->color.r = val; changed = true;
					break;
				case TweenSlot::G:
					who->color.g = val; changed = true;
					break;
				case TweenSlot::B:
					who->color.b = val; changed = true;
					break;
				case TweenSlot::A:
					who->color.a = val; changed = true;
					break;
				case TweenSlot::UNI1: {
					DORVertexes *v = dynamic_cast<DORVertexes*>(who);
					if (v && v->shader) {
						tglUseProgramObject(v->shader->shader);
						glUniform1fv(v->tween_uni[0], 1, &val);
						v->tween_uni_val[0] = val;
					}
					break;
				}
				case TweenSlot::UNI2: {
					DORVertexes *v = dynamic_cast<DORVertexes*>(who);
					if (v && v->shader) {
						tglUseProgramObject(v->shader->shader);
						glUniform1fv(v->tween_uni[1], 1, &val);
						v->tween_uni_val[1] = val;
					}
					break;
				}
				case TweenSlot::UNI3: {
					DORVertexes *v = dynamic_cast<DORVertexes*>(who);
					if (v && v->shader) {
						tglUseProgramObject(v->shader->shader);
						glUniform1fv(v->tween_uni[2], 1, &val);
						v->tween_uni_val[2] = val;
					}
					break;
				}
			}

			if (t.on_change_ref != LUA_NOREF) {
				lua_rawgeti(L, LUA_REGISTRYINDEX, DisplayObject::weak_registry_ref);
				lua_rawgeti(L, LUA_REGISTRYINDEX, t.on_change_ref);
				lua_rawgeti(L, -2, who->weak_self_ref);
				lua_pushnumber(L, val);
				lua_call(L, 2, 0);
				lua_pop(L, 1); // the weak registry
			}

			if (t.cur >= t.time) {
				t.time = 0;
				if (t.on_end_ref != LUA_NOREF) {
					lua_rawgeti(L, LUA_REGISTRYINDEX, DisplayObject::weak_registry_ref);
					lua_rawgeti(L, LUA_REGISTRYINDEX, t.on_end_ref);
					lua_rawgeti(L, -2, who->weak_self_ref);
					lua_call(L, 1, 0);
					lua_pop(L, 1); // the weak registry
				}
				// Check time == 0, if it is not it means the on_end callback reassigned the slot, we dont want to touch it then, it's not "us" anymore
				if (!t.time) {
					refcleaner(&t.on_end_ref);
					refcleaner(&t.on_change_ref);
				}
			}
		}
	}
	if (mat) who->recomputeModelMatrix();
	if (changed) who->setChanged(true);
	if (!nb_tweening) {
		killMe();
		return; // Just safety in case something is added later. "delete this" must always be the last thing done
	}
}

float DisplayObject::getDefaultTweenSlotValue(TweenSlot slot) {
	switch (slot) {
		case TweenSlot::TX: return x;
		case TweenSlot::TY: return y;
		case TweenSlot::TZ: return z;
		case TweenSlot::RX: return rot_x;
		case TweenSlot::RY: return rot_y;
		case TweenSlot::RZ: return rot_z;
		case TweenSlot::SX: return scale_x;
		case TweenSlot::SY: return scale_y;
		case TweenSlot::SZ: return scale_z;
		case TweenSlot::R: return color.r;
		case TweenSlot::G: return color.g;
		case TweenSlot::B: return color.b;
		case TweenSlot::A: return color.a;
		case TweenSlot::UNI1: { DORVertexes *v = dynamic_cast<DORVertexes*>(this); if (v && v->shader) return v->tween_uni_val[0]; }
		case TweenSlot::UNI2: { DORVertexes *v = dynamic_cast<DORVertexes*>(this); if (v && v->shader) return v->tween_uni_val[1]; }
		case TweenSlot::UNI3: { DORVertexes *v = dynamic_cast<DORVertexes*>(this); if (v && v->shader) return v->tween_uni_val[2]; }
	}
	return 0;
}

void DORTweener::setTween(TweenSlot slot, easing_ptr easing, float from, float to, float time, int on_end_ref, int on_change_ref) {
	auto &t = tweens[(short)slot];
	t.easing = easing;
	t.from = from;
	t.to = to;
	t.cur = 0;
	t.time = time / (float)NORMALIZED_FPS;
	t.on_end_ref = on_end_ref;
	t.on_change_ref = on_change_ref;
}

void DORTweener::cancelTween(TweenSlot slot) {
	if (slot == TweenSlot::MAX) {
		killMe();
		return; // Just safety in case something is added later. "delete this" must always be the last thing done		
	} else {
		auto &t = tweens[(short)slot];
		t.time = 0;
		refcleaner(&t.on_end_ref);
		refcleaner(&t.on_change_ref);
	}
}

void DORTweener::killMe() {
	who->tweener = NULL;
	IRealtime::killMe();
}

bool DORTweener::hasTween(TweenSlot slot) {
	auto &t = tweens[(short)slot];
	return t.time != 0;
}

bool DisplayObject::hasTween(TweenSlot slot) {
	if (!tweener) return false;
	return tweener->hasTween(slot);
}

void DisplayObject::tween(TweenSlot slot, easing_ptr easing, float from, float to, float time, int on_end_ref, int on_change_ref) {
	// if (to == getDefaultTweenSlotValue(slot)) return; // If we want to go to a value we already have, no need to botehr at all
	if (!tweener) tweener = new DORTweener(this);
	tweener->setTween(slot, easing, from, to, time, on_end_ref, on_change_ref);
}

void DisplayObject::cancelTween(TweenSlot slot) {
	if (!tweener) return;
	tweener->cancelTween(slot);
}


void DisplayObject::translate(float x, float y, float z, bool increment) {
	if (physics.size()) {
		if (!increment) {
			this->z = z;
			for (auto physic : physics) physic->setPos(x, y);
			if (z != this->z) setSortingChanged();
			recomputeModelMatrix();
			return;
		} else {
			increment = false;
		}
	}

	if (increment) {
		this->x += x;
		this->y += y;
		this->z += z;
		if (z) setSortingChanged();
	} else {
		if (z != this->z) setSortingChanged();
		this->x = x;
		this->y = y;
		this->z = z;
	}
	recomputeModelMatrix();
}

void DisplayObject::rotate(float x, float y, float z, bool increment) {
	if (physics.size()) {
		if (!increment) {
			this->rot_x = x;
			this->rot_y = y;
			for (auto physic : physics) physic->setAngle(z);
			recomputeModelMatrix();
			return;
		} else {
			increment = false;
		}
	}

	if (increment) {
		this->rot_x += x;
		this->rot_y += y;
		this->rot_z += z;
	} else {
		this->rot_x = x;
		this->rot_y = y;
		this->rot_z = z;
	}
	recomputeModelMatrix();
}

void DisplayObject::scale(float x, float y, float z, bool increment) {
	if (increment) {
		this->scale_x += x;
		this->scale_y += y;
		this->scale_z += z;
	} else {
		this->scale_x = x;
		this->scale_y = y;
		this->scale_z = z;
	}
	recomputeModelMatrix();
}

void DisplayObject::cloneInto(DisplayObject *into) {
	// into->L = L;

	// No parent
	into->parent = NULL;

	// Clone reference
	if (L && lua_ref) {
		lua_rawgeti(L, LUA_REGISTRYINDEX, lua_ref);
		into->lua_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	}

	into->model = model;
	into->color = color;
	into->visible = visible;
	into->x = x;
	into->y = y;
	into->z = z;
	into->rot_x = rot_x;
	into->rot_y = rot_y;
	into->rot_z = rot_z;
	into->scale_x = scale_x;
	into->scale_y = scale_y;
	into->scale_z = scale_z;

	into->changed = true;
}

/*************************************************************************
 ** DORVertexes
 *************************************************************************/
DORVertexes::~DORVertexes() {
	for (int i = 0; i < DO_MAX_TEX; i++) {
		if (tex_lua_ref[i] != LUA_NOREF && L) refcleaner(&tex_lua_ref[i]);
	}
};

void DORVertexes::setTexture(GLuint tex, int lua_ref, int id) {
	if (id >= DO_MAX_TEX) id = DO_MAX_TEX - 1;
	if (tex_lua_ref[id] != LUA_NOREF && L) refcleaner(&tex_lua_ref[id]);
	this->tex[id] = tex;
	tex_lua_ref[id] = lua_ref;

	for (int i = 0; i < DO_MAX_TEX; i++) {
		if (this->tex[i]) tex_max = i + 1;
	}
}

void DORVertexes::setShader(shader_type *s) {
	shader = s ? s : default_shader;
	tween_uni = {0, 0, 0};
}

void DORVertexes::getShaderUniformTween(const char *uniform, uint8_t pos, float default_val) {
	if (!shader || pos < 0 || pos >= 3) return;
	tween_uni[pos] = glGetUniformLocation(shader->shader, uniform);
	tween_uni_val[pos] = default_val;
}

void DORVertexes::clear() {
	vertices.clear();
	vertices_kind_info.clear();
	vertices_map_info.clear();
	setChanged();
}

void DORVertexes::cloneInto(DisplayObject *_into) {
	DisplayObject::cloneInto(_into);
	DORVertexes *into = dynamic_cast<DORVertexes*>(_into);
	into->vertices.insert(into->vertices.begin(), vertices.begin(), vertices.end());
	into->tex_max = tex_max;
	into->tex = tex;
	into->shader = shader;
	// Clone reference
	for (int i = 0; i < DO_MAX_TEX; i++) {
		if (L && tex_lua_ref[i] != LUA_NOREF) {
			lua_rawgeti(L, LUA_REGISTRYINDEX, tex_lua_ref[i]);
			into->tex_lua_ref[i] = luaL_ref(L, LUA_REGISTRYINDEX);
		}
	}
}

int DORVertexes::addQuad(
		float x1, float y1, float u1, float v1, 
		float x2, float y2, float u2, float v2, 
		float x3, float y3, float u3, float v3, 
		float x4, float y4, float u4, float v4, 
		float r, float g, float b, float a
	) {
	return addQuad(
		x1, y1, 0, u1, v1,
		x2, y2, 0, u2, v2,
		x3, y3, 0, u3, v3,
		x4, y4, 0, u4, v4,
		r, g, b, a
	);
}

int DORVertexes::addQuad(
		float x1, float y1, float z1, float u1, float v1, 
		float x2, float y2, float z2, float u2, float v2, 
		float x3, float y3, float z3, float u3, float v3, 
		float x4, float y4, float z4, float u4, float v4, 
		float r, float g, float b, float a
	) {
	int size = vertices.size();
	if (size + 4 >= vertices.capacity()) {vertices.reserve(vertices.capacity() * 2);}

	// This really shouldnt happend from the lua side as we dont even expose the addQuad version with z positions
	if ((z1 != z2) || (z1 != z3) || (z1 != z4) || (z3 != z4) || (size && (z1 != zflat))) {
		printf("Warning making non flat DORVertexes::addQuad!\n");
		is_zflat = false;
	}
	if (!size) zflat = z1;

	vertices.push_back({{x1, y1, z1, 1}, {u1, v1}, {r, g, b, a}});
	vertices.push_back({{x2, y2, z2, 1}, {u2, v2}, {r, g, b, a}});
	vertices.push_back({{x3, y3, z3, 1}, {u3, v3}, {r, g, b, a}});
	vertices.push_back({{x4, y4, z4, 1}, {u4, v4}, {r, g, b, a}});

	setChanged();
	return 0;
}

int DORVertexes::addQuad(vertex v1, vertex v2, vertex v3, vertex v4) {
	int size = vertices.size();
	if (size + 4 >= vertices.capacity()) {vertices.reserve(vertices.capacity() * 2);}

	// This really shouldnt happend from the lua side as we dont even expose the addQuad version with z positions
	if ((v1.pos.z != v2.pos.z) || (v1.pos.z != v3.pos.z) || (v1.pos.z != v4.pos.z) || (v3.pos.z != v4.pos.z) || (size && (v1.pos.z != zflat))) {
		printf("Warning making non flat DORVertexes::addQuad!\n");
		is_zflat = false;
	}
	if (!size) zflat = v1.pos.z;

	vertices.push_back(v1);
	vertices.push_back(v2);
	vertices.push_back(v3);
	vertices.push_back(v4);

	setChanged();
	return 0;
}

int DORVertexes::addQuadKindInfo(float v1, float v2, float v3, float v4) {
	int size = vertices_kind_info.size();
	if (size + 4 >= vertices_kind_info.capacity()) {vertices_kind_info.reserve(vertices_kind_info.capacity() * 2);}

	vertices_kind_info.push_back({v1});
	vertices_kind_info.push_back({v2});
	vertices_kind_info.push_back({v3});
	vertices_kind_info.push_back({v4});

	setChanged();
	return 0;
}

int DORVertexes::addQuadMapInfo(vertex_map_info v1, vertex_map_info v2, vertex_map_info v3, vertex_map_info v4) {
	int size = vertices_map_info.size();
	if (size + 4 >= vertices_map_info.capacity()) {vertices_map_info.reserve(vertices_map_info.capacity() * 2);}

	vertices_map_info.push_back(v1);
	vertices_map_info.push_back(v2);
	vertices_map_info.push_back(v3);
	vertices_map_info.push_back(v4);

	setChanged();
	return 0;
}

int DORVertexes::addQuadPie(
		float x1, float y1, float x2, float y2,
		float u1, float v1, float u2, float v2,
		float angle,
		float r, float g, float b, float a
	) {
	if (angle < 0) angle = 0;
	else if (angle > 360) angle = 360;
	if (angle == 360) return 0;

	int size = vertices.size();
	if (size + 10 >= vertices.capacity()) {vertices.reserve(vertices.capacity() * 2);}

	if ((size && (0 != zflat))) {
		printf("Warning making non flat DORVertexes::addQuadPie!\n");
		is_zflat = false;
	}
	if (!size) zflat = 0;


	float w = x2 - x1;
	float h = y2 - y1;
	float mw = w / 2, mh = h / 2;
	float xmid = x1 + mw, ymid = y1 + mh;

	float uw = u2 - u1;
	float vh = v2 - v1;
	float mu = uw / 2, mv = vh / 2;
	float umid = u1 + mu, vmid = v1 + mv;

	float scale = cos(M_PI / 4);

	int quadrant = angle / 45;
	float baseangle = (angle + 90) * M_PI / 180;
	// Now we project the circle coordinates on a bounding square thanks to scale
	float c = -cos(baseangle) / scale * mw;
	float s = -sin(baseangle) / scale * mh;
	float cu = -cos(baseangle) / scale * mu;
	float sv = -sin(baseangle) / scale * mv;

	if (quadrant >= 0 && quadrant < 2) {
		// Cover all the left
		vertices.push_back({{x1, y1, 0, 1}, {u1, v1}, {r, g, b, a}});
		vertices.push_back({{xmid, y1, 0, 1}, {umid, v1}, {r, g, b, a}});
		vertices.push_back({{xmid, y2, 0, 1}, {umid, v2}, {r, g, b, a}});
		vertices.push_back({{x1, y2, 0, 1}, {u1, v2}, {r, g, b, a}});
		// Cover bottom right
		vertices.push_back({{xmid, ymid, 0, 1}, {umid, vmid}, {r, g, b, a}});
		vertices.push_back({{x2, ymid, 0, 1}, {u2, vmid}, {r, g, b, a}});
		vertices.push_back({{x2, y2, 0, 1}, {u2, v2}, {r, g, b, a}});
		vertices.push_back({{xmid, y2, 0, 1}, {umid, v2}, {r, g, b, a}});
		// Cover top right
		if (quadrant == 0) {
			vertices.push_back({{xmid + c, y1, 0, 1}, {umid +cu, v1}, {r, g, b, a}});
			vertices.push_back({{x2, y1, 0, 1}, {u2, v1}, {r, g, b, a}});
			vertices.push_back({{x2, ymid, 0, 1}, {u2, vmid}, {r, g, b, a}});
			vertices.push_back({{xmid, ymid, 0, 1}, {umid, vmid}, {r, g, b, a}});
		} else {
			vertices.push_back({{x2, ymid + s, 0, 1}, {u2, vmid + sv}, {r, g, b, a}});
			vertices.push_back({{x2, ymid + s, 0, 1}, {u2, vmid + sv}, {r, g, b, a}});
			vertices.push_back({{x2, ymid, 0, 1}, {u2, vmid}, {r, g, b, a}});
			vertices.push_back({{xmid, ymid, 0, 1}, {umid, vmid}, {r, g, b, a}});
		}
	}
	else if (quadrant >= 2 && quadrant < 4) {
		// Cover all the left
		vertices.push_back({{x1, y1, 0, 1}, {u1, v1}, {r, g, b, a}});
		vertices.push_back({{xmid, y1, 0, 1}, {umid, v1}, {r, g, b, a}});
		vertices.push_back({{xmid, y2, 0, 1}, {umid, v2}, {r, g, b, a}});
		vertices.push_back({{x1, y2, 0, 1}, {u1, v2}, {r, g, b, a}});
		// Cover bottom right
		if (quadrant == 2) {
			vertices.push_back({{xmid, ymid, 0, 1}, {umid, vmid}, {r, g, b, a}});
			vertices.push_back({{x2, ymid + s, 0, 1}, {u2, vmid + sv}, {r, g, b, a}});
			vertices.push_back({{x2, y2, 0, 1}, {u2, v2}, {r, g, b, a}});
			vertices.push_back({{xmid, y2, 0, 1}, {umid, v2}, {r, g, b, a}});
		} else {
			vertices.push_back({{xmid, ymid, 0, 1}, {umid, vmid}, {r, g, b, a}});
			vertices.push_back({{xmid + c, y2, 0, 1}, {umid + cu, v2}, {r, g, b, a}});
			vertices.push_back({{xmid + c, y2, 0, 1}, {umid + cu, v2}, {r, g, b, a}});
			vertices.push_back({{xmid, y2, 0, 1}, {umid, v2}, {r, g, b, a}});

		}
	}
	else if (quadrant >= 4 && quadrant < 6) {
		// Cover top left
		vertices.push_back({{x1, y1, 0, 1}, {u1, v1}, {r, g, b, a}});
		vertices.push_back({{xmid, y1, 0, 1}, {umid, v1}, {r, g, b, a}});
		vertices.push_back({{xmid, ymid, 0, 1}, {umid, vmid}, {r, g, b, a}});
		vertices.push_back({{x1, ymid, 0, 1}, {u1, vmid}, {r, g, b, a}});
		// Cover bottom right
		if (quadrant == 4) {
			vertices.push_back({{x1, ymid, 0, 1}, {u1, vmid}, {r, g, b, a}});
			vertices.push_back({{xmid, ymid, 0, 1}, {umid, vmid}, {r, g, b, a}});
			vertices.push_back({{xmid + c, y2, 0, 1}, {umid + cu, v2}, {r, g, b, a}});
			vertices.push_back({{x1, y2, 0, 1}, {u1, v2}, {r, g, b, a}});
		} else {
			vertices.push_back({{x1, ymid, 0, 1}, {u1, vmid}, {r, g, b, a}});
			vertices.push_back({{xmid, ymid, 0, 1}, {umid, vmid}, {r, g, b, a}});
			vertices.push_back({{x1, ymid + s, 0, 1}, {u1, vmid + sv}, {r, g, b, a}});
			vertices.push_back({{x1, ymid + s, 0, 1}, {u1, vmid + sv}, {r, g, b, a}});
		}
	}
	else if (quadrant >= 6 && quadrant < 8) {
		// Cover top left
		if (quadrant == 6) {
			vertices.push_back({{x1, y1, 0, 1}, {u1, v1}, {r, g, b, a}});
			vertices.push_back({{xmid, y1, 0, 1}, {umid, v1}, {r, g, b, a}});
			vertices.push_back({{xmid, ymid, 0, 1}, {umid, vmid}, {r, g, b, a}});
			vertices.push_back({{x1, ymid + s, 0, 1}, {u1, vmid + sv}, {r, g, b, a}});
		} else {
			vertices.push_back({{xmid + c, y1, 0, 1}, {umid + cu, v1}, {r, g, b, a}});
			vertices.push_back({{xmid, y1, 0, 1}, {umid, v1}, {r, g, b, a}});
			vertices.push_back({{xmid, ymid, 0, 1}, {umid, vmid}, {r, g, b, a}});
			vertices.push_back({{xmid + c, y1, 0, 1}, {umid + cu, v1}, {r, g, b, a}});
		}
	}

	setChanged();
	return 0;
}

int DORVertexes::addPoint(
		float x1, float y1, float z1, float u1, float v1, 
		float r, float g, float b, float a
	) {
	int size = vertices.size();
	if (size + 1 >= vertices.capacity()) {vertices.reserve(vertices.capacity() * 2);}

	// This really shouldnt happend from the lua side as we dont even expose the addQuad version with z positions
	if (size && (z1 != zflat)) {
		printf("Warning making non flat DORVertexes::addQuad!\n");
		is_zflat = false;
	}
	if (!size) zflat = z1;

	vertices.push_back({{x1, y1, z1, 1}, {u1, v1}, {r, g, b, a}});

	setChanged();
	return 0;
}


void CalcNormal(float N[3], float v0[3], float v1[3], float v2[3]) {
	float v10[3];
	v10[0] = v1[0] - v0[0];
	v10[1] = v1[1] - v0[1];
	v10[2] = v1[2] - v0[2];

	float v20[3];
	v20[0] = v2[0] - v0[0];
	v20[1] = v2[1] - v0[1];
	v20[2] = v2[2] - v0[2];

	N[0] = v20[1] * v10[2] - v20[2] * v10[1];
	N[1] = v20[2] * v10[0] - v20[0] * v10[2];
	N[2] = v20[0] * v10[1] - v20[1] * v10[0];

	float len2 = N[0] * N[0] + N[1] * N[1] + N[2] * N[2];
	if (len2 > 0.0f) {
		float len = sqrtf(len2);

		N[0] /= len;
		N[1] /= len;
	}
}

extern "C" GLuint load_image_texture(const char *file);
void DORVertexes::loadObj(const string &filename) {
	if (!PHYSFS_exists(filename.c_str())) {
		printf("[DORVertexes] loadObj: file unknown %s\n", filename.c_str());
		return;
	}
	tinyobj::attrib_t attrib;
	vector<tinyobj::shape_t> shapes;
	vector<tinyobj::material_t> materials;
	string err;

	string prefix = filename.substr(0, filename.find_last_of('/') + 1);
	tinyobj::LoadObj(&attrib, &shapes, &materials, &err, filename.c_str(), prefix.c_str(), true);

	printf("[DORVertexes] loadObj: %s\n", err.c_str());
	printf("# of vertices  = %d\n", (int)(attrib.vertices.size()) / 3);
	printf("# of normals   = %d\n", (int)(attrib.normals.size()) / 3);
	printf("# of texcoords = %d\n", (int)(attrib.texcoords.size()) / 2);
	printf("# of materials = %d\n", (int)materials.size());
	printf("# of shapes    = %d\n", (int)shapes.size());

	// vector<GLuint> materials_diffuses; materials_diffuses.resize(materials.size());
	// int i = 0;
	// for (auto &mat : materials) {
	// 	if (mat.diffuse_texname != "") {
	// 		mat.diffuse_texname = prefix + mat.diffuse_texname;
	// 		string extless = mat.diffuse_texname.substr(0, mat.diffuse_texname.find_last_of('.') + 1);
	// 		string file = extless + "png";
	// 		GLuint tex = load_image_texture(file.c_str());
	// 		materials_diffuses[i] = tex;
	// 		printf("mat.diffuse_texname '%s' : %d\n", mat.diffuse_texname.c_str(), tex);
	// 		// DGDGDGDG obviously this is all very wrong, it wont ever be GC'ed and all such kind of nasty
	// 		// THIS IS A TETS ONLY
	// 	}
	// 	i++;
	// }

	for (size_t s = 0; s < shapes.size(); s++) {
		size_t index_offset = 0;
		for (size_t f = 0; f < shapes[s].mesh.num_face_vertices.size(); f++) {
			size_t fnum = shapes[s].mesh.num_face_vertices[f];
			int mat_id = shapes[s].mesh.material_ids[f];
			auto &mat = materials[mat_id];
			for (size_t v = 0; v < fnum; v++) {
				tinyobj::index_t idx = shapes[s].mesh.indices[index_offset + v];
				vec4 pos(attrib.vertices[3 * idx.vertex_index + 0], attrib.vertices[3 * idx.vertex_index + 1], attrib.vertices[3 * idx.vertex_index + 2], 1);
				vec2 texcoords(0, 1);
				vec4 color(1, 1, 1, 1);

				if (idx.texcoord_index >= 0) {
					texcoords.x = attrib.texcoords[2 * idx.texcoord_index + 0];
					texcoords.y = attrib.texcoords[2 * idx.texcoord_index + 1];
					// tex[0] = materials_diffuses[mat_id];
					// printf("SHAPE %d tex : %d : %fx%f\n", s, materials_diffuses[mat_id], texcoords[0], texcoords[1]);
				}

				if (mat_id >= 0) {
					color.r = mat.diffuse[0];
					color.g = mat.diffuse[1];
					color.b = mat.diffuse[2];
				}

				// printf("POS %f x %f x %f\n", pos.x, pos.y, pos.z);
				vertices.push_back({pos, texcoords, color});
			}
			index_offset += fnum;
		}
		break;
	}
	
				// tinyobj::material_t &shapes[s].mesh.material_ids[3 * f + 0];
				// tinyobj::index_t idx0 = shapes[s].mesh.indices[3 * f + 0];
				// tinyobj::index_t idx1 = shapes[s].mesh.indices[3 * f + 1];
				// tinyobj::index_t idx2 = shapes[s].mesh.indices[3 * f + 2];

				// float v[3][3];
				// for (int k = 0; k < 3; k++) {
				// 	int f0 = idx0.vertex_index;
				// 	int f1 = idx1.vertex_index;
				// 	int f2 = idx2.vertex_index;
				// 	assert(f0 >= 0);
				// 	assert(f1 >= 0);
				// 	assert(f2 >= 0);

				// 	v[0][k] = attrib.vertices[3 * f0 + k];
				// 	v[1][k] = attrib.vertices[3 * f1 + k];
				// 	v[2][k] = attrib.vertices[3 * f2 + k];
				// }

				// float uv[3][3];
				// if (attrib.texcoords.size() > 0) {
				// 	int f0 = idx0.texcoord_index;
				// 	int f1 = idx1.texcoord_index;
				// 	int f2 = idx2.texcoord_index;
				// 	assert(f0 >= 0);
				// 	assert(f1 >= 0);
				// 	assert(f2 >= 0);
				// 	for (int k = 0; k < 2; k++) {
				// 		uv[0][k] = attrib.texcoords[2 * f0 + k];
				// 		uv[1][k] = attrib.texcoords[2 * f1 + k];
				// 		uv[2][k] = attrib.texcoords[2 * f2 + k];
				// 	}
				// }

				// float d[3][3];
				// if (attrib.diffuse.size() > 0) {
				// 	int f0 = idx0.texcoord_index;
				// 	int f1 = idx1.texcoord_index;
				// 	int f2 = idx2.texcoord_index;
				// 	assert(f0 >= 0);
				// 	assert(f1 >= 0);
				// 	assert(f2 >= 0);
				// 	for (int k = 0; k < 2; k++) {
				// 		d[0][k] = attrib.texcoords[2 * f0 + k];
				// 		d[1][k] = attrib.texcoords[2 * f1 + k];
				// 		d[2][k] = attrib.texcoords[2 * f2 + k];
				// 	}
				// }

				// float n[3][2];
				// if (attrib.normals.size() > 0) {
				// 	int f0 = idx0.normal_index;
				// 	int f1 = idx1.normal_index;
				// 	int f2 = idx2.normal_index;
				// 	assert(f0 >= 0);
				// 	assert(f1 >= 0);
				// 	assert(f2 >= 0);
				// 	for (int k = 0; k < 3; k++) {
				// 		n[0][k] = attrib.normals[3 * f0 + k];
				// 		n[1][k] = attrib.normals[3 * f1 + k];
				// 		n[2][k] = attrib.normals[3 * f2 + k];
				// 	}
				// } else {
				// 	// compute geometric normal
				// 	CalcNormal(n[0], v[0], v[1], v[2]);
				// 	n[1][0] = n[0][0];
				// 	n[1][1] = n[0][1];
				// 	n[1][2] = n[0][2];
				// 	n[2][0] = n[0][0];
				// 	n[2][1] = n[0][1];
				// 	n[2][2] = n[0][2];
				// }

				// for (int k = 0; k < 3; k++) {
				// 	// Use normal as color.
				// 	float c[3] = {n[k][0], n[k][1], n[k][2]};
				// 	float len2 = c[0] * c[0] + c[1] * c[1] + c[2] * c[2];
				// 	if (len2 > 0.0f) {
				// 		float len = sqrtf(len2);

				// 		c[0] /= len;
				// 		c[1] /= len;
				// 		c[2] /= len;
				// 	}

				// 	vertices.push_back({{v[k][0], v[k][1], v[k][2], 1}, {uv[k][0], uv[k][1]}, {c[0] * 0.5 + 0.5, c[1] * 0.5 + 0.5, c[2] * 0.5 + 0.5, 1}});
				// }
	// 		}
	// 	}
	// }
}

void DORVertexes::setDataKinds(uint8_t kinds) {
	data_kind = kinds;
	setChanged();
	setSortingChanged();
}

void DORVertexes::render(RendererGL *container, mat4& cur_model, vec4& cur_color, bool cur_visible) {
	if (!visible || !cur_visible) return;
	mat4 vmodel = cur_model * model;
	vec4 vcolor = cur_color * color;
	auto dl = getDisplayList(container, tex, shader, data_kind, RenderKind::QUADS);

	// Make sure we do not have to reallocate each step
	int nb = vertices.size();
	int startat = dl->list.size();
	dl->list.reserve(startat + nb);

	// Copy & apply the model matrix
	// DGDGDGDG: is it better to first copy it all and then alter it ? most likely not, change me
	dl->list.insert(std::end(dl->list), std::begin(this->vertices), std::end(this->vertices));
	vertex *dest = dl->list.data();

	if (data_kind & VERTEX_MODEL_INFO) {
		// Make sure we do not have to reallocate each step
		int nb = vertices.size();
		int startat = dl->list_model_info.size();
		dl->list_model_info.resize(startat + nb);
		vertex_model_info vm;
		vm.model = vmodel;
		std::fill_n(std::begin(dl->list_model_info) + startat, nb, vm);
		for (int di = startat; di < startat + nb; di++) {
			dest[di].color = vcolor * dest[di].color;
		}		
		// printf("rendering with model info\n");
	} else {
		// printf("rendering withOUT model info\n");
		for (int di = startat; di < startat + nb; di++) {
			dest[di].pos = vmodel * dest[di].pos;
			dest[di].color = vcolor * dest[di].color;
		}		
	}

	if (data_kind & VERTEX_KIND_INFO) {
		// Make sure we do not have to reallocate each step
		int nb = vertices_kind_info.size();
		int startat = dl->list_kind_info.size();
		dl->list_kind_info.reserve(startat + nb);
		dl->list_kind_info.insert(std::end(dl->list_kind_info), std::begin(this->vertices_kind_info), std::end(this->vertices_kind_info));
	}

	if (data_kind & VERTEX_MAP_INFO) {
		// Make sure we do not have to reallocate each step
		int nb = vertices_map_info.size();
		int startat = dl->list_map_info.size();
		dl->list_map_info.reserve(startat + nb);
		dl->list_map_info.insert(std::end(dl->list_map_info), std::begin(this->vertices_map_info), std::end(this->vertices_map_info));
	}

	resetChanged();
}

// void DORVertexes::renderZ(RendererGL *container, mat4& cur_model, vec4& cur_color, bool cur_visible) {
// 	if (!visible || !cur_visible) return;
// 	mat4 vmodel = cur_model * model;
// 	vec4 vcolor = cur_color * color;

// 	// Make sure we do not have to reallocate each step
// 	int nb = vertices.size();
// 	int startat = container->zvertices.size();
// 	container->zvertices.resize(startat + nb);

// 	// Copy & apply the model matrix
// 	vertex *src = vertices.data();
// 	sortable_vertex *dest = container->zvertices.data();
// 	for (int di = startat, si = 0; di < startat + nb; di++, si++) {
// 		dest[di].sub = NULL;
// 		dest[di].tex = tex;
// 		dest[di].shader = shader;
// 		dest[di].v.tex = src[si].tex;
// 		dest[di].v.color = vcolor * src[si].color;
// 		dest[di].v.pos = vmodel * src[si].pos;
// 	}

// 	resetChanged();
// }

void DORVertexes::sortZ(RendererGL *container, mat4& cur_model) {
	if (!is_zflat) {
		printf("[DORVertexes::sortZ] ERROR! trying to sort a non zflat vertices list!\n");
		return;
	}

	mat4 vmodel = cur_model * model;

	// We take a "virtual" point at zflat coordinates
	vec4 virtualz = vmodel * vec4(0, 0, zflat, 1);
	sort_z = virtualz.z;
	sort_shader = shader;
	sort_tex = tex;
	container->sorted_dos.push_back(this);
}

/*************************************************************************
 ** IContainer
 *************************************************************************/
void IContainer::containerAdd(DisplayObject *self, DisplayObject *dob) {
	dos.push_back(dob);
	dob->setParent(self);
};

bool IContainer::containerRemove(DisplayObject *dob) {
	for (auto it = dos.begin() ; it != dos.end(); ++it) {
		if (*it == dob) {
			dos.erase(it);

			dob->setParent(NULL);
			if (L) {
				int ref = dob->unsetLuaRef();
				refcleaner(&ref);
			}
			return true;
		}
	}
	return false;
};

void IContainer::containerClear() {
	for (auto it = dos.begin() ; it != dos.end(); ++it) {
		// printf("IContainer clearing : %lx\n", (long int)*it);
		(*it)->setParent(NULL);
		if (L) {
			int ref = (*it)->unsetLuaRef();
			refcleaner(&ref);
		}
	}
	dos.clear();
}

void IContainer::containerRender(RendererGL *container, mat4& cur_model, vec4& cur_color, bool cur_visible) {
	for (auto it = dos.begin() ; it != dos.end(); ++it) {
		DisplayObject *i = dynamic_cast<DisplayObject*>(*it);
		if (i) i->render(container, cur_model, cur_color, cur_visible);
	}
}

// void IContainer::containerRenderZ(RendererGL *container, mat4& cur_model, vec4& cur_color, bool cur_visible) {
// 	for (auto it = dos.begin() ; it != dos.end(); ++it) {
// 		DisplayObject *i = dynamic_cast<DisplayObject*>(*it);
// 		if (i) i->renderZ(container, cur_model, cur_color, cur_visible);
// 	}
// }

void IContainer::containerSortZ(RendererGL *container, mat4& cur_model) {
	for (auto it = dos.begin() ; it != dos.end(); ++it) {
		DisplayObject *i = dynamic_cast<DisplayObject*>(*it);
		if (i) i->sortZ(container, cur_model);
	}
}

/*************************************************************************
 ** DORContainer
 *************************************************************************/
void DORContainer::cloneInto(DisplayObject* _into) {
	DisplayObject::cloneInto(_into);
	DORContainer *into = dynamic_cast<DORContainer*>(_into);
	for (auto it = dos.begin() ; it != dos.end(); ++it) {
		into->add((*it)->clone());
	}	
}
void DORContainer::add(DisplayObject *dob) {
	containerAdd(this, dob);
	setChanged();
	setSortingChanged();
};

void DORContainer::remove(DisplayObject *dob) {
	if (containerRemove(dob)) {
		setChanged();
		setSortingChanged();
	}
};

void DORContainer::clear() {
	containerClear();
	setChanged(true);
	setSortingChanged();
}

DORContainer::~DORContainer() {
	clear();
}

void DORContainer::render(RendererGL *container, mat4& cur_model, vec4& cur_color, bool cur_visible) {
	if (!visible || !cur_visible) return;
	mat4 cmodel = cur_model * model;
	vec4 ccolor = cur_color * color;
	containerRender(container, cmodel, ccolor, true);
	resetChanged();
}

// void DORContainer::renderZ(RendererGL *container, mat4& cur_model, vec4& cur_color, bool cur_visible) {
// 	if (!visible || !cur_visible) return;
// 	mat4 cmodel = cur_model * model;
// 	vec4 ccolor = cur_color * color;
// 	containerRenderZ(container, cmodel, ccolor, true);
// 	resetChanged();
// }

void DORContainer::sortZ(RendererGL *container, mat4& cur_model) {
	// if (!visible) return; // DGDGDGDG: If you want :shown() to not trigger a Z rebuild we need to remove that. But to do that visible needs to be able to propagate like model & color; it does not currently
	mat4 cmodel = cur_model * model;
	containerSortZ(container, cmodel);
}

// void DORContainer::sortZ(RendererGL *container, mat4& cur_model) {
// }


/***************************************************************************
 ** SubRenderer
 ***************************************************************************/
#include <string.h>
void SubRenderer::cloneInto(DisplayObject* _into) {
	DORContainer::cloneInto(_into);
	SubRenderer *into = dynamic_cast<SubRenderer*>(_into);
	into->use_model = use_model;
	into->use_color = use_color;
	if (into->renderer_name) free((void*)into->renderer_name);
	into->renderer_name = strdup(renderer_name);
}

void SubRenderer::setRendererName(char *name, bool copy) {
	if (renderer_name) free((void*)renderer_name);
	if (copy) renderer_name = strdup(name);
	else renderer_name = name;
}
void SubRenderer::setRendererName(const char *name) {
	setRendererName((char*)name, true);
}

void SubRenderer::render(RendererGL *container, mat4& cur_model, vec4& cur_color, bool cur_visible) {
	if (!visible || !cur_visible) return;
	this->use_model = cur_model;
	this->use_color = cur_color;
	stopDisplayList(); // Needed to make sure we break texture chaining
	auto dl = getDisplayList(container);
	stopDisplayList(); // Needed to make sure we break texture chaining
	dl->sub = this;
	// resetChanged(); // DGDGDGDG: investigate why things break if this is on
}

// void SubRenderer::renderZ(RendererGL *container, mat4& cur_model, vec4& cur_color, bool cur_visible) {
// 	if (!visible || !cur_visible) return;
// 	this->use_model = cur_model;
// 	this->use_color = cur_color;
// 	int startat = container->zvertices.size();
// 	container->zvertices.resize(startat + 1);
// 	sortable_vertex *dest = container->zvertices.data();
// 	dest[startat].sub = this;
// 	// resetChanged(); // DGDGDGDG: investigate why things break if this is on
// }

void SubRenderer::sortZ(RendererGL *container, mat4& cur_model) {
	mat4 vmodel = cur_model * model;

	// We take a "virtual" point at zflat coordinates
	vec4 virtualz = vmodel * vec4(0, 0, 0, 1);
	sort_z = virtualz.z;
	sort_shader = NULL;
	sort_tex = {0, 0, 0};
	container->sorted_dos.push_back(this);
}

void SubRenderer::toScreenSimple() {
	toScreen(mat4(), {1.0, 1.0, 1.0, 1.0});
}

/***************************************************************************
 ** StaticSubRenderer class
 ***************************************************************************/
void StaticSubRenderer::cloneInto(DisplayObject* _into) {
	SubRenderer::cloneInto(_into);
	StaticSubRenderer *into = dynamic_cast<StaticSubRenderer*>(_into);
	into->cb = cb;
}

void StaticSubRenderer::toScreen(mat4 cur_model, vec4 color) {
	if (cb) cb(cur_model, color);
}

/***************************************************************************
 ** DORCallback class
 ***************************************************************************/
void DORCallback::cloneInto(DisplayObject* _into) {
	SubRenderer::cloneInto(_into);
	DORCallback *into = dynamic_cast<DORCallback*>(_into);
	if (L && cb_ref) {
		lua_rawgeti(L, LUA_REGISTRYINDEX, cb_ref);
		into->cb_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	}
}

void DORCallback::onKeyframe(float nb_keyframes) {
	keyframes += nb_keyframes;
}

void DORCallback::toScreen(mat4 cur_model, vec4 color) {
	lua_rawgeti(L, LUA_REGISTRYINDEX, cb_ref);
	lua_pushnumber(L, keyframes);
	if (lua_pcall(L, 1, 0, 0))
	{
		printf("DORCallback callback error: %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
	keyframes = 0;
}
