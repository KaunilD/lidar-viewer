#include "libs.h"
#include "vertex.hpp"

class PCObject {
public:

	unsigned int idx;
	int totalPoints = 700;

	glm::mat4 modelMatrix = glm::mat4(1.0f);

	glm::vec3 min = glm::vec3(1.0f);
	glm::vec3 max = glm::vec3(1.0f);
	glm::vec3 mean = glm::vec3(1.0f);


	std::vector<Vertex> vertices;
	std::vector<GLuint> indices;

	PCObject();
	PCObject(const char * data_file);

	~PCObject();

	GLuint shaderID;
	GLuint VAO, VBO, EBO;
	void attachShaders(GLuint programID) { shaderID = programID; };
	void setupGLBuffers();
	void render();
};
