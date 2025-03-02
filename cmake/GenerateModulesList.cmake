# Write modules list to file
set(SS4S_MODULES_INI_OUTPUT_FILE "${SS4S_MODULE_LIBRARY_OUTPUT_DIRECTORY}/ss4s_modules.ini"
        CACHE FILEPATH "Path of generated modules index file")

file(WRITE "${SS4S_MODULES_INI_OUTPUT_FILE}" "; Generated File - DO NOT EDIT\n")
foreach (SS4S_MODULE_TARGET ${SS4S_MODULE_TARGETS})
    get_target_property(_NAME ${SS4S_MODULE_TARGET} SS4S_MODULE_NAME)
    get_target_property(_GROUP ${SS4S_MODULE_TARGET} SS4S_MODULE_GROUP)
    get_target_property(_DISPLAY_NAME ${SS4S_MODULE_TARGET} SS4S_MODULE_DISPLAY_NAME)
    get_target_property(_FOR_AUDIO ${SS4S_MODULE_TARGET} SS4S_MODULE_FOR_AUDIO)
    get_target_property(_FOR_VIDEO ${SS4S_MODULE_TARGET} SS4S_MODULE_FOR_VIDEO)
    get_target_property(_WEIGHT ${SS4S_MODULE_TARGET} SS4S_MODULE_WEIGHT)
    get_target_property(_CONFLICTS ${SS4S_MODULE_TARGET} SS4S_MODULE_CONFLICTS)
    get_target_property(_OS_VERSION ${SS4S_MODULE_TARGET} SS4S_MODULE_OS_VERSION)


    file(APPEND "${SS4S_MODULES_INI_OUTPUT_FILE}" "[${_NAME}]\n")
    file(APPEND "${SS4S_MODULES_INI_OUTPUT_FILE}" "name = ${_DISPLAY_NAME}\n")
    if (_GROUP AND NOT ${_GROUP} STREQUAL "${_NAME}")
        file(APPEND "${SS4S_MODULES_INI_OUTPUT_FILE}" "group = ${_GROUP}\n")
    endif()
    if (_FOR_AUDIO)
        file(APPEND "${SS4S_MODULES_INI_OUTPUT_FILE}" "audio = true\n")
    endif ()
    if (_FOR_VIDEO)
        file(APPEND "${SS4S_MODULES_INI_OUTPUT_FILE}" "video = true\n")
    endif ()
    file(APPEND "${SS4S_MODULES_INI_OUTPUT_FILE}" "weight = ${_WEIGHT}\n")
    if (_CONFLICTS)
        string(REPLACE ";" "," _CONFLICTS "${_CONFLICTS}")
        file(APPEND "${SS4S_MODULES_INI_OUTPUT_FILE}" "conflicts = ${_CONFLICTS}\n")
    endif ()
    if (_OS_VERSION)
        file(APPEND "${SS4S_MODULES_INI_OUTPUT_FILE}" "os_version = ${_OS_VERSION}\n")
    endif ()
    file(APPEND "${SS4S_MODULES_INI_OUTPUT_FILE}" "\n")
endforeach ()

if (CMAKE_INSTALL_LIBDIR)
    install(FILES ${SS4S_MODULES_INI_OUTPUT_FILE} DESTINATION ${CMAKE_INSTALL_LIBDIR})
endif ()