/*
	TE4 - T-Engine 4
	Copyright (C) 2009 - 2017 Nicolas Casalini

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
using namespace std;
using namespace glm;

enum class GeneratorsList : uint8_t {
	LifeGenerator,
	BasicTextureGenerator,
	DiskPosGenerator, CirclePosGenerator,
	DiskVelGenerator,
	BasicSizeGenerator,
	BasicRotationGenerator,
	StartStopColorGenerator, FixedColorGenerator,
};

class Generator {
protected:
	vec2 base_pos = vec2(0, 0), shift_pos = vec2(0, 0), final_pos = vec2(0, 0);

public:
	void shift(float x, float y, bool absolute);
	void basePos(float x, float y) { base_pos = vec2(x, y); };
	virtual void useSlots(ParticlesData &p) {};
	virtual void generate(ParticlesData &p, uint32_t start, uint32_t end) = 0;
};

/********************************************************************
 ** Life
 ********************************************************************/
class LifeGenerator : public Generator {
	float min, max;
public:
	LifeGenerator(float min, float max) : min(min), max(max) {};
	virtual void useSlots(ParticlesData &p) { p.initSlot4(LIFE); };
	virtual void generate(ParticlesData &p, uint32_t start, uint32_t end);
};

/********************************************************************
 ** Texture
 ********************************************************************/
class BasicTextureGenerator : public Generator {
public:
	virtual void useSlots(ParticlesData &p) { p.initSlot2(TEX); };
	virtual void generate(ParticlesData &p, uint32_t start, uint32_t end);
};

/********************************************************************
 ** Positions
 ********************************************************************/
class DiskPosGenerator : public Generator {
	float radius;
public:
	DiskPosGenerator(float radius) : radius(radius) {};
	virtual void useSlots(ParticlesData &p) { p.initSlot4(POS); };
	virtual void generate(ParticlesData &p, uint32_t start, uint32_t end);
};

class CirclePosGenerator : public Generator {
	float radius;
	float width;
public:
	CirclePosGenerator(float radius, float width) : radius(radius), width(width) {};
	virtual void useSlots(ParticlesData &p) { p.initSlot4(POS); };
	virtual void generate(ParticlesData &p, uint32_t start, uint32_t end);
};

class DiskVelGenerator : public Generator {
	float min_vel, max_vel;
public:
	DiskVelGenerator(float min_vel, float max_vel) : min_vel(min_vel), max_vel(max_vel) {};
	virtual void useSlots(ParticlesData &p) { p.initSlot2(VEL); p.initSlot2(ACC); };
	virtual void generate(ParticlesData &p, uint32_t start, uint32_t end);
};

class BasicSizeGenerator : public Generator {
	float min_size, max_size;
public:
	BasicSizeGenerator(float min_size, float max_size) : min_size(min_size), max_size(max_size) {};
	virtual void useSlots(ParticlesData &p) { p.initSlot4(POS); };
	virtual void generate(ParticlesData &p, uint32_t start, uint32_t end);
};

class BasicRotationGenerator : public Generator {
	float min_rot, max_rot;
public:
	BasicRotationGenerator(float min_rot, float max_rot) : min_rot(min_rot), max_rot(max_rot) {};
	virtual void useSlots(ParticlesData &p) { p.initSlot4(POS); };
	virtual void generate(ParticlesData &p, uint32_t start, uint32_t end);
};

/********************************************************************
 ** Colors
 ********************************************************************/
class StartStopColorGenerator : public Generator {
	vec4 min_color_start, min_color_stop; 
	vec4 max_color_start, max_color_stop; 
public:
	StartStopColorGenerator(vec4 min_color_start, vec4 max_color_start, vec4 min_color_stop, vec4 max_color_stop) : min_color_start(min_color_start), max_color_start(max_color_start), min_color_stop(min_color_stop), max_color_stop(max_color_stop)  {};
	virtual void useSlots(ParticlesData &p) { p.initSlot4(COLOR); p.initSlot4(COLOR_START); p.initSlot4(COLOR_STOP); };
	virtual void generate(ParticlesData &p, uint32_t start, uint32_t end);
};

class FixedColorGenerator : public Generator {
	vec4 color_start;
	vec4 color_stop;
public:
	FixedColorGenerator(vec4 color_start, vec4 color_stop) : color_start(color_start), color_stop(color_stop) {};
	virtual void useSlots(ParticlesData &p) { p.initSlot4(COLOR); p.initSlot4(COLOR_START); p.initSlot4(COLOR_STOP); };
	virtual void generate(ParticlesData &p, uint32_t start, uint32_t end);
};
