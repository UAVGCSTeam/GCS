cmake_minimum_required(VERSION 3.16)

project(GCS VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 6.7.3 REQUIRED COMPONENTS Widgets)
# + SerialPort added here
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets Quick QuickWidgets Core Sql SerialPort)

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
        setup_and_run_xbee.py
        XbeeLink.cpp
        XbeeLink.h
        MavlinkSender.cpp
        MavlinkSender.h

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

# MAVLink headers (handle both layouts)
set(MAVLINK_DIR "${CMAKE_SOURCE_DIR}/external/mavlink" CACHE PATH "Path to MAVLink c_library_v2")
target_include_directories(GCS PRIVATE
    ${MAVLINK_DIR}
    ${MAVLINK_DIR}/mavlink
)

target_link_libraries(GCS PRIVATE
Qt${QT_VERSION_MAJOR}::Widgets
Qt${QT_VERSION_MAJOR}::Quick
Qt${QT_VERSION_MAJOR}::QuickWidgets
Qt${QT_VERSION_MAJOR}::Core
Qt${QT_VERSION_MAJOR}::Sql
# + link SerialPort
Qt${QT_VERSION_MAJOR}::SerialPort)

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
