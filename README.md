# SM2-FPGA

**FPGA arithmetic core for the SM2 elliptic curve (GB/T 32918)**

> **SM2** is the Chinese national standard for public-key cryptography based on elliptic curves. This repository currently contains the FPGA-side 256-bit modular arithmetic and point-operation building blocks used by the SM2 curve. It is not a complete SM2 encryption, signature, or key-exchange implementation.

## Target Board

| Board | Chip | Package | Speed |
|-------|------|---------|-------|
| RK-ZYNQ7100-F | XC7Z100 | FFG900 | -2 |

Tested with **Vivado 2023.1**.

## Repository Structure

```
SM2-FPGA/
├── rtl/                # RTL implementation (SystemVerilog)
├── sim/                # Simulation testbenches and board-level demo top
├── ip/                 # Vivado IP core configurations
├── constr/             # Pin & timing constraints
├── scripts/            # Project recreation scripts
├── LICENSE             # MIT License
└── README.md
```

## Current Progress

### Implemented

- [x] **mod_adder_256b** - 256-bit modular adder
- [x] **mod_subtracter_256b** - 256-bit modular subtracter
- [x] **mul_256b** - 256-bit multiplier
- [x] **mont_mul_256b** - 256-bit Montgomery multiplier (core of ECC)
- [x] **c1_cal** - SM2 curve point-operation datapath used by the C1 calculation experiment
- [x] **c1_test** - RK-ZYNQ7100-F board-level demo top for `c1_cal`

### TODO

- [ ] Complete/generalized SM2 scalar multiplication flow
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

```bash
git clone git@github.com:chusan086/SM2-FPGA.git
cd SM2-FPGA/scripts
vivado -source create_project.tcl
```

Or open Vivado, in the Tcl Console:

```tcl
cd <path-to>/SM2-FPGA/scripts
source create_project.tcl
```

The script will create `build/sm2_prj1/` under the repository root with the full Vivado project.

### Run Simulation

In Vivado, set the desired testbench as top (under Simulation Sources) and run simulation. Each module has a corresponding testbench in `sim/`.

## Development Notes

- All RTL written in **SystemVerilog**
- The core ECC arithmetic uses **Montgomery multiplication** for efficient modular reduction
- Designed for Xilinx 7-series FPGAs, easily portable to other families

---

## SM2-FPGA (中文说明)

**面向 SM2 椭圆曲线的 FPGA 算术核心 (GB/T 32918)**

当前仓库主要包含 SM2 曲线所需的 256-bit 模运算和点运算硬件模块，以及面向 RK-ZYNQ7100-F 的实验顶层。它还不是完整的 SM2 加密、签名或密钥交换协议实现。

## 目标平台

| 开发板 | 芯片 | 封装 | 速度等级 |
|--------|------|------|----------|
| RK-ZYNQ7100-F | XC7Z100 | FFG900 | -2 |

使用 **Vivado 2023.1** 开发测试。

## 项目结构

```
SM2-FPGA/
├── rtl/                # RTL 实现代码 (SystemVerilog)
├── sim/                # 仿真测试文件和板级实验顶层
├── ip/                 # Vivado IP 核配置文件
├── constr/             # 管脚及时序约束
├── scripts/            # 工程重建脚本
├── LICENSE             # MIT 许可证
└── README.md
```

## 当前进度

### 已完成

- [x] **mod_adder_256b** - 256-bit 模加法器
- [x] **mod_subtracter_256b** - 256-bit 模减法器
- [x] **mul_256b** - 256-bit 乘法器
- [x] **mont_mul_256b** - 256-bit Montgomery 模乘器（ECC 核心运算）
- [x] **c1_cal** - C1 计算实验使用的 SM2 曲线点运算数据通路
- [x] **c1_test** - 面向 RK-ZYNQ7100-F 的 `c1_cal` 板级实验顶层

### 待实现

- [ ] 完整/通用化的 SM2 标量乘法流程
- [ ] SM2 密钥生成
- [ ] SM2 加密/解密
- [ ] SM2 签名/验签
- [ ] AXI 接口集成
- [ ] Zynq PS-PL 联调演示

## 使用方式

### 重建 Vivado 工程

```bash
git clone git@github.com:chusan086/SM2-FPGA.git
cd SM2-FPGA/scripts
vivado -source create_project.tcl
```

或在 Vivado Tcl Console 中：

```tcl
cd <路径>/SM2-FPGA/scripts
source create_project.tcl
```

脚本会在仓库根目录下创建 `build/sm2_prj1/` 文件夹，包含完整的 Vivado 工程。

### 运行仿真

在 Vivado 的 Simulation Sources 中选择对应的 testbench 作为顶层文件，运行仿真。每个模块在 `sim/` 中都有对应的 testbench 文件。

## 开发说明

- 所有 RTL 使用 **SystemVerilog** 编写
- ECC 核心运算采用 **Montgomery 模乘** 实现高效模约减
- 基于 Xilinx 7 系列 FPGA 设计，可移植到其他系列
