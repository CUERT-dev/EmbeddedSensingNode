# EmbeddedSensingNode

Firmware for the Sensing node of the CUERT car: an STM32G431 that reads the car sensors and publishes them on CAN to the Jetson and the Actuating node. Its sibling repository is the Actuating repo, which shares the same layout, tooling, and workflow.

Target board: NUCLEO-G431RB (STM32G431RBT6). Current state: blinks the on-board LED (LD2, PA5) every 500 ms.

## Sensors owned by this node

| Parameter | Part |
|---|---|
| Motor speed before gearbox | AS5600 encoder |
| Wheel speed | TLE4922 |
| Position and speed (100 ms) | GNSS1A1 shield |
| Compass | LTS2MDLTR |
| IMU | ASM330LHHTR |
| Steering rack position | Potentiometer |
| Voltage, current, temperature | Analog sensors |
| Connectivity | Wi-Fi module |

## Installation

Linux (Ubuntu 22.04 or newer) or WSL2:

```bash
sudo apt-get update
sudo apt-get install -y git gcc-arm-none-eabi cmake ninja-build clang-format openocd
```

Windows and macOS users can install the same four tools: Arm GNU Toolchain 12 or newer, CMake 3.22 or newer, Ninja, and OpenOCD. VS Code with the CMake Tools and Cortex-Debug extensions is the recommended editor.

## Setup

```bash
git clone https://github.com/CUERT-dev/EmbeddedSensingNode.git
cd EmbeddedSensingNode
git checkout Developing
cmake --preset release
cmake --build --preset release
```

The build produces `build/sensing.elf`, `build/sensing.bin`, and `build/sensing.map`. Connect the Nucleo over USB and flash with:

```bash
./scripts/flash.sh
```

The green LD2 LED changes state every 500 ms, completing one on/off cycle per second.

## Branches

| Branch | Content | Receives PRs from |
|---|---|---|
| `Developing` | Active development, blink firmware lives here | `Feature/*`, `Fix/*`, `Docs/*`, `Chore/*`, and `GeneratingTheProject` |
| `Testing` | Code under hardware and integration testing | `Developing` only |
| `Validating` | Verified code ready for hand-over to the team | `Testing` only |

Code moves in one direction: feature branch, then `Developing`, then `Testing`, then `Validating`. The `flow` CI check rejects any pull request that skips a stage.

## Development workflow

1. Take an issue in Linear and move it from Todo to In Progress.
2. Branch from `Developing` using `Feature/<issue-id>-<short-name>` or `Fix/<issue-id>-<short-name>`, for example `Feature/EMB-30-as5600-driver`.
3. Commit with Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`).
4. Run `clang-format -i` on changed files and build locally before pushing.
5. Open a pull request into `Developing`. CI must be green and one reviewer must approve.
6. When a feature set is ready for hardware testing, open a pull request from `Developing` into `Testing`, then from `Testing` into `Validating` after it passes. Use merge commits for these promotions so the branches stay in step.
7. Move the Linear issue to Done after the merge into `Developing`, or after `Validating` if the issue requires validation.

Nobody pushes directly to `Developing`, `Testing`, or `Validating`. Every change goes through a pull request with a green CI run and approval.

Repository rules are applied by `scripts/setup-repo.sh`: the three branches are protected, direct and force pushes are blocked, pull requests need approval, the `format`, `build`, and `flow` checks must pass, and conversations must be resolved.

## CI

`.github/workflows/ci.yml` runs on pushes and pull requests to `Developing`, `Testing`, and `Validating`:

- `flow`: rejects pull requests that break the branch order.
- `format`: clang-format check on all C sources.
- `build`: CMake and Ninja build with `arm-none-eabi-gcc`, warnings as errors, then uploads the ELF, BIN, and map as the `sensing-firmware` artifact.

## Repository layout

### Root files

| File | Purpose |
|---|---|
| `CMakeLists.txt` | Top-level CMake build for the firmware |
| `CMakePresets.json` | Configure and build presets, including `release` |
| `EmbeddedSensingNode.ioc` | STM32CubeMX project: pin map, clocks, and peripheral configuration |
| `.mxproject` | STM32CubeMX project metadata |
| `startup_stm32g431xx.s` | CubeMX-generated startup assembly for the STM32G431 |
| `STM32G431xx_FLASH.ld` | CubeMX-generated linker script for the STM32G431 |
| `.clang-format` | Formatting rules enforced by the `format` check |
| `.editorconfig` | Editor indentation and line-ending defaults |
| `.gitattributes` | Line-ending and diff handling for repository files |
| `.gitignore` | Build outputs and local files kept out of Git |
| `README.md` | This file |

### Folders

| Folder | Content | Purpose |
|---|---|---|
| `Core/` | `Inc/`, `Src/` | STM32CubeMX initialization, interrupt handlers, and the application entry point in `Core/Src/main.c` |
| `drivers/` | `BSP/`, `CMSIS/`, `STM32G4xx_HAL_Driver/`, `.gitkeep` | ST vendor code copied in by STM32CubeMX; sensor drivers are added here one per sensor |
| `middleware/` | `.gitkeep` | Reserved for CAN protocol definitions, RTOS wrappers, sensor fusion and filtering |
| `platform/` | `startup.c`, `STM32G431RBTx_FLASH.ld` | Bare-metal startup code and linker script for the STM32G431RB |
| `tests/` | `.gitkeep` | Reserved for host-side unit tests of logic that does not touch hardware |
| `docs/` | `.gitkeep` | Reserved for architecture notes, the CAN message map, and wiring tables |
| `scripts/` | `flash.sh`, `setup-repo.sh` | `flash.sh` programs the board, `setup-repo.sh` applies the branch protection rules |
| `cmake/` | `arm-none-eabi.cmake`, `gcc-arm-none-eabi.cmake`, `starm-clang.cmake`, `stm32cubemx/` | Toolchain files for Arm GNU and ST Clang, plus CubeMX-generated CMake sources |
| `EWARM/` | `EmbeddedSensingNode.ewd`, `.ewp`, `Project.eww`, `startup_stm32g431xx.s`, `stm32g431xx_flash.icf`, `stm32g431xx_sram.icf` | IAR Embedded Workbench project generated by CubeMX |
| `.github/` | `CODEOWNERS`, `pull_request_template.md`, `workflows/` | Code owners, pull request template, and the CI workflow |

Files under `drivers/BSP`, `drivers/CMSIS`, `drivers/STM32G4xx_HAL_Driver`, `cmake/stm32cubemx`, and `EWARM` are produced by STM32CubeMX. Change the `.ioc` and regenerate instead of editing them by hand.

## Working with an AI assistant

Give the assistant this README and the shared setup PDF. Layer rules: the application may call `middleware` and `drivers`; `drivers` reach the hardware through the CubeMX HAL. Code is comment-free and formatted by `.clang-format`; every change must pass `cmake --build --preset release` with zero warnings.
