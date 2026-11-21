#!/usr/bin/env bash
set -euo pipefail
openocd -f interface/stlink.cfg -f target/stm32g4x.cfg -c "program build/sensing.elf verify reset exit"
