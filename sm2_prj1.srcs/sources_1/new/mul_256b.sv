`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/03 20:58:27
// Design Name: 
// Module Name: mul_256b
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

module mul_256b(
    input logic             aclk,
    input logic             aresetn,

    input logic             data_in_valid,
    output logic            data_in_ready,
    input logic [255:0]     data_in_x,
    input logic [255:0]     data_in_y,

    output logic            data_out_valid,
    output logic [512:0]    data_out
    );

    // 状态机状态
    typedef enum logic [2:0] {
        IDLE,
        CALC,
        WAIT, // 等待流水线填充
        SUM,
        DONE
    } state_t;

    state_t current_state, next_state;

    // 内部寄存器
    logic [255:0] x_reg, y_reg;
    logic [512:0] sum_reg;
    logic [319:0] temp1, temp2; // 用于中间结果存储
    logic         adder1, adder2, adder3, adder4; // 用于多次加法的进位
    logic [4:0]   cnt; // 用于整个操作周期的计数器

    // mont_mul_cell_64b 信号
    logic [63:0]    mul_a, mul_b;
    logic [127:0]   mul_p;
    logic [127:0]   mul_p_reg;

    // 数据分段
    logic [0:3][63:0] data_x, data_y;
    assign data_x[0] = x_reg[63:0];
    assign data_x[1] = x_reg[127:64];
    assign data_x[2] = x_reg[191:128];
    assign data_x[3] = x_reg[255:192];

    assign data_y[0] = y_reg[63:0];
    assign data_y[1] = y_reg[127:64];
    assign data_y[2] = y_reg[191:128];
    assign data_y[3] = y_reg[255:192];

    // 实例化单个乘法器
    mont_mul_cell_64b m_mont_mul_cell_64b (
        .CLK(aclk),
        .A(mul_a),
        .B(mul_b),
        .P(mul_p)
    );
    
    // 新增：在时钟沿锁存乘法器的输出
    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            mul_p_reg <= 'b0;
        end else begin
            mul_p_reg <= mul_p;
        end
    end

    // 状态寄存器
    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // 下一状态逻辑和数据路径控制
    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (data_in_valid) begin
                    next_state = CALC;
                end
            end
            CALC: begin
                if (cnt == 5'd15) begin
                    next_state = WAIT;
                end
            end
            WAIT: begin
                // 等待18个周期，直到第一个结果准备好
                // CALC(16) + WAIT(3) = 19
                if (cnt == 5'd19) begin
                    next_state = SUM;
                end
            end
            SUM: begin
                // 当cnt=15时，完成最后一次累加，下一个周期进入DONE
                if (cnt == 5'd19) begin 
                    next_state = DONE;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // 输入、计数器和累加器的寄存器
    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            cnt <= '0;
            data_in_ready <= 1'b1;
            data_out_valid <= 1'b0;
        end else begin
            // 默认赋值
            data_in_ready <= data_in_ready;
            data_out_valid <= 1'b0;

            case (current_state)
                IDLE: begin
                    data_in_ready <= 1'b1;
                    if (data_in_valid) begin
                        x_reg <= data_in_x;
                        y_reg <= data_in_y;
                        cnt <= '0;
                        sum_reg <= '0; 
                        data_in_ready <= 1'b0; // 接收数据后，拉低ready
                    end
                end
                CALC: begin
                    // 根据计数器为乘法器提供输入
                    mul_a <= data_x[cnt[3:2]];
                    mul_b <= data_y[cnt[1:0]];
                    cnt <= cnt + 1;
                end
                WAIT: begin
                    // 保持乘法器输入为0，同时等待流水线结果
                    mul_a <= '0;
                    mul_b <= '0;
                    if(cnt == 5'd19)
                        cnt <= 5'b0;
                    else 
                        cnt <= cnt + 1;
                end
                SUM: begin
                    // 累加流水线输出的结果
                    // calc_cnt 对应原始乘法的计数 (0-15)
                    cnt <= cnt + 1;
                    case(cnt)
                        'd0:begin
                            sum_reg[127:0] <= mul_p_reg;
                        end
                        'd1:begin // adder1 [128]
                            {adder1,sum_reg[127:64]} <= {1'b0,sum_reg[127:64]} + mul_p_reg[63:0];
                            sum_reg[191:128] <= mul_p_reg[127:64];
                        end
                        'd2:begin // adder1 [192]
                            {adder1,sum_reg[191:128]} <= {1'b0,sum_reg[191:128]} + mul_p_reg[63:0] + adder1;
                            sum_reg[255:192] <= mul_p_reg[127:64];
                        end
                        'd3:begin // adder1 [256]
                            {adder1,sum_reg[255:192]} <= {1'b0,sum_reg[255:192]} + mul_p_reg[63:0] + adder1;
                            sum_reg[319:256] <= mul_p_reg[127:64];
                        end
                        'd4:begin 
                            temp1[127:0] <= mul_p_reg;
                        end
                        'd5:begin //adder2 [192]
                            {adder2,temp1[127:64]} <= {1'b0,temp1[127:64]} + mul_p_reg[63:0];
                            temp1[191:128] <= mul_p_reg[127:64];
                        end
                        'd6:begin //adder2 [256]
                            {adder2,temp1[191:128]} <= {1'b0,temp1[191:128]} + mul_p_reg[63:0] + adder2;
                            temp1[255:192] <= mul_p_reg[127:64];
                        end
                        'd7:begin //adder2 [320]
                            {adder2,temp1[255:192]} <= {1'b0,temp1[255:192]} + mul_p_reg[63:0] + adder2 + adder1;
                            temp1[319:256] <= mul_p_reg[127:64];
                        end
                        'd8:begin
                            temp2[127:0] <= mul_p_reg;
                            sum_reg <= sum_reg + (temp1 << 64); // 每次加完temp1
                        end
                        'd9:begin //adder1 [256]
                            {adder1,temp2[127:64]} <= {1'b0,temp2[127:64]} + mul_p_reg[63:0];
                            temp2[191:128] <= mul_p_reg[127:64];
                        end
                        'd10:begin //adder1 [320]
                            {adder1,temp2[191:128]} <= {1'b0,temp2[191:128]} + mul_p_reg[63:0] + adder1;
                            temp2[255:192] <= mul_p_reg[127:64];
                        end
                        'd11:begin // adder1 [384]
                            {adder1,temp2[255:192]} <= {1'b0,temp2[255:192]} + mul_p_reg[63:0] + adder1 + adder2;
                            temp2[319:256] <= mul_p_reg[127:64];
                        end
                        'd12:begin
                            temp1[127:0] <= mul_p_reg;
                            sum_reg <= sum_reg + (temp2 << 128); // 每次加完temp2
                        end
                        'd13:begin // adder2 [320]
                            {adder2,temp1[127:64]} <= {1'b0,temp1[127:64]} + mul_p_reg[63:0];
                            temp1[191:128] <= mul_p_reg[127:64];
                        end
                        'd14:begin // adder2 [384]
                            {adder2,temp1[191:128]} <= {1'b0,temp1[191:128]} + mul_p_reg[63:0] + adder2;
                            temp1[255:192] <= mul_p_reg[127:64];
                        end
                        'd15:begin // adder2 [448]
                            {adder2,temp1[255:192]} <= {1'b0,temp1[255:192]} + mul_p_reg[63:0] + adder2 + adder1;
                            temp1[319:256] <= mul_p_reg[127:64];
                        end
                        'd16:begin
                            sum_reg <= sum_reg + (adder2 << 448) + (temp1 << 192); // 最后一次加完temp1和 adder2
                        end
                    endcase
                end
                DONE: begin
                    data_out <= sum_reg;
                    data_out_valid <= 1'b1;
                    // 为下一次操作复位
                    cnt <= '0;
                    sum_reg <= '0;
                    mul_a <= '0;
                    mul_b <= '0;
                end
            endcase
        end
    end
    
    
endmodule
