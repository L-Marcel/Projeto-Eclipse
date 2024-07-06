shader_type canvas_item;

uniform bool whitten = false;

void fragment() {
	if(whitten) {
		COLOR.rgb = vec3(1.0, 1.0, 1.0);
	}
}
