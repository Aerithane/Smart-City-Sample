set(service "docker_swarm")
set(build_options ${NOFFICES} ${PLATFORM})
include("${CMAKE_SOURCE_DIR}/script/service.cmake")
include("${CMAKE_SOURCE_DIR}/script/deployment.cmake")
set(service "docker_compose")
include("${CMAKE_SOURCE_DIR}/script/service.cmake")
include("${CMAKE_SOURCE_DIR}/script/deployment.cmake")
