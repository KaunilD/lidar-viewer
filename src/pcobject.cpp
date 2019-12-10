#include "pcobject.hpp"

PCObject::~PCObject() {

}

PCObject::PCObject() {};

PCObject::PCObject(const char * data_path) {
	try {
		boost::property_tree::ptree pt;
		boost::property_tree::read_json(data_path, pt);
		for (boost::property_tree::ptree::value_type& root : pt) {
			std::cout << root.first.data() << std::endl;

			for (boost::property_tree::ptree::value_type& frames : root.second) {

				for (boost::property_tree::ptree::value_type& frame : frames.second) {
					idx = frame.second.get<int>("idx");
					int pIdx = 0;
					for (boost::property_tree::ptree::value_type& point : frame.second.get_child("points")) {

						vertices.push_back(Vertex{
							glm::vec3(
								point.second.get<float>("x"),
								point.second.get<float>("y"),
								point.second.get<float>("z")
							),
							glm::vec3(1.0f),
							glm::vec3(1.0f),
							glm::vec3(1.0f),
							glm::vec3(1.0f),
							glm::vec2(1.0f),
							});
						indices.push_back(pIdx);

						pIdx += 1;

						if (pIdx >= totalPoints) break;
					}
				}
			}
		}
	}
	catch (std::exception const& e) {
		std::cout << "ERROR:: JSON_READ::" << e.what() << std::endl;
	}
}

void PCObject::setupGLBuffers() {
	glGenVertexArrays(1, &VAO);
	glGenBuffers(1, &VBO);
	glGenBuffers(1, &EBO);

	glBindVertexArray(VAO);

	glBindBuffer(GL_ARRAY_BUFFER, VBO);
	glBufferData(GL_ARRAY_BUFFER, vertices.size()*sizeof(Vertex), &vertices[0], GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size()*sizeof(GLuint), &indices[0], GL_STATIC_DRAW);

	// LOCATION AND LAYOUT OF VERTICES AND INDICES IN GLSL 
	GLuint positionAttribLoc = glGetAttribLocation(shaderID, "vertex_position");
	glVertexAttribPointer(positionAttribLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, position));
	glEnableVertexAttribArray(positionAttribLoc);

	GLuint colorAttribLoc = glGetAttribLocation(shaderID, "vertex_color");
	glVertexAttribPointer(colorAttribLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, color));
	glEnableVertexAttribArray(colorAttribLoc);
}

void PCObject::render() {
	glBindVertexArray(VAO);
	glDrawElements(GL_POINTS, indices.size(), GL_UNSIGNED_INT, 0);
}