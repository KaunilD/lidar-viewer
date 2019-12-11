#version 440

layout (location = 0) in vec3 vertex_position;
layout (location = 1) in vec3 vertex_color;
layout (location = 2) in vec3 vertex_normal;

out vec3 vs_position;
out vec3 vs_normal;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;


void main()
{
	vs_position = vertex_position;
	vs_normal = vertex_normal;

	gl_Position = viewMatrix * modelMatrix * vec4(vertex_position, 1.f);
}