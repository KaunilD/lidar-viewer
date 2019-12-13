#version 440

in vec3 vs_position;
in vec3 vs_normal;

uniform vec3 lightPosition;
uniform vec3 viewPos;

uniform vec3 lightColor;
uniform vec3 objectColor;



out vec4 fs_color;

void main()
{
	
	float ambientStrength = 0.5;

	vec3 ambientLight = ambientStrength * lightColor;
	
	vec3 normedNormal = normalize(vs_normal);
	vec3 lightDir = normalize(lightPosition - vs_position);
	float diffuse = normalize(dot(lightDir, normedNormal));
	float diffuseStrength = max(diffuse, 0.0f);

	vec3 diffuseLight = diffuseStrength * lightColor;

	vec3 result = (ambientLight + diffuseLight)* objectColor; 

	fs_color = vec4(result, 1.0f);
}