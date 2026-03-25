include_directories(../)

find_package(Qt6 REQUIRED COMPONENTS Core Test Gui)

function(add_gcs_test target_name)
    add_executable(${target_name} ${ARGN})

    target_include_directories(${target_name} PRIVATE
        ${CMAKE_SOURCE_DIR}/GCS
        ${CMAKE_SOURCE_DIR}/tests
    )

    target_link_libraries(${target_name} PRIVATE
        Qt6::Core
        Qt6::Test
        Qt6::Gui
    )

    add_test(NAME ${target_name} COMMAND ${target_name})
endfunction()

add_gcs_test(test_uavmission
    test_uavmission.cpp
    ${CMAKE_SOURCE_DIR}/uavmission.cpp
    ${CMAKE_SOURCE_DIR}/DroneClass.cpp
)

add_gcs_test(test_droneclass
    test_droneclass.cpp
    ${CMAKE_SOURCE_DIR}/DroneClass.cpp
)
