`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/07 11:25:35
// Design Name: 
// Module Name: mod_adder_256b
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
module mod_adder_256b#(
    parameter P = 256'hFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF
)(
    input logic             aclk,
    input logic             aresetn,

    input logic             data_in_valid,
    output logic            data_in_ready,
    input logic [255:0]     data_in_a,
    input logic [255:0]     data_in_b,

    output logic [255:0]    data_out,
    output logic            data_out_valid
    );
    typedef enum logic [1:0] { 
        IDLE,
        BUSY,
        DONE
    } state_t;

    state_t cur_sta, nex_sta;

    logic [4:0]     cal_cnt,step_cnt;
    logic [255:0]   a_reg, b_reg;
    logic [256:0]   p_reg;

    // 
    logic [63:0]    A, B;
    logic           ADD, C_IN, C_OUT;
    logic [63:0]    S;

    addsub_cell_64b m_addsub_cell_64b (
    .A(A),          // input wire [63 : 0] A
    .B(B),          // input wire [63 : 0] B
    .CLK(aclk),      // input wire CLK
    .ADD(ADD),      // input wire ADD
    .C_IN(C_IN),    // input wire C_IN
    .C_OUT(C_OUT),  // output wire C_OUT
    .S(S)          // output wire [63 : 0] S
    );

    // ???
    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            cur_sta <= IDLE;
        end else begin
            cur_sta <= nex_sta;
        end
    end

    always_comb begin
        case(cur_sta)
            IDLE: begin
                if (data_in_valid) begin
                    nex_sta = BUSY;
                end else begin
                    nex_sta = IDLE;
                end
            end
            BUSY: begin
                if(step_cnt == 5'd3) begin
                    nex_sta = DONE;
                end else begin
                    nex_sta = BUSY;
                end
            end
            DONE: begin
                nex_sta = IDLE;
            end
            default: begin
                nex_sta = IDLE;
            end
        endcase
    end

    always_ff @(posedge aclk) begin : blockName
    
        data_out_valid <= 1'b0;
        data_in_ready <= 1'b0;
        case(cur_sta)
            IDLE: begin
                if (data_in_valid) begin
                    data_in_ready <= 1'b0;
                    cal_cnt <= 5'd0;
                    step_cnt <= 5'd0;
                    a_reg <= data_in_a;
                    b_reg <= data_in_b;
                end else begin
                    data_in_ready <= 1'b1;
                end
            end
            BUSY: begin
                case(step_cnt)
                    5'd0: begin
                        if(cal_cnt == 5'd8) cal_cnt <= 5'd0;
                        else cal_cnt <= cal_cnt + 5'd1;
                        case(cal_cnt)
                            5'd0: begin
                                A <= a_reg[63:0];
                                B <= b_reg[63:0];
                                ADD <= 1'b1;
                                C_IN <= 1'b0;
                            end
                            5'd1: begin
                                // do nothing
                            end
                            5'd2: begin
                                A <= a_reg[127:64];
                                B <= b_reg[127:64];
                                ADD <= 1'b1;
                                C_IN <= C_OUT;
                                p_reg[63:0] <= S[63:0];
                            end
                            5'd3: begin
                                // do nothing
                            end
                            5'd4: begin
                                A <= a_reg[191:128];
                                B <= b_reg[191:128];
                                ADD <= 1'b1;
                                C_IN <= C_OUT;
                                p_reg[127:64] <= S[63:0];
                            end
                            5'd5: begin
                                // do nothing
                            end
                            5'd6: begin
                                A <= a_reg[255:192];
                                B <= b_reg[255:192];
                                ADD <= 1'b1;
                                C_IN <= C_OUT;
                                p_reg[191:128] <= S[63:0];
                            end
                            5'd7: begin
                                // do nothing
                            end
                            5'd8: begin
                                p_reg[256:192] <= {C_OUT,S};
                                step_cnt <= step_cnt + 1;
                            end
                            default: begin
                                A <= 32'b0;
                                B <= 32'b0;
                                ADD <= 1'b0;
                                C_IN <= 1'b0;
                            end
                        endcase
                    end
                    5'd1: begin
                        if(cal_cnt == 5'd9) cal_cnt <= 5'd0;
                        else cal_cnt <= cal_cnt + 1;
                        case(cal_cnt)
                            5'd0: begin
                                if(p_reg[256])begin
                                    cal_cnt <= 5'd9;
                                end 
                            end
                            5'd1: begin
                                if(p_reg[255:224] < P[255:224])begin
                                    step_cnt <= 5'd3;
                                end else if(p_reg[255:224] > P[255:224]) begin
                                    cal_cnt <= 5'd9;
                                end
                            end
                            5'd2: begin
                                if(p_reg[223:192] < P[223:192])begin
                                    step_cnt <= 5'd3;
                                end else if(p_reg[223:192] > P[223:192]) begin
                                    cal_cnt <= 5'd9;
                                end
                            end
                            5'd3: begin
                                if(p_reg[191:160] < P[191:160])begin
                                    step_cnt <= 5'd3;
                                end else if(p_reg[191:160] > P[191:160]) begin
                                    cal_cnt <= 5'd9;
                                end
                            end
                            5'd4: begin
                                if(p_reg[159:128] < P[159:128])begin
                                    step_cnt <= 5'd3;
                                end else if(p_reg[159:128] > P[159:128]) begin
                                    cal_cnt <= 5'd9;
                                end
                            end
                            5'd5: begin
                                if(p_reg[127:96] < P[127:96])begin
                                    step_cnt <= 5'd3;
                                end else if(p_reg[127:96] > P[127:96]) begin
                                    cal_cnt <= 5'd9;
                                end
                            end
                            5'd6: begin
                                if(p_reg[95:64] < P[95:64])begin
                                    step_cnt <= 5'd3;
                                end else if(p_reg[95:64] > P[95:64]) begin
                                    cal_cnt <= 5'd9;
                                end
                            end
                            5'd7: begin
                                if(p_reg[63:32] < P[63:32])begin
                                    step_cnt <= 5'd3;
                                end else if(p_reg[63:32] > P[63:32]) begin
                                    cal_cnt <= 5'd9;
                                end
                            end
                            5'd8: begin
                                if(p_reg[31:0] < P[31:0])begin
                                    step_cnt <= 5'd3;
                                end else if(p_reg[31:0] > P[31:0]) begin
                                    cal_cnt <= 5'd9;
                                end
                            end
                            5'd9: begin
                                step_cnt <= 5'd2;
                            end
                        endcase
                    end
                    // p_reg - P
                    5'd2: begin
                        if(cal_cnt == 5'd8) cal_cnt <= 5'd0;
                        else cal_cnt <= cal_cnt + 1;
                        case(cal_cnt)
                            5'd0: begin
                                A <= p_reg[63:0];
                                B <= P[63:0];
                                ADD <= 1'b0;
                                C_IN <= 1'b1;
                            end
                            5'd1: begin
                                // do nothing
                            end
                            5'd2: begin
                                A <= p_reg[127:64];
                                B <= P[127:64];
                                ADD <= 1'b0;
                                C_IN <= C_OUT;
                                p_reg[63:0] <= S[63:0];
                            end
                            5'd3: begin
                                // do nothing
                            end
                            5'd4: begin
                                A <= p_reg[191:128];
                                B <= P[191:128];
                                ADD <= 1'b0;
                                C_IN <= C_OUT;
                                p_reg[127:64] <= S[63:0];
                            end
                            5'd5: begin
                                // do nothing
                            end
                            5'd6: begin
                                A <= p_reg[255:192];
                                B <= P[255:192];
                                ADD <= 1'b0;
                                C_IN <= C_OUT;
                                p_reg[191:128] <= S[63:0];
                            end
                            5'd7: begin
                                // do nothing
                            end
                            5'd8: begin
                                p_reg[255:192] <= S;
                                step_cnt <= step_cnt + 1;
                            end
                            default: begin
                                A <= 32'b0;
                                B <= 32'b0;
                                ADD <= 1'b0;
                                C_IN <= 1'b0;
                            end
                        endcase
                    end
                    // output
                    5'd3: begin
                        
                    end
                    default: begin
                        step_cnt <= step_cnt;
                    end
                endcase
            end
            DONE: begin
                data_out <= p_reg[255:0];
                data_out_valid <= 1'b1;
            end
            default: begin
                data_in_ready <= 1'b0;
                data_out_valid <= 1'b0;
            end
        endcase
    end

endmodule
