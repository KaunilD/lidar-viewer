#include <glm/vec3.hpp>

#ifndef LIST_H_
#define LIST_H_
struct Vertex {
	glm::vec3 position; // 12bytes
	glm::vec3 normals;
	glm::vec3 color; // 12 bytes
	glm::vec3 tangent;
	glm::vec3 bitTangent;
	glm::vec2 texture;
};
#endif