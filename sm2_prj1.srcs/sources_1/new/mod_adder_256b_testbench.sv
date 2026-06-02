`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/07 12:08:37
// Design Name: 
// Module Name: mod_adder_256b_testbench
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


module mod_adder_256b_testbench(

    );

    localparam P = 256'hFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF;

    logic             aclk;
    logic             aresetn;

    logic             data_in_valid;
    logic             data_in_ready;
    logic [255:0]     data_in_a;
    logic [255:0]     data_in_b;

    logic [255:0]    data_out;
    logic            data_out_valid;

    mod_subtracter_256b #(
        .P(P)
    ) u_mod_subtracter_256b (
        .aclk(aclk),
        .aresetn(aresetn),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_in_a(data_in_a),
        .data_in_b(data_in_b),
        .data_out(data_out),
        .data_out_valid(data_out_valid)
    );

    // Clock generation
    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk;
    end

    // Test sequence
    initial begin
        // Reset
        aresetn <= 1'b0;
        data_in_valid <= 1'b0;
        data_in_a <= 256'b0;
        data_in_b <= 256'b0;
        repeat(2) @(posedge aclk);
        aresetn <= 1'b1;
        @(posedge aclk);

        // Wait for DUT to be ready
        wait(data_in_ready);
        @(posedge aclk);
        // Test Case 1: a - b < P
        $display("Test Case 1: a + b < P");
        data_in_a <= 256'd100;
        data_in_b <= 256'd200;
        data_in_valid <= 1'b1;
        @(posedge aclk);
        data_in_valid <= 1'b0;
        
        wait(data_out_valid);
        @(posedge aclk);
        if (data_out == 256'd300) begin
            $display("Test Case 1 Passed. Result: %h", data_out);
        end else begin
            $display("Test Case 1 Failed. Expected: %h, Got: %h", 256'd300, data_out);
        end
        
        // Wait for DUT to be ready
        wait(data_in_ready);
        @(posedge aclk);
        // Test Case 2: a = b
        $display("Test Case 2: a + b > P");
        data_in_a <= 50;
        data_in_b <= 50;
        data_in_valid <= 1'b1;
        @(posedge aclk);
        data_in_valid <= 1'b0;

        wait(data_out_valid);
        @(posedge aclk);
        if (data_out == 50) begin
            $display("Test Case 2 Passed. Result: %h", data_out);
        end else begin
            $display("Test Case 2 Failed. Expected: %h, Got: %h", 50, data_out);
        end
        
        // Wait for DUT to be ready
        wait(data_in_ready);
        @(posedge aclk);
        // Test Case 3: a + b = P
        $display("Test Case 3: a + b = P");
        data_in_a <= P - 2;
        data_in_b <= 2;
        data_in_valid <= 1'b1;
        @(posedge aclk);
        data_in_valid <= 1'b0;

        wait(data_out_valid);
        @(posedge aclk);
        if (data_out == 0) begin
            $display("Test Case 3 Passed. Result: %h", data_out);
        end else begin
            $display("Test Case 3 Failed. Expected: %h, Got: %h", 0, data_out);
        end
        

    end

endmodule
