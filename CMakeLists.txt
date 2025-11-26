cmake_minimum_required(VERSION 3.16)

project(GCS VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 REQUIRED COMPONENTS Widgets Quick QuickControls2 QuickWidgets Core Sql)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets Quick QuickControls2 Core QuickWidgets Sql SerialPort)

set(PROJECT_SOURCES
        mainwindow.cpp
        mainwindow.h
        mainwindow.ui
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(GCS
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
        QtMap.qrc
        main.cpp
        mapcontroller.h mapcontroller.cpp
        filehandler.h filehandler.cpp
        backend/dbmanager.h backend/dbmanager.cpp
        droneclass.h droneclass.cpp
        dronecontroller.h dronecontroller.cpp
        xbeeHandler.py
        requirements.txt
        XbeeLink.cpp
        XbeeLink.h
        MavlinkSender.cpp
        MavlinkSender.h
        MavlinkReceiver.h
        MavLinkReceiver.cpp

       # MavLinkUdp.h MavLinkUdp.cpp
    )
else()
    if(ANDROID)
        add_library(GCS SHARED
            ${PROJECT_SOURCES}
        )
    else()
        add_executable(GCS
            ${PROJECT_SOURCES}
        )
    endif()
endif()

# --- MAVLink headers: support prefixed and flat layouts ---
set(_MAV_CANDIDATES
  "${CMAKE_SOURCE_DIR}/external/mavlink"
  "${CMAKE_SOURCE_DIR}/external/mavlink/c_library_v2"
  "${CMAKE_SOURCE_DIR}/external/c_library_v2"
)

unset(MAVLINK_INCLUDE_DIR)
foreach(p IN LISTS _MAV_CANDIDATES)
  if(EXISTS "${p}/mavlink/common/mavlink.h")
    set(MAVLINK_INCLUDE_DIR "${p}")      # prefixed layout
    break()
  elseif(EXISTS "${p}/common/mavlink.h")
    set(MAVLINK_INCLUDE_DIR "${p}")      # flat layout  <-- your case
    break()
  endif()
endforeach()

if(NOT MAVLINK_INCLUDE_DIR)
  message(FATAL_ERROR "MAVLink headers not found. Put c_library_v2 under external/ or pass -DMAVLINK_INCLUDE_DIR=/abs/path")
endif()

message(STATUS "MAVLINK_INCLUDE_DIR = ${MAVLINK_INCLUDE_DIR}")
target_include_directories(GCS PRIVATE "${MAVLINK_INCLUDE_DIR}")



target_link_libraries(GCS PRIVATE
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::QuickControls2
    Qt${QT_VERSION_MAJOR}::QuickWidgets
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Sql
    Qt${QT_VERSION_MAJOR}::SerialPort
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
if(${QT_VERSION} VERSION_LESS 6.1.0)
  set(BUNDLE_ID_OPTION MACOSX_BUNDLE_GUI_IDENTIFIER com.example.GCS)
endif()
set_target_properties(GCS PROPERTIES
    ${BUNDLE_ID_OPTION}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS GCS
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(GCS)
endif()
