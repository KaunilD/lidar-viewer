cmake_minimum_required (VERSION 3.8)
set( CMAKE_CXX_STANDARD 11 )
project( lidar-viewer )

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/")

set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

add_subdirectory("glfw-3.3/glfw-3.3")

find_package(OpenGL REQUIRED)

include_directories("glew-2.1.0/include")
include_directories("glm")
link_directories("glew-2.1.0/lib/Release/x64/")


# BOOST
set(Boost_DEBUG				ON)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_LIBS	ON)
set(BOOST_ROOT "C:/boost_1_60_0")
set(BOOST_LIBRARYDIR "C:/boost_1_60_0/stage/lib")
set(BOOST_INCLUDEDIR "C:/boost_1_60_0/build/install/include/boost-1_60")
include_directories(${BOOST_INCLUDEDIR})
find_package( Boost 1.60 COMPONENTS system filesystem REQUIRED )


add_executable(
	lidar-viewer
	"src/main.cpp"
	"src/shaderprogram.cpp"
	"src/objloader.cpp"
	"src/camera.cpp"
	"src/pcobject.cpp"

)

target_link_libraries(lidar-viewer glew32)

target_include_directories(
	lidar-viewer PUBLIC ${OPENGL_INCLUDE_DIR} "src/"
)

target_link_libraries( 
	lidar-viewer glfw ${OPENGL_gl_LIBRARY}
	${Boost_FILESYSTEM_LIBRARY} ${Boost_SYSTEM_LIBRARY} ${Boost_REGEX_LIBRARY} ${BOOST_LIBRARIES}

)

set_target_properties(lidar-viewer PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib" )
set_target_properties(lidar-viewer PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib" )
set_target_properties(lidar-viewer PROPERTIES ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib" )
set_target_properties(lidar-viewer PROPERTIES OUTPUT_NAME "${PLUGIN_OUTPUT_FILENAME}")