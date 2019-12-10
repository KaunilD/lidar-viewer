#include "libs.h"
#include "vertex.hpp"

class PCObject {
public:

	unsigned int idx;
	int totalPoints = 70000;

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
