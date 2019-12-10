#include "camera.hpp"

Camera::Camera() {}

Camera::Camera(
	glm::vec3 _upVector, glm::vec3 _frontVector, glm::vec3 _positionVector,
	float _fov, float _fbW, float _fbH, float _near, float _far
) {
	positionVector = _positionVector;
	upVector = _upVector;
	frontVector = _frontVector;
	worldUpVector = _upVector;


	fov = _fov;
	fbWidth = _fbW;
	fbHeight = _fbH;
	near = _near;
	far = _far;

	pitch = 0.0f; 
	yaw =  -90.0f;

	updateDirectionVectors();
	updateViewMatrix();
	updateProjectionMatrix();

}

void Camera::setSpeed(float _speed) {
	speed = _speed;
}

void Camera::processKB(Movement movement, float speed) {
	if (movement == W) {
		positionVector += speed * frontVector;
	}
	if (movement == S) {
		positionVector -= speed * frontVector;
	}
	if (movement == Q) {
		positionVector += speed * worldUpVector;
	}
	if (movement == A) {
		positionVector -= speed * worldUpVector;
	}

	if (movement == Z ){
		positionVector -= rightVector * speed;
	}

	if (movement == X){
		positionVector += rightVector * speed;
	}
	if (movement == UP){
		pitch += 0.10f;
		if (pitch > 89.0f)
			pitch = 89.0f;

		updateDirectionVectors();

	}
	if (movement == DOWN) {
		pitch -= 0.10f;
		
		if (pitch < -89.0f)
			pitch = -89.0f;

		updateDirectionVectors();
	}
	if (movement == LEFT){
		yaw -= 0.10f;

		updateDirectionVectors();
	}
	if (movement == RIGHT) {
		yaw += 0.10f;
		
		updateDirectionVectors();
	}
}

void Camera::updateDirectionVectors() {
	glm::vec3 front;
	front.x = cos(glm::radians(yaw)) * cos(glm::radians(pitch));
	front.y = sin(glm::radians(pitch));
	front.z = sin(glm::radians(yaw)) * cos(glm::radians(pitch));
	frontVector = glm::normalize(front);

	rightVector = glm::normalize(glm::cross(frontVector, worldUpVector));
	upVector = glm::normalize(glm::cross(rightVector, frontVector));
}

void Camera::updateViewMatrix() {
	viewMatrix = glm::lookAt(
		positionVector, positionVector + frontVector, upVector
	);
}

void Camera::updateProjectionMatrix() {
	
	projectionMatrix = glm::perspective(
		glm::radians(fov),
		(float) fbWidth / (float) fbHeight,
		near, far
	);
}
