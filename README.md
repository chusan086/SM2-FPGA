# SM2-FPGA

**FPGA implementation of SM2 elliptic curve cryptography (GB/T 32918)**

> **SM2** is the Chinese national standard for public-key cryptography based on elliptic curves. This project implements the core 256-bit modular arithmetic units required for SM2 on FPGA.

## Target Board

| Board | Chip | Package | Speed |
|-------|------|---------|-------|
| RK-ZYNQ7100-F | XC7Z100 | FFG900 | -2 |

Tested with **Vivado 2023.1**.

## Repository Structure

`
SM2-FPGA/
??? rtl/                # RTL implementation (SystemVerilog)
??? sim/                # Simulation testbenches
??? ip/                 # Vivado IP core configurations
??? constr/             # Pin & timing constraints
??? scripts/            # Project recreation scripts
??? LICENSE             # MIT License
??? README.md
`

## Current Progress

### Implemented

- [x] **mod_adder_256b** - 256-bit modular adder
- [x] **mod_subtracter_256b** - 256-bit modular subtracter
- [x] **mul_256b** - 256-bit multiplier
- [x] **mont_mul_256b** - 256-bit Montgomery multiplier (core of ECC)
- [x] **c1_cal** - SM2 point addition & doubling

### TODO

- [ ] SM2 scalar multiplication
- [ ] SM2 key generation
- [ ] SM2 encryption / decryption
- [ ] SM2 signature & verification
- [ ] AXI interface integration
- [ ] Zynq PS-PL demo

## Getting Started

### Prerequisites

- Vivado 2023.1 (or compatible)
- RK-ZYNQ7100-F board (or any XC7Z100-based board)

### Recreate the Vivado Project

`ash
git clone git@github.com:chusan086/SM2-FPGA.git
cd SM2-FPGA/scripts
vivado -source create_project.tcl
`

Or open Vivado, in the Tcl Console:

`	cl
cd <path-to>/SM2-FPGA/scripts
source create_project.tcl
`

The script will create a sm2_prj1/ directory next to scripts/ with the full Vivado project.

### Run Simulation

In Vivado, set the desired testbench as top (under Simulation Sources) and run simulation. Each module has a corresponding testbench in sim/.

## Development Notes

- All RTL written in **SystemVerilog**
- The core ECC arithmetic uses **Montgomery multiplication** for efficient modular reduction
- Designed for Xilinx 7-series FPGAs, easily portable to other families

---

## SM2-FPGA

**SM2 ???????? FPGA ?? (GB/T 32918)**

## ????

| ??? | ?? | ?? | ???? |
|--------|------|------|----------|
| RK-ZYNQ7100-F | XC7Z100 | FFG900 | -2 |

?? **Vivado 2023.1** ?????

## ????

`
SM2-FPGA/
??? rtl/                # RTL ???? (SystemVerilog)
??? sim/                # ??????
??? ip/                 # Vivado IP ?????
??? constr/             # ???????
??? scripts/            # ??????
??? LICENSE             # MIT ???
??? README.md
`

## ????

### ???

- [x] **mod_adder_256b** - 256-bit ????
- [x] **mod_subtracter_256b** - 256-bit ????
- [x] **mul_256b** - 256-bit ???
- [x] **mont_mul_256b** - 256-bit Montgomery ????ECC ?????
- [x] **c1_cal** - SM2 ?? / ????

### ???

- [ ] SM2 ????
- [ ] SM2 ????
- [ ] SM2 ??/??
- [ ] SM2 ??/??
- [ ] AXI ????
- [ ] Zynq PS-PL ????

## ????

### ?? Vivado ??

`ash
git clone git@github.com:chusan086/SM2-FPGA.git
cd SM2-FPGA/scripts
vivado -source create_project.tcl
`

?? Vivado Tcl Console ??

`	cl
cd <??>/SM2-FPGA/scripts
source create_project.tcl
`

???? scripts/ ?????? sm2_prj1/ ????????? Vivado ???

### ????

? Vivado ? Simulation Sources ?????? testbench ????????????????? sim/ ?????? testbench ???

## ????

- ?? RTL ?? **SystemVerilog** ??
- ECC ?????? **Montgomery ??** ???????
- ?? Xilinx 7 ?? FPGA ???????????
