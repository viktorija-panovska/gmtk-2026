shader_type spatial;

uniform sampler2D drawing_tex;
uniform sampler2D stencil_tex;
uniform bool use_stencil;

void fragment() {
	vec4 drawing = texture(drawing_tex, UV);
	if (drawing.a != 0.0 && (!use_stencil || texture(stencil_tex, UV) != vec4(1, 1, 1, 1)))
		ALBEDO = drawing.rgb;
	else
		ALPHA = 0.0;
}