﻿#include "libs.h"
#include "objloader.hpp"
#include "pcobject.hpp"
#include "shaderprogram.hpp"
#include "camera.hpp"

int frameBufferHeight = 0;
int frameBufferWidth = 0;

// FPS CONTROLLER
bool running = true;
double lastTime = 0.0;
double deltaTime;
double currentTime;
const double maxFPS = 360.0f;
const double maxPeriod = 1.0 / maxFPS;

// CAMERA
float cameraSpeed = 0.05f; // adjust accordingly

// MODEL MATRIX
glm::mat4 modelMatrix;

// VIEW MATRIX
glm::vec3 camUpVector = glm::vec3(0.0f, 1.0f, 0.0f);
glm::vec3 camFrontVector = glm::vec3(0.0f, 0.0f, -1.0f);
glm::vec3 camPosVector = glm::vec3(0.0f, 0.0f, 1.0f);

// PROJECTION MATRIX
float fov = 45.0f;
float near = 0.001f;
float far = 200.0f;

Camera camera, slrCamera;

int readLIDARFrame(std::string, struct LIDARFrame *);
void display(GLFWwindow);
void updateInput(GLFWwindow);
void frameBufferResizeCb(GLFWwindow, int, int);
bool loadShaders(GLuint &);
int main(void);
int updatePointCloud();
void initGlRenderFlags(void);

int currentFrame = 0;

void display(GLFWwindow *window) {
	glfwSwapBuffers(window);
	glFlush();
}

void updateInput(GLFWwindow * window) {
	if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
		glfwSetWindowShouldClose(window, GLFW_TRUE);
	}

	cameraSpeed = 0.1f * (float)deltaTime;

	if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS) {
		camera.processKB(W, cameraSpeed);
		slrCamera.processKB(W, cameraSpeed);
	}
	if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS) {
		camera.processKB(S, cameraSpeed);
		slrCamera.processKB(S, cameraSpeed);
	}
	if (glfwGetKey(window, GLFW_KEY_Q) == GLFW_PRESS){
		camera.processKB(Q, cameraSpeed);
		slrCamera.processKB(Q, cameraSpeed);
	}
	if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS) {
		camera.processKB(A, cameraSpeed);
		slrCamera.processKB(A, cameraSpeed);
	}
	if (glfwGetKey(window, GLFW_KEY_Z) == GLFW_PRESS) {
		camera.processKB(Z, cameraSpeed);
		slrCamera.processKB(Z, cameraSpeed);
	}
	if (glfwGetKey(window, GLFW_KEY_X) == GLFW_PRESS) {
		camera.processKB(X, cameraSpeed);
		slrCamera.processKB(X, cameraSpeed);
	}
	if (glfwGetKey(window, GLFW_KEY_UP) == GLFW_PRESS) {
		camera.processKB(UP, cameraSpeed);
		slrCamera.processKB(UP, cameraSpeed);
	}
	if (glfwGetKey(window, GLFW_KEY_DOWN) == GLFW_PRESS) {
		camera.processKB(DOWN, cameraSpeed);
		slrCamera.processKB(DOWN, cameraSpeed);
	}
	if (glfwGetKey(window, GLFW_KEY_LEFT) == GLFW_PRESS) {
		camera.processKB(LEFT, cameraSpeed);
		slrCamera.processKB(LEFT, cameraSpeed);
	}
	if (glfwGetKey(window, GLFW_KEY_RIGHT) == GLFW_PRESS) {
		camera.processKB(RIGHT, cameraSpeed);
		slrCamera.processKB(RIGHT, cameraSpeed);
	}

	if (glfwGetKey(window, GLFW_KEY_N) == GLFW_PRESS) {
				
	}

	//std::cout << pitch << " " << yaw << std::endl;

}

void frameBufferResizeCb(GLFWwindow * window, int fbW, int fbH) {
	
	frameBufferWidth = fbW;
	frameBufferHeight = fbW;
	glViewport(0, 0, fbW, fbH);
}

void initGlRenderFlags() {
	glEnable(GL_DEPTH_TEST);
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

}

int main(void)
{

	if (!glfwInit())
		return -1;


	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 4);
	glfwWindowHint(GLFW_SAMPLES, 4); // 4x antialiasing
	glfwWindowHint(GLFW_RESIZABLE, GL_TRUE);

	GLFWwindow* window;
	window = glfwCreateWindow(
		VIEWPORT_WIDTH, VIEWPORT_HEIGHT,
		"PC Viewer", NULL, NULL
	);

	if (!window)
	{
		glfwTerminate();
		return -1;
	}

	glfwGetFramebufferSize(window, &frameBufferWidth, &frameBufferHeight);
	glViewport(0, 0, frameBufferWidth, frameBufferHeight);
	glfwSetFramebufferSizeCallback(window, frameBufferResizeCb);

	glfwMakeContextCurrent(window);
	// INIT OPENGL FLAGS
	initGlRenderFlags();

	// INITIALIZE GLEW
	glewExperimental = GL_TRUE;
	if (glewInit() != GLEW_OK) {
		std::cout << "ERROR::MAIN.CPP::GLEW_INIT_FAILED" << "/n";
		glfwTerminate();
	}



	// POINTCLOUD OBJECT
	ShaderProgram pcObjectShader(
		"C:/Users/dhruv/Development/git/lidar-viewer/src/glsl/vertex_core.glsl",
		"C:/Users/dhruv/Development/git/lidar-viewer/src/glsl/fragment_core.glsl"
	);
	PCObject pcObject(
		"C:/Users/dhruv/Development/git/lidar-viewer/data/scans_2.json"
	);
	pcObject.attachShaders(pcObjectShader.programID);
	pcObject.setupGLBuffers();
	


	// SLR CAMERA
	ShaderProgram slrObjectShader(
		"C:/Users/dhruv/Development/git/lidar-viewer/src/glsl/object_vs.glsl",
		"C:/Users/dhruv/Development/git/lidar-viewer/src/glsl/object_fs.glsl"
	);
	ObjLoader slrObject(
		"C:/Users/dhruv/Development/git/lidar-viewer/res/slr_camera/slr_camera.obj"
	);
	slrObject.setupModelMatrix();
	slrObject.attachShaders(slrObjectShader.programID);
	slrObject.setupGLBuffers();

	// CAMERA
	camera = Camera(
		camUpVector, camFrontVector, camPosVector,
		fov, frameBufferWidth, frameBufferHeight, near, far
	);

	

	slrCamera = Camera(
		camUpVector, 
		glm::vec3(-0.75f, -0.75f, 0.0f), 
		glm::vec3(-0.75f, -0.75f, 0.0f),
		fov, frameBufferWidth, frameBufferHeight, near, far
	);
	
	pcObjectShader.useProgram();
	pcObjectShader.setMat4("viewMatrix", camera.viewMatrix);
	pcObjectShader.setMat4("projectionMatrix", camera.projectionMatrix);
	
	while (!glfwWindowShouldClose(window))
	{
		currentTime = glfwGetTime();
		deltaTime = currentTime - lastTime;

		glfwPollEvents();

		updateInput(window);


		if (deltaTime >= maxPeriod) {
			lastTime = currentTime;

			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

			camera.updateProjectionMatrix();
			camera.updateViewMatrix();

			slrCamera.updateViewMatrix();

			pcObjectShader.useProgram();
			pcObjectShader.setMat4("viewMatrix", camera.viewMatrix);
			pcObjectShader.setMat4("projectionMatrix", camera.projectionMatrix);
			pcObject.render();
			
			slrObjectShader.useProgram();
			
			slrObjectShader.setVec3("lightColor", glm::vec3(1.0f, 1.0f, 1.0f));
			slrObjectShader.setVec3("objectColor", glm::vec3(0.75f, 0.75f, 1.0f));
			slrObjectShader.setVec3("lightPosition", glm::vec3(-0.75f, -0.75f, -1.0f));


			slrObjectShader.setMat4("modelMatrix", slrObject.modelMatrix);
			slrObjectShader.setMat4("viewMatrix", slrCamera.viewMatrix);
			slrObjectShader.setMat4("projectionMatrix", slrCamera.projectionMatrix);

			slrObject.render();
		}

		display(window);

	}

	glfwDestroyWindow(window);
	glfwTerminate();
	
	glDeleteVertexArrays(1, &pcObject.VAO);
	glDeleteBuffers(1, &pcObject.VBO);
	glDeleteProgram(pcObjectShader.programID);
	
	glDeleteVertexArrays(1, &slrObject.VAO);
	glDeleteBuffers(1, &slrObject.VBO);
	glDeleteProgram(slrObjectShader.programID);

	return 0;
}