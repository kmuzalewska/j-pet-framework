# J-PET framework project main description file
#
# Author: Adam Strzelecki <adam.strzelecki@uj.edu.pl>
#
# Description:
#   Builds all J-PET framework modules using CMake build generator.

cmake_minimum_required(VERSION 2.6)
option(test "Build all tests." OFF)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(JPetFramework-Utilities) # for generate_root_dictionaries

project(JPetFramework CXX) # using only C++
# enable C++11 and warnings
if(NOT MSVC)
  add_definitions(-std=c++11 -Wall -Wunused-parameter)
endif()

foreach(mode QUIET REQUIRED)
  find_package(ROOT 5 ${mode} COMPONENTS
    Hist
    Physics
    RIO
    Thread
    Tree
    )
  if(ROOT_USE_FILE)
    include(${ROOT_USE_FILE})
  endif()
  if(ROOT_FOUND)
    break()
  endif()
  # if we failed with CMake based find_package, use fallback
  # root-config version from cmake/fallback/
  list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/fallback)
endforeach()
include_directories(${ROOT_INCLUDE_DIRS})
add_definitions(${ROOT_DEFINITIONS})
message(STATUS "ROOT version: ${ROOT_VERSION}")
if(ROOT_FOUND AND NOT ROOT_VERSION VERSION_LESS "6.0")
  message(FATAL_ERROR "ROOT 6.0 is not compatible")
endif()

find_package(PQXX REQUIRED)
include_directories(${PQXX_INCLUDE_DIRS})
add_definitions(${PQXX_DEFINITIONS})

find_package(Config++ REQUIRED)
include_directories(${CONFIG++_INCLUDE_DIRS})
add_definitions(${CONFIG++_DEFINITIONS})

if(test)
	find_package(Boost 1.50.0 REQUIRED COMPONENTS
	filesystem
	program_options
	regex
	system
	unit_test_framework
	)
else()
	find_package(Boost 1.50.0 REQUIRED COMPONENTS
	filesystem
	program_options
	regex
	system
	)
endif()
include_directories(${Boost_INCLUDE_DIRS})
add_definitions(${Boost_DEFINITIONS})

get_directory_property(has_parent PARENT_DIRECTORY)
if(has_parent)
  # export ROOT, Boost and pqxx includes to depending projects
  set(Framework_INCLUDE_DIRS
    ${ROOT_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
    ${PQXX_INCLUDE_DIRS}
    PARENT_SCOPE
    )
  set(Framework_DEFINITIONS
    ${ROOT_DEFINITIONS}
    ${Boost_DEFINITIONS}
    ${PQXX_DEFINITIONS}
    PARENT_SCOPE
    )
  # ensure that projects use C++11 too
  if(NOT MSVC)
    set(Framework_DEFINITIONS
      -std=c++11
      ${Framework_DEFINITIONS}
      PARENT_SCOPE
      )
  endif()
  # export ROOT cint needed to generate dictionaries from projects
  set(ROOT_rootcint_CMD   ${ROOT_rootcint_CMD}   PARENT_SCOPE)
  set(rootcint_cmd        ${ROOT_rootcint_CMD}   PARENT_SCOPE)
  set(ROOTCINT_EXECUTABLE ${ROOTCINT_EXECUTABLE} PARENT_SCOPE)
  # export ROOT rpath needed for OS X
  set(ROOT_LIBRARY_DIR    ${ROOT_LIBRARY_DIR}    PARENT_SCOPE)
endif()

# enable rpath on OS X and point it to ROOT
if(APPLE)
  set(CMAKE_MACOSX_RPATH ON)
  set(CMAKE_EXE_LINKER_FLAGS
    "${CMAKE_EXE_LINKER_FLAGS} -Wl,-rpath,${ROOT_LIBRARY_DIR}"
    )
endif()

# use rpath pointing to build directory
set(CMAKE_SKIP_BUILD_RPATH OFF)
set(CMAKE_BUILD_WITH_INSTALL_RPATH OFF)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)

file(GLOB HEADERS JPet*/*.h)
file(GLOB SOURCES JPet*/*.cpp)
generate_root_dictionaries(DICTIONARIES SOURCES ${SOURCES}
  EXCLUDE # exclude following sources from ROOT dictionary
          # everything else will have dictionary generated
  # FIXME: For some reason these are excluded, it should be some better way
  # than writing them down explicitly to tell which file needs dictionary
  # and which not.
  JPetAnalysisRunner
  JPetCmdParser
  JPetDBParamGetter
  JPetManager
  JPetParamManager
  JPetReader
  JPetTask
  JPetTaskIO
  JPetTaskLoader
  JPetTaskExecutor
  JPetScopeReader
  JPetScopeTask
  JPetOptions
  )
add_library(JPetFramework SHARED ${SOURCES} ${HEADERS} ${DICTIONARIES})

# - Unpacker
file(GLOB UNPACKER2_HEADERS JPetUnpacker/Unpacker2/*.h)
file(GLOB UNPACKER2_SOURCES JPetUnpacker/Unpacker2/*.cc)
generate_root_dictionaries(UNPACKER_DICTIONARIES SOURCES ${UNPACKER2_SOURCES}
  INCLUDE # generate ROOT dictionaries for following sources
  Unpacker2
  TDCHit
  ADCHit
  Event
  UnpackingModule
  Unpacker_HPTDC_HR
  Unpacker_HPTDC_VHR
  Unpacker_HUB2
  Unpacker_TRB2
  Unpacker_Shower
  Unpacker_Ecal_ADC
  Unpacker_TRB3
  Unpacker_Lattice_TDC
  )
add_library(Unpacker2 ${UNPACKER2_HEADERS} ${UNPACKER2_SOURCES}
  ${UNPACKER_DICTIONARIES}
  )

# - DBHandler
file(GLOB DBHANDLER_HEADERS DBHandler/HeaderFiles/*.h)
file(GLOB DBHANDLER_SOURCES DBHandler/SourceFiles/*.cpp)
add_library(dbhandler SHARED ${DBHANDLER_HEADERS} ${DBHANDLER_SOURCES})
target_link_libraries(dbhandler
  ${PQXX_LIBRARIES}
  ${CONFIG++_LIBRARIES}
  )

# - tinyxml2
add_library(tinyxml2
  JPetUnpacker/Unpacker2/tinyxml2-master/tinyxml2.h
  JPetUnpacker/Unpacker2/tinyxml2-master/tinyxml2.cpp
  )

# add dependencies
target_link_libraries(JPetFramework
  Unpacker2
  tinyxml2
  dbhandler
  ${ROOT_LIBRARIES}
  ${Boost_LIBRARIES}
  )
if(test)
        add_subdirectory(tests)
endif()

# extra files, so they are visible in your editor
file(GLOB EXTRAS extras/**)
add_custom_target(extra SOURCES ${EXTRAS}
  README
  Doxyfile
  tests/README
  tests/run_tests.pl
  )

# make clang print colored diagnostics when invoked from Ninja
if(UNIX AND
   CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND
   CMAKE_GENERATOR STREQUAL "Ninja")
  add_definitions(-fcolor-diagnostics)
endif()

# workaround: relocation R_X86_64_32S against `...' can not be used when
# making a shared object
if(UNIX AND CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
  set_target_properties(Unpacker2 tinyxml2 PROPERTIES COMPILE_FLAGS "-fPIC")
endif()