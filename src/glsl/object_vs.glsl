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
	vs_normal = mat3(transpose(inverse(modelMatrix))) * vertex_normal;  

	gl_Position = modelMatrix * viewMatrix * vec4(vertex_position, 1.f);
	
	// multiply vertex_position with model and view matrix to give an effect 
	// of a stationary light source illuminating different parts of the object
	// as it changes views
	vs_position = vec3(gl_position);
	
}