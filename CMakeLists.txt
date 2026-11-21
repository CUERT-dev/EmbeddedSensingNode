cmake_minimum_required(VERSION 3.22)
project(sensing C ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(MCU_FLAGS -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard)

add_executable(${PROJECT_NAME})
set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".elf")

add_subdirectory(cmake/stm32cubemx)
target_link_libraries(${PROJECT_NAME} stm32cubemx)

target_compile_options(STM32_Drivers PRIVATE
    ${MCU_FLAGS} -Os -g3 -ffunction-sections -fdata-sections
)
target_compile_options(${PROJECT_NAME} PRIVATE
    ${MCU_FLAGS} -Wall -Wextra -Werror -Os -g3
    -ffunction-sections -fdata-sections
)
target_link_options(${PROJECT_NAME} PRIVATE
    ${MCU_FLAGS}
    -T${CMAKE_CURRENT_SOURCE_DIR}/STM32G431xx_FLASH.ld
    --specs=nano.specs
    -Wl,--gc-sections -Wl,-Map=${PROJECT_NAME}.map
)
set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY
    LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/STM32G431xx_FLASH.ld
)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}>
)
