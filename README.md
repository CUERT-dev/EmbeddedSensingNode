# EmbeddedSensingNode

Firmware for the Sensing node of the CUERT car: an STM32G431 that reads the car sensors and publishes them on CAN to the Jetson and the Actuating node. Its sibling repository is the Actuating repo, which shares the same layout, tooling, and workflow.

Target board: NUCLEO-G431RB. Current state: blinks the on-board LED (LD2, PA5) every 500 ms.

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
git checkout develop
cmake --preset release
cmake --build --preset release
```

The build produces `build/sensing.elf`, `build/sensing.bin`, and `build/sensing.map`. Connect the Nucleo over USB and flash with:

```bash
./scripts/flash.sh
```

Success looks like the green LD2 LED blinking twice per second.

## Development workflow

1. Take an issue in Linear and move it from Todo to In Progress.
2. Branch from `develop` using `feature/<issue-id>-<short-name>`, for example `feature/EMB-30-as5600-driver`.
3. Commit with Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`).
4. Run `clang-format -i` on changed files and build locally before pushing.
5. Open a pull request into `develop`. CI must be green and one reviewer must approve.
6. Merges are squash-only. `main` is updated from `develop` by pull request at each milestone.
7. Move the Linear issue to Done after the merge.

Repository rules, applied by `scripts/setup-repo.sh`: `main` and `develop` are protected, direct pushes and force pushes are blocked, pull requests need one approval, the `format` and `build` checks must pass, conversations must be resolved, and history stays linear.

## CI

`.github/workflows/ci.yml` runs on every push and pull request to `main` and `develop`:

- `format`: clang-format check on all C sources.
- `build`: CMake and Ninja build with `arm-none-eabi-gcc`, warnings as errors, then uploads the ELF, BIN, and map as the `sensing-firmware` artifact.

## Folder guide

| Folder | Purpose |
|---|---|
| `app/` | Application entry point and RTOS tasks (acquisition, fusion, CAN publishing) |
| `bsp/` | Board support: clocks, GPIO, LED, delays, pin map for the Nucleo and the final PCB |
| `drivers/` | One driver per sensor (AS5600, TLE4922, GNSS1A1, LTS2MDLTR, ASM330LHHTR, ADC sensors) |
| `middleware/` | CAN protocol definitions, RTOS wrappers, sensor fusion and filtering |
| `platform/` | Startup code and linker script for STM32G431RB |
| `tests/` | Host-side unit tests for logic that does not touch hardware |
| `docs/` | Architecture notes, CAN message map, wiring tables |
| `scripts/` | `flash.sh` for programming, `setup-repo.sh` for branches and protection rules |
| `cmake/` | Arm GCC toolchain file |
| `.github/` | CI workflow, pull request template, code owners |

## Working with an AI assistant

Give the assistant this README and the shared setup PDF. Layer rules: `app` may call `middleware`, `drivers`, and `bsp`; `drivers` may call `bsp` only; `bsp` touches registers directly. Code is comment-free and formatted by `.clang-format`; every change must pass `cmake --build --preset release` with zero warnings.
