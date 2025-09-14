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
