cmake_minimum_required(VERSION 3.22)
project(sensing C ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(MCU_FLAGS -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard)

file(GLOB_RECURSE SOURCES
    app/*.c
    bsp/*.c
    middleware/*.c
    platform/*.c
)

add_executable(${PROJECT_NAME}.elf ${SOURCES})

target_include_directories(${PROJECT_NAME}.elf PRIVATE app bsp drivers middleware platform)
target_compile_definitions(${PROJECT_NAME}.elf PRIVATE STM32G431xx)
target_compile_options(${PROJECT_NAME}.elf PRIVATE
    ${MCU_FLAGS} -Wall -Wextra -Werror -Os -g3
    -ffreestanding -fno-tree-loop-distribute-patterns
    -ffunction-sections -fdata-sections
)
target_link_options(${PROJECT_NAME}.elf PRIVATE
    ${MCU_FLAGS}
    -T${CMAKE_SOURCE_DIR}/platform/STM32G431RBTx_FLASH.ld
    -Wl,--gc-sections -Wl,-Map=${PROJECT_NAME}.map
    -nostdlib -lgcc
)

add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}.elf> ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}.elf>
)
