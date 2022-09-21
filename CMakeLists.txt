cmake_minimum_required(VERSION 3.16)

project(BaMaStudio VERSION 0.1 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:__cplusplus /permissive-")
endif()

find_package(Qt6 6.2 COMPONENTS Quick QuickControls2 Xml Svg REQUIRED)


include(FetchContent)
FetchContent_Declare(
  SIUtils
  GIT_REPOSITORY https://github.com/ssakone/SIUtils.git
  GIT_TAG        main
)
FetchContent_MakeAvailable(SIUtils)

include_directories(${SIUtils_SOURCE_DIR}/src)


add_subdirectory(QtWindowsCMake)

qt_add_executable(BaMaStudio
    main.cpp
)

qt_add_qml_module(BaMaStudio
    URI BStudio
    VERSION 1.0
    QML_FILES BStudio/main.qml
              BStudio/Tools/SpriteGenerator.qml
)

target_link_libraries(BaMaStudio
    PRIVATE Qt6::Quick Qt6::Xml Qt6::Svg Qt6::QuickControls2 SIUtils)

if (WIN32)
    add_qt_windows_exe(BaMaStudio
        NAME "BamaStudio"
        OUTPUT_TARGET ${CMAKE_CURRENT_BINARY_DIR}/BamaStudio
        VERSION ${VERSION}
        PUBLISHER "sakone"
        PRODUCT_URL "www.BamaStudio.app"
        PACKAGE "org.sakone.BamaStudio"
        ICON "${CMAKE_CURRENT_SOURCE_DIR}/platforms/windows/favicon.ico"
        ICON_RC "${CMAKE_CURRENT_SOURCE_DIR}/platforms/windows/icon.rc"
        QML_DIR ${CMAKE_CURRENT_SOURCE_DIR}
        NO_OPENGL_SW
    )
endif()
