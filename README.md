## SM2-FPGA

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
├── LICENSE             # MIT 许可证
└── README.md
```


## 开发说明

- 所有 RTL 使用 **SystemVerilog** 编写
- ECC 核心运算采用 **Montgomery 模乘** 实现高效模约减
- 基于 Xilinx 7 系列 FPGA 设计，可移植到其他系列
