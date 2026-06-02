`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/04 14:13:19
// Design Name: 
// Module Name: mont_mul_256b_testbench
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


module mont_mul_256b_testbench();
    
    localparam CLK_PERIOD = 10; // 100MHz clock

    // Signals
    logic             aclk;
    logic             aresetn;
    logic             data_in_valid;
    logic             data_in_ready;
    logic [255:0]     data_in_x;
    logic [255:0]     data_in_y;
    logic [255:0]     data_out;
    logic             data_out_valid;

    // DUT instantiation
    mont_mul_256b dut (
        .aclk(aclk),
        .aresetn(aresetn),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_in_x(data_in_x),
        .data_in_y(data_in_y),
        .data_out(data_out),
        .data_out_valid(data_out_valid)
    );

    // Clock generation
    initial begin
        aclk = 0;
        forever #(CLK_PERIOD / 2) aclk = ~aclk;
    end

    // Test stimulus
    initial begin
        // Reset sequence
        aresetn <= 1'b0;
        data_in_valid <= 1'b0;
        data_in_x <= '0;
        data_in_y <= '0;
        repeat(5) @(posedge aclk);
        aresetn <= 1'b1;
        @(posedge aclk);

/*        // --- Test Case 1 ---
        wait(dut.data_in_ready);
        @(posedge aclk) begin
            data_in_x <= 256'd2;
            data_in_y <= 256'd3;
            data_in_valid <= 1'b1;
        end
        @(posedge aclk) begin
            data_in_valid <= 1'b0;
        end
        
        wait(dut.data_out_valid);
        @(posedge aclk);*/

        // --- Test Case 2 ---
        wait(dut.data_in_ready);
        @(posedge aclk) begin
            data_in_x <= 'hCB8D19DD9C694317436357680414B36E224C72992597F45F2998DB68F6A37111;
            data_in_y <= 'hA3435977BA08D99F530050FBD3EA2DC58C9B0F920B4C4891CC3145A9044C82C1;
            data_in_valid <= 1'b1;
        end
        @(posedge aclk) begin
            data_in_valid <= 1'b0;
        end

        wait(dut.data_out_valid);
        @(posedge aclk) begin
            data_in_x <= data_out;
            data_in_y <= 'd1;
            data_in_valid <= 1'b1;
        end
        @(posedge aclk) begin
            data_in_valid <= 1'b0;
        end

    end

endmodule
