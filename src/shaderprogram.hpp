#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include <glm/glm.hpp>
#include <glm/vec3.hpp>
#include <glm/vec4.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/mat4x4.hpp>
#include <glm/gtc/matrix_transform.hpp>

class ShaderProgram {
	public:
		GLuint programID;
		ShaderProgram();
		ShaderProgram(const char * vs_path, const char * fs_path);
		void useProgram();
		void setMat4(std::string name, glm::mat4 matrix);
		void setVec3(std::string name, glm::vec3 vector);
	private:
		void checkCompileErrors(GLuint programID, std::string type);
};