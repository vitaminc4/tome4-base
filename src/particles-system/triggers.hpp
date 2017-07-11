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

enum class TriggerableKind { DESTROY, WAKEUP, FORCE };

class Triggerable {
private:
	bool can_trigger = false;
	unordered_map<string, TriggerableKind> triggers_map;

public:
	inline bool canTrigger() { return can_trigger; }
	void triggerOnName(string &name, TriggerableKind kind) {
		triggers_map.emplace(name, kind);
	}
	inline void fireTrigger(string &name) {
		const auto it = triggers_map.find(name);
		if (it == triggers_map.end()) return;
		triggered(it->second);
	}

	virtual void triggered(TriggerableKind kind) {};
};
