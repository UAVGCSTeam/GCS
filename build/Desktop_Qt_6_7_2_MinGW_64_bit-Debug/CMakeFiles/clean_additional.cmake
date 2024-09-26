# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\GCS_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\GCS_autogen.dir\\ParseCache.txt"
  "GCS_autogen"
  )
endif()
