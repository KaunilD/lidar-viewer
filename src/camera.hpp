#include <glm/glm.hpp>
#include <glm/vec3.hpp>
#include <glm/vec4.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/mat4x4.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <exception>

#define FOV 45.0f

enum Movement {
	Q,
	A,
	W,
	S,
	Z,
	X,
	UP,
	DOWN,
	RIGHT,
	LEFT
};

class Camera {
public:

	float fov;
	float near;
	float far;
	float aspectRatio;
	int fbWidth, fbHeight;

	float pitch;
	float yaw;

	float speed;

	glm::vec3 positionVector;
	glm::vec3 upVector;
	glm::vec3 worldUpVector;
	glm::vec3 rightVector;

	glm::vec3 frontVector;


	glm::mat4 viewMatrix;
	glm::mat4 projectionMatrix, modelMatrix;


	Camera();
	Camera(
		glm::vec3 _upVector, glm::vec3 _frontVector, glm::vec3 _positionVector,
		float _fov, float _fbW, float _fbH, float _near, float _far
	);

	void setSpeed(float _speed);
	void processKB(Movement mov, float speed);
	void updateDirectionVectors();
	void updateViewMatrix();
	void updateProjectionMatrix();

};