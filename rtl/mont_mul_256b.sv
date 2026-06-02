`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/03 20:30:58
// Design Name: 
// Module Name: mont_mul_256b
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


module mont_mul_256b#(
    parameter P = 256'hFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF,
    parameter P_MOD = 256'hFFFFFFFC00000001FFFFFFFE00000000FFFFFFFF000000010000000000000001
    )(
    input logic             aclk,
    input logic             aresetn,

    input logic             data_in_valid,
    output logic            data_in_ready,
    input logic [255:0]     data_in_x,
    input logic [255:0]     data_in_y,

    output logic [255:0]    data_out,
    output logic            data_out_valid
    );
    typedef enum logic [1:0] { 
        IDLE,
        BUSY,
        DONE
    } state_t;

    state_t cur_sta, nex_sta;

    // mul_256b 信号
    logic               mul_in_valid;
    logic               mul_in_ready;
    logic               mul_out_valid;
    logic [255:0]       x_reg, y_reg;
    logic [512:0]       p_reg;

    mul_256b u_mul_256b (
        .aclk(aclk),
        .aresetn(aresetn),
        .data_in_valid(mul_in_valid),
        .data_in_ready(mul_in_ready),
        .data_in_x(x_reg),
        .data_in_y(y_reg),
        .data_out_valid(mul_out_valid),
        .data_out(p_reg)
    );
    
    logic [4:0]         cnt;
    logic [511:0]       t_reg;
    logic [512:0]       pp_reg;
    logic               adder;  // 加法进位 
    logic [255:0]       result_reg;
    logic [255:0]       sub_result; // 用于存储减法结果
    logic               compare_bit;  // 用于存储比较结果

    always_ff @(posedge aclk) begin
        if(!aresetn) cur_sta <= IDLE;
        else cur_sta <= nex_sta;
    end

    always_comb begin
        case (cur_sta)
            IDLE: begin
                nex_sta = data_in_valid ? BUSY : IDLE;
            end
            BUSY: begin
                // 当最后一个计算步骤完成时，跳转到DONE状态
                if (cnt == 5'd16) // 状态计数增加
                    nex_sta = DONE;
                else
                    nex_sta = BUSY;
            end
            DONE: begin
                nex_sta = IDLE;
            end
            default : begin
                nex_sta = IDLE;
            end
        endcase
    end

    always_ff @(posedge aclk) begin
        if(!aresetn) begin
            cnt <= 'b0;
            data_out_valid <= 1'b0;
            data_in_ready <= 1'b1;
            
        end else begin
            // 默认赋值
            data_in_ready <= data_in_ready;
            data_out_valid <= 1'b0;
            mul_in_valid <= 1'b0;
            case(cur_sta)
                IDLE: begin
                    data_in_ready <= 1'b1;
                    if (data_in_valid) begin
                        x_reg <= data_in_x;
                        y_reg <= data_in_y;
                        mul_in_valid <= 1'b1;
                        
                        compare_bit <= 1'b0;
                        cnt <= 'b0;
                        data_in_ready <= 1'b0; // 接收数据后，拉低ready
                    end
                end
                BUSY: begin
                    case(cnt)
                        'd0: begin
                            if(mul_out_valid) 
                                cnt <= cnt + 1;
                        end
                        'd1: begin
                            t_reg <= p_reg[511:0];
                            x_reg <= p_reg[255:0];
                            y_reg <= P_MOD;
                            mul_in_valid <= 1'b1;
                            cnt <= cnt + 1;
                        end
                        'd2: begin
                            if(mul_out_valid) 
                                cnt <= cnt + 1;
                        end
                        'd3: begin
                            x_reg <= p_reg[255:0];
                            y_reg <= P;
                            mul_in_valid <= 1'b1;
                            cnt <= cnt + 1;
                        end
                        'd4: begin
                            if(mul_out_valid) begin
                                cnt <= cnt + 1;
                                {adder,pp_reg[63:0]} <= {1'b0,p_reg[63:0]} + t_reg[63:0];
                            end
                        end
                        'd5: begin
                            cnt <= cnt + 1;
                            {adder,pp_reg[127:64]} <= {1'b0,p_reg[127:64]} + t_reg[127:64] + adder;
                        end
                        'd6: begin
                            cnt <= cnt + 1;
                            {adder,pp_reg[191:128]} <= {1'b0,p_reg[191:128]} + t_reg[191:128] + adder;
                        end
                        'd7: begin
                            cnt <= cnt + 1;
                            {adder,pp_reg[255:192]} <= {1'b0,p_reg[255:192]} + t_reg[255:192] + adder;
                        end
                        'd8: begin
                            cnt <= cnt + 1;
                            {adder,pp_reg[319:256]} <= {1'b0,p_reg[319:256]} + t_reg[319:256] + adder;
                        end
                        'd9: begin
                            cnt <= cnt + 1;
                            {adder,pp_reg[383:320]} <= {1'b0,p_reg[383:320]} + t_reg[383:320] + adder;
                        end
                        'd10: begin
                            cnt <= cnt + 1;
                            {adder,pp_reg[447:384]} <= {1'b0,p_reg[447:384]} + t_reg[447:384] + adder;
                        end
                        'd11: begin
                            cnt <= cnt + 1;
                            {pp_reg[512:448]} <= {1'b0,p_reg[511:448]} + t_reg[511:448] + adder;
                        end
                        'd12: begin
                            cnt <= cnt + 1;
                            {adder,sub_result[63:0]} <= {1'b0,pp_reg[319:256]} - P[63:0];
                            if((!compare_bit)&& (pp_reg[512:448] > P[255:192]))
                                compare_bit <= 1'b1;
                        end
                        'd13: begin
                            cnt <= cnt + 1;
                            {adder,sub_result[127:64]} <= {1'b0,pp_reg[383:320]} - P[127:64] - adder;
                            if((!compare_bit)&& (pp_reg[447:384] > P[191:128]))
                                compare_bit <= 1'b1;
                        end
                        'd14: begin
                            cnt <= cnt + 1;
                            {adder,sub_result[191:128]} <= {1'b0,pp_reg[447:384]} - P[191:128] - adder;
                            if((!compare_bit)&& (pp_reg[383:320] > P[127:64]))
                                compare_bit <= 1'b1;
                        end
                        'd15: begin
                            cnt <= cnt + 1;
                            {adder,sub_result[255:192]} <= {1'b0,pp_reg[511:448]} - P[255:192] - adder;
                            if((!compare_bit)&& (pp_reg[319:256] > P[63:0]))
                                compare_bit <= 1'b1;
                        end
                        'd16: begin
                            // 流水线第二级：根据上一周期的比较结果进行选择
                            result_reg <= compare_bit ? sub_result : pp_reg[511:256];
                            cnt <= cnt + 1;
                        end
                    endcase
                end
                DONE: begin
                    data_out <= result_reg;
                    data_out_valid <= 1'b1;
                    adder <= 1'b0;
                    // 为下一次操作复位
                    cnt <= '0;
                    t_reg <= '0;
                    x_reg <= '0;
                    y_reg <= '0;
                    result_reg <= '0;
                    sub_result <= '0;
                    compare_bit <= '0;
                end
            endcase
        end
    end

endmodule
