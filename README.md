# FPGA-Based-Real-Time-Torque-Calculation-Accelerator
Mud Viscosity and torque calculation using TorqCalc_IP, FIFO, DSP IP, DMA IP and BRAM

## Project Description

This project implements a custom FPGA-based hardware accelerator for real-time torque calculation, designed for integration with a Zynq SoC using Xilinx Vivado. The design leverages AXI interfaces, a custom DSP pipeline, a stream FIFO, and on-chip Block RAM to process streaming sensor data with low latency, making it suitable for industrial control and monitoring applications.

## Block Diagram

<img width="1070" alt="image" src="https://github.com/user-attachments/assets/04ab3dbe-e5b2-45e7-8b25-d22bf5abd57e" />


## Block Diagram Overview

-   **Zynq Processing System (PS):** Acts as the system controller, managing configuration and data transfer between software and programmable logic (PL).
-   **AXI DMA:** Facilitates high-throughput data movement between the PS and PL via AXI-Stream interfaces.
-   **Custom IP (TorqCalc\_IP):** Core hardware accelerator that receives sensor data, performs real-time torque calculation using a DSP48 slice, and outputs the result as an AXI-Stream.
-   **AXI Interconnect:** Connects the PS, DMA, and custom IP, ensuring seamless communication across AXI interfaces.
-   **AXI Stream FIFO (\`axis\_data\_fifo\_0\`):** Provides temporary buffering for the incoming sensor data stream, accommodating potential rate mismatches between the data source and the processing pipeline.
-   **AXI BRAM Controller (\`axi\_bram\_ctrl\_0\`):** Enables access to Block RAM (BRAM) for storing calibration data, filter coefficients, or intermediate calculation results.
-   **Block Memory Generator (\`blk\_mem\_gen\_0\`):** Implements the on-chip BRAM, providing fast, local memory storage.

## IP Blocks Used

-   **ZYNQ7 Processing System**
-   **AXI DMA**
-   **TorqCalc\_IP (Custom IP):**
    -   *S00\_AXI*: AXI4-Lite slave for register/configuration access.
    -   *S00\_AXIS*: AXI4-Stream slave for receiving input data.
    -   *M00\_AXIS*: AXI4-Stream master for outputting processed results.
    -   *DSP48* (inside TorqCalc\_IP): Performs high-speed multiply-accumulate for torque computation.
-   **AXI Stream FIFO (\`axis\_data\_fifo\_0\`)**
-   **AXI BRAM Controller (\`axi\_bram\_ctrl\_0\`)**
-   **Block Memory Generator (\`blk\_mem\_gen\_0\`)**

## Block Flow

1.  **Sensor data** is streamed from the PS (or external source) through AXI DMA to the AXI Stream FIFO (\`axis\_data\_fifo\_0\`).
2.  The **FIFO** provides buffering to handle varying data rates.
3.  **TorqCalc\_IP** receives the data from the FIFO on its AXI-Stream slave interface (\`S00\_AXIS\`), and feeds it to the DSP48.
4.  **DSP48:** The output will be processed to show the torque. The parameters might be set by AXI-BRAM
5.  The BRAM will store the parameters. This will be accessible through the AXI BRAM Controller.
6.  The **processed result** from DSP48 is output on the AXI-Stream master interface (\`M00\_AXIS\`) and sent back to the PS via DMA.
7.  **AXI4-Lite** controls the process.

## Code Flow

-   **S00\_AXI.v:** Implements AXI4-Lite for configuration.
-   **S00\_AXIS.v:** Streaming input, manages buffering, and DSP48 access.
-   **M00\_AXIS.v:** Data output with streaming.
-   **Top-level wrapper:** Instantiates and connects all submodules.

## How to Use

1.  Clone the project in Vivado.
2.  Generate bitstream.
3.  Program the FPGA. Use PS to send sensor data and results through DMA.
4.  Modify the AXI-Lite as you like.

## References

*   [Vivado Custom IP User Guide](https://www.xilinx.com/support/documents/sw_manuals/xilinx2022_1/ug1118-vivado-creating-packaging-custom-ip.pdf)
*   [Vivado Block Design Tutorial](https://www.xilinx.com/support/documents/sw_manuals/xilinx2021_2/ug1119-vivado-creating-packaging-ip-tutorial.pdf)
*   [FPGA Developer: Creating a Custom IP Block in Vivado](https://www.fpgadeveloper.com/2014/08/creating-a-custom-ip-block-in-vivado.html/)
