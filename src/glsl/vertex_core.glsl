#version 440

layout (location = 0) in vec3 vertex_position;
layout (location = 1) in vec3 vertex_color;

out vec3 vs_position;
out vec3 vs_color;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;


void main()
{
	vs_position = vertex_position;
	vs_color = vertex_color;

	gl_Position = projectionMatrix * viewMatrix * vec4(vertex_position, 1.f);
}