`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/03 21:42:28
// Design Name: 
// Module Name: mul_256b_testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mul_256b_testbench();

    // 时钟周期定义 (100MHz)
    localparam CLK_PERIOD = 10;

    // 信号定义
    logic             aclk;
    logic             aresetn;
    logic             data_in_valid;
    logic             data_in_ready;
    logic [255:0]     data_in_x;
    logic [255:0]     data_in_y;
    logic             data_out_valid;
    logic [512:0]     data_out;
    logic [511:0]     expected_out;

    // 实例化被测模块 (DUT: Design Under Test)
    mul_256b dut (
        .aclk(aclk),
        .aresetn(aresetn),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_in_x(data_in_x),
        .data_in_y(data_in_y),
        .data_in_z('b0),
        .data_out_valid(data_out_valid),
        .data_out(data_out)
    );

    // 时钟生成
    initial begin
        aclk = 0;
        forever #(CLK_PERIOD / 2) aclk = ~aclk;
    end

    // 测试激励
    initial begin
        
        // 初始化和复位
        $display("--- Simulation Start ---");
        aresetn = 1'b0;
        data_in_valid = 1'b0;
        data_in_x = '0;
        data_in_y = '0;
        repeat(5) @(posedge aclk);
        aresetn = 1'b1;
        @(posedge aclk);

        // --- Test Case 1 ---
        wait(dut.data_in_ready);
        @(posedge aclk)begin
            data_in_x <= 256'd2;
            data_in_y <= 256'd3;
            expected_out <= 512'd6;
            data_in_valid <= 1'b1;
        end
        $display("Test 1: Sending data...");
        @(posedge aclk) begin
            data_in_valid <= 1'b0;
        end
        
        wait(dut.data_out_valid);
        

        // --- Test Case 2 ---
        wait(dut.data_in_ready);
        @(posedge aclk) begin
            data_in_x <= 256'hFF;
            data_in_y <= 256'h10;
            expected_out <= 512'hFF0;
            data_in_valid <= 1'b1;
        end
        $display("Test 2: Sending data...");
        @(posedge aclk) begin
            data_in_valid <= 1'b0;
        end
        
        wait(dut.data_out_valid);
        

        // --- Test Case 3 ---
        wait(dut.data_in_ready);
        @(posedge aclk) begin
            data_in_x <= {128'hA, 128'hB};
            data_in_y <= {128'hC, 128'hD};
            expected_out <= {128'hA, 128'hB} * {128'hC, 128'hD}; // 仿真器可以直接计算期望值
            data_in_valid <= 1'b1;
        end
        $display("Test 3: Sending data...");
        @(posedge aclk) begin
            data_in_valid <= 1'b0;
        end
        
        wait(dut.data_out_valid);
        

        // --- Test Case 4 ---
        wait(dut.data_in_ready);
        @(posedge aclk) begin
            data_in_x <= 'hCB8D19DD9C694317436357680414B36E224C72992597F45F2998DB68F6A37111;
            data_in_y <= 'hA3435977BA08D99F530050FBD3EA2DC58C9B0F920B4C4891CC3145A9044C82C1;
            expected_out <= 512'hB2AA42C4D2896D6FB281C556B661101D42CE0BE47C4D0FE6414F0B9C5DCC3942F3B15CEB87DB6BE601D13DBBBC1C8065630F0C6178BDD6E67E4231813B7DA0E;
            data_in_valid <= 1'b1;
        end
        $display("Test 4: Sending data...");
        @(posedge aclk) begin
            data_in_valid <= 1'b0;
        end
        
        // --- Test Case 3 ---
        wait(dut.data_out_valid);
        wait(dut.data_in_ready);
        @(posedge aclk) begin
            data_in_x <= 'h5A9C3A3FE342695B3E8B2B4D7A4D6E8C5E8A9F7B6C5D4E3F2A1B0C9D8E7F6A5B;
            data_in_y <= 'h1F8C7B6A5D4E3F2A1B0C9D8E7F6A5B4C3D2E1F0A9B8C7D6E5F4A3B2C1D0E9F8A;
            expected_out <= 'hB2AA42C4D2896D6FB281C556B661101D42CE0BE47C4D0FE6414F0B9C5DCC3942F3B15CEB87DB6BE601D13DBBBC1C8065630F0C6178BDD6E67E4231813B7DA0E; // 仿真器可以直接计算期望值
            data_in_valid <= 1'b1;
        end
        $display("Test 3: Sending data...");
        @(posedge aclk) begin
            data_in_valid <= 1'b0;
        end
    end
    
    logic[127:0] a = 128'hCB8D19DD9C694317 * 128'hA3435977BA08D99F;
    logic[127:0] b = 128'h2998DB68F6A37111 * 128'hCC3145A9044C82C1;
endmodule

