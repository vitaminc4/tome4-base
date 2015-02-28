/*
    TE4 - T-Engine 4
    Copyright (C) 2009 - 2015 Nicolas Casalini

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
#include "display.h"
#include "types.h"
#include "physfs.h"
#include "physfsrwops.h"
#include "renderer.h"
}

#include "renderer-gl.hpp"

bool use_modern_gl = TRUE;

static RendererState *state = NULL;

// A static cache of element positions; quad VO only ahve quads so we can cache those
static GLuint *vbo_elements_data = NULL;
static GLuint vbo_elements = 0;
static int vbo_elements_nb = 0;

vertexes_renderer* vertexes_renderer_new(vertex_mode kind, render_mode mode) {
	vertexes_renderer *vr = (vertexes_renderer*)malloc(sizeof(vertexes_renderer));
	glGenBuffers(1, &vr->vbo);
	if (mode == VERTEX_STATIC) vr->mode = GL_STATIC_DRAW;
	if (mode == VERTEX_DYNAMIC) vr->mode = GL_DYNAMIC_DRAW;
	if (mode == VERTEX_STREAM) vr->mode = GL_STREAM_DRAW;
	if (kind == VO_POINTS) vr->kind = GL_POINTS;
	if (kind == VO_QUADS) vr->kind = GL_TRIANGLES;
	if (kind == VO_TRIANGLE_FAN) vr->kind = GL_TRIANGLE_FAN;
	return vr;
}

void vertexes_renderer_free(vertexes_renderer *vr) {
	glDeleteBuffers(1, &vr->vbo);
	free(vr);
}

static void vertexes_renderer_update(vertexes_renderer *vr, lua_vertexes *vx) {
	// Release old un-needed buffer, this way the GL driver does not have to lock the memory
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertex_data) * vx->nb, NULL, vr->mode);
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertex_data) * vx->nb, vx->vertices);

	if (vx->kind == VO_QUADS) {
		int nb_quads = vx->nb / 4;

		if (nb_quads > vbo_elements_nb) {
			vbo_elements_data = (GLuint*)realloc((void*)vbo_elements_data, nb_quads * 6 * sizeof(GLuint));
			for (; vbo_elements_nb < nb_quads; vbo_elements_nb++) {
				// printf("Initing a quad elements %d\n", vbo_elements_nb);
				vbo_elements_data[vbo_elements_nb * 6 + 0] = vbo_elements_nb * 4 + 0;
				vbo_elements_data[vbo_elements_nb * 6 + 1] = vbo_elements_nb * 4 + 1;
				vbo_elements_data[vbo_elements_nb * 6 + 2] = vbo_elements_nb * 4 + 2;

				vbo_elements_data[vbo_elements_nb * 6 + 3] = vbo_elements_nb * 4 + 0;
				vbo_elements_data[vbo_elements_nb * 6 + 4] = vbo_elements_nb * 4 + 2;
				vbo_elements_data[vbo_elements_nb * 6 + 5] = vbo_elements_nb * 4 + 3;
			}

			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo_elements);
			// Release old un-needed buffer, this way the GL driver does not have to lock the memory
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint) * vbo_elements_nb * 6, NULL, GL_DYNAMIC_DRAW);
			glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeof(GLuint) * vbo_elements_nb * 6, vbo_elements_data);
		}
	}
}

void vertexes_renderer_toscreen(vertexes_renderer *vr, lua_vertexes *vx, float x, float y, float r, float g, float b, float a) {
	tglBindTexture(GL_TEXTURE_2D, vx->tex);
	state->translate(x, y, 0);

	// Modern(ish) OpenGL way
	if (use_modern_gl) {
		shader_type *shader;

		if (!current_shader) {
			useNoShader();
			if (!current_shader) return;
		}

		shader = current_shader;
		if (shader->vertex_attrib == -1) return;

		if (shader->p_color != -1) {
			GLfloat d[4];
			d[0] = r;
			d[1] = g;
			d[2] = b;
			d[3] = a;
			glUniform4fv(shader->p_color, 1, d);
		}

		if (shader->p_mvp != -1) {
			state->updateMVP();
			glUniformMatrix4fv(shader->p_mvp, 1, GL_FALSE, glm::value_ptr(state->mvp));
		}

		glBindBuffer(GL_ARRAY_BUFFER, vr->vbo);
		if (vx->changed) {
			vertexes_renderer_update(vr, vx);
		}

		glEnableVertexAttribArray(shader->vertex_attrib);
		glVertexAttribPointer(shader->vertex_attrib, 2, GL_FLOAT, GL_FALSE, sizeof(vertex_data), 0);
		if (shader->texcoord_attrib != -1) {
			glEnableVertexAttribArray(shader->texcoord_attrib);
			glVertexAttribPointer(shader->texcoord_attrib, 2, GL_FLOAT, GL_FALSE, sizeof(vertex_data), (void*)(sizeof(GLfloat) * 2));
		}
		if (shader->color_attrib != -1) {
			glEnableVertexAttribArray(shader->color_attrib);
			glVertexAttribPointer(shader->color_attrib, 4, GL_FLOAT, GL_FALSE, sizeof(vertex_data), (void*)(sizeof(GLfloat) * 4));
		}

		if (vx->kind == VO_QUADS) {
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo_elements);
			glDrawElements(vr->kind, vx->nb / 4 * 6, GL_UNSIGNED_INT, (void*)0);
		} else {
			glDrawArrays(vr->kind, 0, vx->nb);
		}

		glDisableVertexAttribArray(shader->vertex_attrib);
		glDisableVertexAttribArray(shader->texcoord_attrib);
		glDisableVertexAttribArray(shader->color_attrib);
		glBindBuffer(GL_ARRAY_BUFFER, 0);

	// Fallback OpenGl 1.1 way, no shaders, fixed pipeline
	} else {
#ifndef NO_OLD_GL
		glVertexPointer(2, GL_FLOAT, sizeof(vertex_data), vx->vertices);
		glTexCoordPointer(2, GL_FLOAT, sizeof(vertex_data), &vx->vertices[0].u);
		glColorPointer(4, GL_FLOAT, sizeof(vertex_data), &vx->vertices[0].r);
		if (vx->kind == VO_QUADS) {
			glDrawArrays(GL_QUADS, 0, vx->nb);
		} else {
			glDrawArrays(vr->kind, 0, vx->nb);
		}
#endif
	}

	state->translate(-x, -y, 0);
	vx->changed = FALSE;
}

void renderer_translate(float x, float y, float z) {
	state->translate(x, y, z);
}
void renderer_scale(float x, float y, float z) {
	state->scale(x, y, z);
}
void renderer_rotate(float a, float x, float y, float z) {
	state->rotate(a, x, y, z);
}
void renderer_pushstate(bool isworld) {
	state->pushState(isworld);
}
void renderer_popstate(bool isworld) {
	state->popState(isworld);
}
void renderer_identity(bool isworld) {
	state->identity(isworld);
}

void renderer_push_ortho_state(int w, int h) {
	state->pushOrthoState(w, h);
}
void renderer_pop_ortho_state() {
	state->popOrthoState();
}

void renderer_init(int w, int h) {
	if (!vbo_elements) glGenBuffers(1, &vbo_elements);

	if (state) delete state;
	state = new RendererState(w, h);
}