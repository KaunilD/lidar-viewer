#version 440

in vec3 vs_position;
in vec3 vs_color;
in vec2 vs_texcoord;

out vec4 fs_color;


double interpolate(double val, double y0, double x0, double y1, double x1) {
	return (val - x0)*(y1 - y0) / (x1 - x0) + y0;
}

double base(double val) {
	if (val <= -0.75) return 0;
	else if (val <= -0.25) return interpolate(val, 0.0, -0.75, 1.0, -0.25);
	else if (val <= 0.25) return 1.0;
	else if (val <= 0.75) return interpolate(val, 1.0, 0.25, 0.0, 0.75);
	else return 0.0;
}

double red(double gray) {
	return base(gray - 0.5);
}
double green(double gray) {
	return base(gray);
}
double blue(double gray) {
	return base(gray + 0.5);
}


void main()
{
	fs_color = vec4(red(vs_position.r), green(vs_position.r), blue(vs_position.r), 1.f);
}