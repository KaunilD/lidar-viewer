#include "libs.h"
#include "vertex.hpp"
/*
	Indexed v, vt, vn read from file using 
	faces (f) section of the .obj file
*/

class ObjLoader {
public:
	std::vector<Vertex> vertices;
	std::vector<int> indices;
	
	// raw data read from file line by line
	std::vector<glm::vec3> rawVertices;
	std::vector<glm::vec2> rawTextures;
	std::vector<glm::vec3> rawNormals;

	std::vector<int> vertesIndices;
	std::vector<int> textureIndices;
	std::vector<int> normalIndices;

	ObjLoader();
	ObjLoader(const char * obj_path);

	GLuint shaderID;
	GLuint VAO, VBO, EBO;

	glm::mat4 modelMatrix = glm::mat4(1.0f);

	void setupModelMatrix();
	void attachShaders(GLuint programID) { shaderID = programID; };
	void setupGLBuffers();
	void render();

};