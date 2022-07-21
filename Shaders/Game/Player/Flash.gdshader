shader_type canvas_item;

uniform bool flash = false;

void fragment ()
{
	vec4 texcolor = texture(TEXTURE, UV);
	if (flash && (texcolor.a > 0.0)) {
		COLOR.rgb = vec3(1.0);
	} else {
		COLOR = texcolor;
	}
}