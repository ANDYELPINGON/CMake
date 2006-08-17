#########################################################################
# Setup release scripts.

IF(WIN32)
  FIND_PROGRAM(NSIS_MAKENSIS NAMES makensis
    PATHS [HKEY_LOCAL_MACHINE\\SOFTWARE\\NSIS]
    DOC "Where is makensis.exe located"
    )
  MARK_AS_ADVANCED(NSIS_MAKENSIS)
  FIND_PROGRAM(WINZIP_WZZIP NAMES wzzip
    PATHS   "C:/Program Files/WinZip"
    DOC "Where is makensis.exe located"
    )
  MARK_AS_ADVANCED(WINZIP_WZZIP)
  STRING(REGEX REPLACE "/" "\\\\" CMake_INSTALL_TOP "${CMAKE_INSTALL_PREFIX}")
  SET(NSIS_EXTRA_COMMANDS ";Include system runtime libraries.\n  SetOutPath \"$INSTDIR\\bin\"\n")
  FOREACH(lib ${CMake_INSTALL_SYSTEM_RUNTIME_LIBS})
    STRING(REGEX REPLACE "/" "\\\\" LIB "${lib}")
    SET(NSIS_EXTRA_COMMANDS "${NSIS_EXTRA_COMMANDS}  File \"${LIB}\"\n")
  ENDFOREACH(lib)
  CONFIGURE_FILE(
    ${PROJECT_SOURCE_DIR}/Utilities/Release/${PROJECT_NAME}.nsi.in
    ${PROJECT_BINARY_DIR}/Utilities/Release/${PROJECT_NAME}.nsi 
    IMMEDIATE @ONLY)
  CONFIGURE_FILE(
    ${PROJECT_SOURCE_DIR}/Utilities/Release/cmake_release.sh.in
    ${PROJECT_BINARY_DIR}/Utilities/Release/cmake_release.sh 
    IMMEDIATE @ONLY)
ENDIF(WIN32)

CONFIGURE_FILE(
  ${PROJECT_SOURCE_DIR}/Utilities/Release/MakeRelease.cmake.in
  ${PROJECT_BINARY_DIR}/Utilities/Release/MakeRelease.cmake
  IMMEDIATE @ONLY)

IF (NSIS_MAKENSIS AND WINZIP_WZZIP)
  # build the NSI
  ADD_CUSTOM_TARGET( release
    ${CMAKE_COMMAND} -DBUILD_NSIW=1 -DCOMMIT_UNIX_SCRIPT=1 -DTAG_TREE=1 -DBUILD_WINZIP=1
    -P ${PROJECT_BINARY_DIR}/Utilities/Release/MakeRelease.cmake
    )
  ADD_CUSTOM_TARGET( release_nsiw
    ${CMAKE_COMMAND} -DBUILD_NSIW=1 
    -P ${PROJECT_BINARY_DIR}/Utilities/Release/MakeRelease.cmake
    )
  ADD_CUSTOM_TARGET( release_winzip
    ${CMAKE_COMMAND} -DBUILD_WINZIP=1 
    -P ${PROJECT_BINARY_DIR}/Utilities/Release/MakeRelease.cmake
    )
ENDIF (NSIS_MAKENSIS AND WINZIP_WZZIP)

ADD_CUSTOM_TARGET( release_commit_unix
  ${CMAKE_COMMAND} -DCOMMIT_UNIX_SCRIPT=1 
  -P ${PROJECT_BINARY_DIR}/Utilities/Release/MakeRelease.cmake
  )
ADD_CUSTOM_TARGET( release_tag
  ${CMAKE_COMMAND} -DTAG_TREE=1 
  -P ${PROJECT_BINARY_DIR}/Utilities/Release/MakeRelease.cmake
  )
ADD_CUSTOM_TARGET( release_tar
  ${CMAKE_COMMAND} -DBUILD_TAR=1 
  -P ${PROJECT_BINARY_DIR}/Utilities/Release/MakeRelease.cmake
  )
