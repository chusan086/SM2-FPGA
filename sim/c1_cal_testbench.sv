`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/06 16:15:37
// Design Name: 
// Module Name: c1_cal_testbench
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


module c1_cal_testbench();

    // Clock and Reset
    logic aclk;
    logic rst_n;

    // DUT Interface
    logic [255:0]   in_data;
    logic           in_valid;
    logic           in_ready;
    logic           out_valid;
    logic [255:0]   out_data_x;
    logic [255:0]   out_data_y;
    logic [255:0]   out_data_z;

    // Instantiate the DUT
    c1_cal u_c1_cal (
        .aclk(aclk),
        .rst_n(rst_n),
        .in_data(in_data),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .out_data_x(out_data_x),
        .out_data_y(out_data_y),
        .out_data_z(out_data_z)
    );

    // Clock generation
    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk; // 100MHz clock
    end

    // Test sequence
    initial begin
        // 1. Initialize signals and apply reset
        in_valid <= 1'b0;
        rst_n <= 1'b1;
        $display("Time: %0t, Reset is de-asserted.", $time);

        // 2. Wait for DUT to be ready
        wait(in_ready);
        

        // 3. Send start signal
        @(posedge aclk);
        in_valid <= 1'b1;
        in_data <= 256'h59276E27D506861A16680F3AD9C02DCCEF3CC1FA3CDBE4CE6D54B80DEAC1BC21;
        @(posedge aclk);
        in_valid <= 1'b0;
        

        
        
    end

endmodule
