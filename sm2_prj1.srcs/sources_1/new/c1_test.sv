`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/06 01:12:38
// Design Name: 
// Module Name: c1_cal
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
module c1_test(
    input               sys_clk,
    output              fan
    );
    assign fan = 1'b0;
    (* mark_debug = "true" *)logic                 aclk;
    (* mark_debug = "true" *)logic                 rst_n;

    (* mark_debug = "true" *)logic [255:0]         in_data;
    (* mark_debug = "true" *)logic                 in_valid;
    (* mark_debug = "true" *)logic                 in_ready;

    (* mark_debug = "true" *)logic                out_valid;
    (* mark_debug = "true" *)logic [255:0]        out_data_x;
    (* mark_debug = "true" *)logic [255:0]        out_data_y;
    (* mark_debug = "true" *)logic [255:0]        out_data_z;
    
    logic cnt = 'b0;
    always @(posedge aclk)begin
        if(out_valid) cnt <= ~cnt;
        in_valid <= 1'b0;
        if(in_ready)begin
            case(cnt)
            1'b0:begin
                in_data <= 256'h59276E27D506861A16680F3AD9C02DCCEF3CC1FA3CDBE4CE6D54B80DEAC1BC21;
                in_valid <= 1'b1;
            end
            1'b1:begin
                in_data <= 256'hD4DE15474DB74D06491C440D305E012400990F3E390C7E87153C12DB2EA60BB3;
                in_valid <= 1'b1;
            end
            endcase
        end
    end
    
    clk_wiz_0 m_clk_wiz_0
   (
    // Clock out ports
    .clk_out1(aclk),     // output clk_out1
    // Status and control signals
    .resetn(1'b1), // input resetn
    .locked(rst_n),       // output locked
   // Clock in ports
    .clk_in1(sys_clk)      // input clk_in1
    );

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
endmodule