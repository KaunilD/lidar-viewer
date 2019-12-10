#include "objloader.hpp"

ObjLoader::ObjLoader() {}

ObjLoader::ObjLoader(const char * obj_path) {
	std::ifstream objFile;
	std::string line;
	// ensure ifstream objects can throw exceptions:
	objFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);
	try
	{
		// open files
		objFile.open(obj_path);
	}
	catch (std::ifstream::failure e)
	{
		std::cout << "ERROR::SHADERPROGRAM::FILE_NOT_SUCCESFULLY_READ" << std::endl;
	}
	while (!objFile.eof()) {
		std::getline(objFile, line);
		std::istringstream ss(line);
		std::string token;

		std::getline(ss, token, ' ');
		//std::cout << line << std::endl;

		if (token == "v") {
			glm::vec3 vertex;
			for (int i = 0; i < 3; i++) {
				std::getline(ss, token, ' ');
				//std::cout << token << std::endl;
				vertex[i] = std::stof(token);
			}
			rawVertices.push_back(vertex);
		}
		else if (token == "vt") {
			glm::vec2 texture;
			for (int i = 0; i < 2; i++) {
				std::getline(ss, token, ' ');
				texture[i] = std::stof(token);
			}
			rawTextures.push_back(texture);
		}
		else if (token == "vn") {
			glm::vec3 normal;
			for (int i = 0; i < 3; i++)
			{
				std::getline(ss, token, ' ');
				normal[i] = std::stof(token);
			}
			rawNormals.push_back(normal);
		}
		else if (token == "f") {
			// f 1/1/1 2/2/2 3/3/3
			for (int i = 0; i < 3; i++) {
				std::getline(ss, token, ' ');
				std::istringstream ss2(token);
				std::string index;

				std::getline(ss2, index, '/');
				vertesIndices.push_back(std::stoul(index));

				std::getline(ss2, index, '/');
				textureIndices.push_back(std::stoul(index));

				std::getline(ss2, index, '/');
				normalIndices.push_back(std::stoul(index));
			}
		}
	}
	std::cout << vertesIndices.size() << std::endl;
	for (int i = 0; i < vertesIndices.size(); i ++) {
		vertices.push_back(Vertex{
				rawVertices[vertesIndices[i] - 1],
				rawNormals[normalIndices[i] - 1],
				glm::vec3(1.0f),
				glm::vec3(1.0f),
				glm::vec3(1.0f),
				rawTextures[textureIndices[i] - 1]
			});
		indices.push_back(i);
	}

	std::cout << "Loaded " << vertices.size() << " points.";

}

void ObjLoader::setupGLBuffers() {
	
	glGenVertexArrays(1, &VAO);
	glGenBuffers(1, &VBO);
	glGenBuffers(1, &EBO);

	glBindVertexArray(VAO);
	
	glBindBuffer(GL_ARRAY_BUFFER, VBO);
	glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(Vertex), &vertices[0], GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(int), &indices[0], GL_STATIC_DRAW);

	// POSITION
	GLuint positionAttribLoc = glGetAttribLocation(shaderID, "vertex_position");
	glEnableVertexAttribArray(positionAttribLoc);
	glVertexAttribPointer(positionAttribLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, position));
	// COLOR
	GLuint colorAttribLoc = glGetAttribLocation(shaderID, "vertex_color");
	glEnableVertexAttribArray(colorAttribLoc);
	glVertexAttribPointer(colorAttribLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, color));
	// NORMAL
	GLuint normalAttribLoc = glGetAttribLocation(shaderID, "vertex_normal");
	glEnableVertexAttribArray(normalAttribLoc);
	glVertexAttribPointer(normalAttribLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, normals));

}

void ObjLoader::render() {
	glBindVertexArray(VAO);
	glDrawElements(GL_TRIANGLES, indices.size(), GL_UNSIGNED_INT, 0);
	glBindVertexArray(0);
}