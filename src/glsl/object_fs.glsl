#version 440

in vec3 vs_position;
in vec3 vs_normal;

uniform vec3 cameraPos;
uniform vec3 viewPos;

out vec4 fs_color;

void main()
{
	float ambientStrength = 0.1;
    float specularStrength = 0.5;
    vec3 lightColor = vec3(0.70f);
	
	// ambient
	vec3 ambient = ambientStrength * lightColor;
  	
	// diffuse 
    vec3 norm = normalize(vs_normal);
    vec3 lightDir = normalize(cameraPos - vs_position);
    float diff = max(dot(norm, lightDir), 0.0f);
    vec3 diffuse = diff * lightColor;

	// specular
	vec3 viewDir = normalize(viewPos - vs_position);
    vec3 reflectDir = reflect(-lightDir, norm);  
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    vec3 specular = specularStrength * spec * lightColor;  

	vec3 result = (ambient + diffuse + specular) * vec3(1.0f);
	fs_color = vec4(result, 1.0f);
}