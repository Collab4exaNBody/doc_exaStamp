cmake_minimum_required(VERSION 3.8)
project(exaStamp_doc VERSION 1.0)

set(OUTPUT_DOC_DIR ${CMAKE_CURRENT_BINARY_DIR}/)



set(TargetName "mkdocs_${PROJECT_NAME}")

# ######################################################
# ######################################################
# ######################################################
# Set the docs directory path
set(DOCS_DIR "${CMAKE_CURRENT_BINARY_DIR}/docs/")
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/docs/ DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/docs/)

# Build the list of all *.md files found in tests directory
set(EXAMPLES_DIR "${CMAKE_SOURCE_DIR}/tests")
file(GLOB_RECURSE EXAMPLE_FILES "${EXAMPLES_DIR}/description.md")
set(EXAMPLE_LIST "")

set(DOCS_EXAMPLES_DIR "Started/Examples")

foreach(EXAMPLE_FILE ${EXAMPLE_FILES})
    get_filename_component(EXAMPLE_NAME ${EXAMPLE_FILE} NAME_WE)
    get_filename_component(EXAMPLE_FILE_DIR ${EXAMPLE_FILE} DIRECTORY)
    string(REPLACE "${EXAMPLES_DIR}" "" EXAMPLE_FILE_DIR ${EXAMPLE_FILE_DIR})
    string(REPLACE "tests" "" EXAMPLE_FILE_DIR ${EXAMPLE_FILE_DIR})
    string(REPLACE "/" " " EXAMPLE_NAV_NAME ${EXAMPLE_FILE_DIR})
    configure_file(${EXAMPLE_FILE} "${DOCS_DIR}/${DOCS_EXAMPLES_DIR}/${EXAMPLE_FILE_DIR}/${EXAMPLE_NAME}.md" COPYONLY)
    set(EXAMPLE_LIST "${EXAMPLE_LIST}\n      - ${EXAMPLE_NAV_NAME}: ${DOCS_EXAMPLES_DIR}/${EXAMPLE_FILE_DIR}/${EXAMPLE_NAME}.md")
endforeach()

# ########################
# # Doc Configuration
# ########################
if(NOT TARGET doc)
  add_custom_target(doc)
endif(NOT TARGET doc)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/mkdocs.yml.cmake ${CMAKE_CURRENT_BINARY_DIR}/mkdocs.yml @ONLY)
add_custom_command(

    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mkdocs.txt
    OUTPUT ${TargetName}

    COMMENT "mkdocs documentation generation for ${PROJECT_NAME}"

    COMMAND mkdocs build
    DEPENDS ${mkConfile}

    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

add_custom_target(${TargetName} DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/mkdocs.txt ${targetName})
add_dependencies(doc ${TargetName})

#######################
## INSTALLATION
#######################
include(GNUInstallDirs)
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/site/ DESTINATION ${PROJECT_NAME}  )
