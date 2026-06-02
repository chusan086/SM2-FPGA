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
module c1_cal#(
    parameter P = 256'hFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF,
    parameter P_MONT = 256'hFFFFFFFC00000001FFFFFFFE00000000FFFFFFFF000000010000000000000001,
    parameter EIGHT_MONT = 256'h800000000000000000000000000000007FFFFFFF80000000000000008,
    parameter FOUR_MONT = 256'h400000000000000000000000000000003FFFFFFFC0000000000000004,
    parameter TWO_MONT = 256'h200000000000000000000000000000001FFFFFFFE0000000000000002,
    parameter A_MONT = 256'hFFFFFFFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC00000003FFFFFFFFFFFFFFFC
    )(
    input logic                 aclk,
    input logic                 rst_n,

    input logic [255:0]         in_data,
    input logic                 in_valid,
    output logic                in_ready,

    output logic                out_valid,
    output logic [255:0]        out_data_x,
    output logic [255:0]        out_data_y,
    output logic [255:0]        out_data_z
    );

    localparam logic [0:14][255:0]   Gx = '{
        256'h91167A5EE1C13B05D6A1ED99AC24C3C33E7981EDDCA6C05061328990F418029E,
        256'h398874C476A3B1F77AEF3E862601440903243D78D5B614A62EDA8381E63C48D6,
        256'h3015AD2077C8C0285DD76FBCBDF037E43C51EB40C7C50ABC05294C0F53498D0E,
        256'hE8457905838420A51366F7FE174CE34DC3579FEFC188F0B5124E7537526AE99E,
        256'hBC10C7B2B9F580E8DD9C6CC7696538D57EB56231D5C28F77264938E59CB4AC8E,
        256'h4BAEA6E078F47A81ABF568B579B42F75E40C440B879D4E9E419855B06C636C23,
        256'hF7890711275A8F23419FE64286ECEE375A552A52FF456695D12870408D2B1842,
        256'h90334C49DFAC8B59E62195232C9AF1C8F57AECF2CD10A73F90F91922C7785195,
        256'hE5885491A0C326C530CAF443285B58BD66850926386F6783C5E23F313E423FD6,
        256'h90E7F760AFD2D88F63A74DCC2006F271D6804C1EB13B9C0BA638FE9691186CA7,
        256'h55CB5D846391982ACE11F4BF750FE52FB883D20B63C4FD85B53DAE7CEBCFEA7C,
        256'hC2D9688047B7821597AEF047DABA601C52A58D6CE63A4DD423C03687D9FA7EE4,
        256'h4F615315752841A992192BDC38DD6ABD6893289BCAA94B4F2087B5AE2C368219,
        256'h3358A25A767C4D246931ADFD3DDB567692EFA04BAEA19F6C39C662E41CD0420A,
        256'h4E2EC0B015433F44EFDFDE036C4177258BF48D1FA5530D086567689D62DE4C9
    };
    localparam logic [0:14][255:0]   Gy = '{
        256'h63CD65D481D735BD8D4CFB066E2A48F8C1F5E5788D3295FAC1354E593C2D0DDD, 
        256'h1FBBDFDDDAF4FD475A86A7AE64921D4829F04A88F6CF4DC128385681C1A73E40,
        256'h167DF558DE1A110586371F717CE702B49EFA98A8C6242C3C0D40BB897BF1733C,
        256'h48C3374AB1D5FDE0276BEBB81B8FF0BAA9805CC2D0F487E18D7B3A4352F4AE21,
        256'h7BB6BB39033850CA9F4BBD016CCC0961B6F3BAF8CC1491FDB523ADB2B68E86D8,
        256'h456A8F02B9EF66A92CB3C00247EC6D64D39DC2A4C83D31756AD702D87BCE52C2,
        256'h9E4D781C63732E723D6EF1BD2AB3AAAF85D53FCBD2310EB2489855847D52620F,
        256'hB3EE31058D090536568BC5B2434D8D78E998F1F9F9914CBCE1EC14789A9A6B03,
        256'h78704A6F048D9EB0225E1F3DF66BF9A9953721E95E69066341FBC7B0A00F7213,
        256'hFB1541DB19D06EE6025A43881D8DC8752E69C7C2E967B178DB84ECD456355AC1,
        256'h40F338FF4F316174AA13F171DE1298D5F93448FE7DA786BBE985A76150B6CF1C,
        256'hDFB3544F994F82EBCEFB54462ADCDA33E3FF21B16BBC1C2226CC3A436416998C,
        256'hF63C3A093A40823B655A576DA1D39A8A4ADE188AE4005D42476111F7A957A66F,
        256'h4CF03F4F7ABE34E6B44066C1DE9043633F95B414C774A8E68981E8D54F00C400,
        256'hD4360DC94614BE53312F8E392AAA0B618933F55E120E3330B98CD59AB37F75AD
    };
    localparam logic [0:14][255:0]   Gz = '{
        256'h100000000000000000000000000000000FFFFFFFF0000000000000001,
        256'hC79ACBA903AE6B7B1A99F60CDC5491F183EBCAF11A652BF5826A9CB2785A1BBA,
        256'hE3D2125AF942174E02C20FAD90368DE25832932B7EEF2B4351711CC32C29B331,
        256'h79F76FD57F22F1E282D64FF809A53F1F729F6B89C6F626B96725A9D05704E681,
        256'hC51C9DD2C6E0145EE3ACBB97FD3448934459CFA0699AB551EC454F343D15477D,
        256'hFAB56294EEDD309612CA79782980E3DEC95C44803301DF092BB1D9C6A8F60558,
        256'h3F247E7165FF4B452527561131455B2721BF35C629D09B9926232FFF87323447,
        256'hFC2301898783EDB9842B719B9C75E6644353BFECBB0F9D663EFF05579AABA4B6,
        256'h9CC67215503DD3CFA9F61AFB8D965BB6AD97C382C993BA241B66F999C1B3796A,
        256'hFAF892D7EF0AEB827DA138B6B838857F5105F01F42B50CDC07D1B2968E5A2569,
        256'h446BA70716C75B2D159F6832E7093462F502F5E0D7C74EB431CB0D9D6278C344,
        256'h60CCC5B4E9AB4CA23D43E5A1704D7EC43FFECC907A7179C6E6409D73D3298107,
        256'h819CD324906F72BBB750A733519E29E392440A797670D2616EE2CEE4244F9D07,
        256'h5C8723758A42E13F4D7A081574312C9544D590CA66AF8949CEF15A611A9F749A,
        256'h591DC08AC36AFC370EB8541C7310A2FFB0D93BB97934CFF5FBC35A7E9509B1A9  
    };

    (* mark_debug = "true" *)logic [6:0]     shift_cnt;
    (* mark_debug = "true" *)logic [5:0]     cal_cnt;
    (* mark_debug = "true" *)logic [3:0]     step_cnt;

    (* mark_debug = "true" *)logic [255:0]   in_data_reg;
    logic [255:0]   x1,y1,z1;
    logic [255:0]   x2,y2,z2;
    logic [255:0]   temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8;

    // mont_mul_256b 实例的信号定义
    logic           mont_A_in_valid, mont_B_in_valid, mont_C_in_valid;
    logic           mont_A_in_ready, mont_B_in_ready, mont_C_in_ready;
    logic [255:0]   mont_A_in_x, mont_A_in_y;
    logic [255:0]   mont_B_in_x, mont_B_in_y;
    logic [255:0]   mont_C_in_x, mont_C_in_y;
    logic [255:0]   mont_A_out, mont_B_out, mont_C_out;
    logic           mont_A_out_valid, mont_B_out_valid, mont_C_out_valid;

    logic          adder_data_in_valid, adder_data_in_ready;
    logic [255:0]  adder_data_in_a, adder_data_in_b;
    logic [255:0]  adder_data_out;
    logic          adder_data_out_valid;

    logic          suber_data_in_valid, suber_data_in_ready;
    logic [255:0]  suber_data_in_a, suber_data_in_b;
    logic [255:0]  suber_data_out;
    logic          suber_data_out_valid;

    typedef enum logic [2:0] {
        IDLE,
        START,
        ST_DONE,
        POINT_DOUBLE,
        POINT_ADD,
        DONE
    } state_t;

    (* mark_debug = "true" *)state_t cur_sta; 
    state_t nex_sta;
    
    mod_adder_256b u_mod_adder_256b (
        .aclk(aclk),
        .aresetn(rst_n),
        .data_in_valid(adder_data_in_valid),
        .data_in_ready(adder_data_in_ready),
        .data_in_a(adder_data_in_a),
        .data_in_b(adder_data_in_b),
        .data_out(adder_data_out),
        .data_out_valid(adder_data_out_valid)
    );

    mod_subtracter_256b u_mod_subtracter_256b (
        .aclk(aclk),
        .aresetn(rst_n),
        .data_in_valid(suber_data_in_valid),
        .data_in_ready(suber_data_in_ready),
        .data_in_a(suber_data_in_a),
        .data_in_b(suber_data_in_b),
        .data_out(suber_data_out),
        .data_out_valid(suber_data_out_valid)
    );

    mont_mul_256b u_mont_A (
        .aclk(aclk),
        .aresetn(rst_n),
        .data_in_valid(mont_A_in_valid),
        .data_in_ready(mont_A_in_ready),
        .data_in_x(mont_A_in_x),
        .data_in_y(mont_A_in_y),
        .data_out(mont_A_out),
        .data_out_valid(mont_A_out_valid)
    );

    mont_mul_256b u_mont_B (
        .aclk(aclk),
        .aresetn(rst_n),
        .data_in_valid(mont_B_in_valid),
        .data_in_ready(mont_B_in_ready),
        .data_in_x(mont_B_in_x),
        .data_in_y(mont_B_in_y),
        .data_out(mont_B_out),
        .data_out_valid(mont_B_out_valid)
    );

    mont_mul_256b u_mont_C (
        .aclk(aclk),
        .aresetn(rst_n),
        .data_in_valid(mont_C_in_valid),
        .data_in_ready(mont_C_in_ready),
        .data_in_x(mont_C_in_x),
        .data_in_y(mont_C_in_y),
        .data_out(mont_C_out),
        .data_out_valid(mont_C_out_valid)
    );

    always_ff @(posedge aclk) begin
        if(!rst_n) begin
            cur_sta <= IDLE;
        end
        else begin
            cur_sta <= nex_sta;
        end
    end

    always_comb begin
        case(cur_sta)
            IDLE: begin
                if(in_valid) 
                    nex_sta = START;
                else 
                    nex_sta = IDLE;
            end
            START: begin
                if(in_data_reg[255:252] != 4'd0) 
                    nex_sta = POINT_DOUBLE;
                else if(shift_cnt >= 7'd64)
                    nex_sta = DONE;
                else
                    nex_sta = START;
            end
            ST_DONE: begin
                if(shift_cnt >= 7'd64) 
                    nex_sta = DONE;
                else if(step_cnt == 4'd0 && in_data_reg[255:252] != 4'd0)
                    nex_sta = POINT_ADD;
                else
                    nex_sta = POINT_DOUBLE;
            end
            POINT_DOUBLE: begin
                if(cal_cnt == 6'd23) 
                    nex_sta = ST_DONE;
                else 
                    nex_sta = POINT_DOUBLE;
            end
            POINT_ADD: begin
                if(cal_cnt == 6'd27) 
                    nex_sta = ST_DONE;
                else 
                    nex_sta = POINT_ADD;
            end
            DONE: begin
                if(cal_cnt == 6'd2) 
                    nex_sta = IDLE;
                else 
                    nex_sta = DONE;
            end
            default: begin
                nex_sta = IDLE;
            end
        endcase
    end

    always_ff @(posedge aclk) begin
        out_valid <= 1'b0;

        adder_data_in_valid <= 1'b0;
        suber_data_in_valid <= 1'b0;
        mont_A_in_valid <= 1'b0;
        mont_B_in_valid <= 1'b0;
        mont_C_in_valid <= 1'b0;
        case(cur_sta)
            IDLE: begin
                if(in_valid) begin
                    in_data_reg <= in_data;
                    cal_cnt <= 6'd0;
                    step_cnt <= 4'd0;
                    shift_cnt <= 7'd0;
                    in_ready <= 1'b0;     
                end else begin
                    in_ready <= 1'b1;
                end        
            end
            START: begin
                in_data_reg <= {in_data_reg[251:0],4'd0};
                shift_cnt <= shift_cnt + 4'd1;
                if(in_data_reg[255:252] != 4'd0) begin
                    x1 <= Gx[in_data_reg[255:252]-1];
                    y1 <= Gy[in_data_reg[255:252]-1];
                    z1 <= Gz[in_data_reg[255:252]-1];  
                    step_cnt <= 4'd1;                 
                end
            end
            ST_DONE: begin
                if(step_cnt == 4'd0) begin
                    in_data_reg <= {in_data_reg[251:0],4'd0};
                    shift_cnt <= shift_cnt + 4'd1;
                    if(in_data_reg[255:252] != 4'd0) begin
                        x2 <= Gx[in_data_reg[255:252]-1];
                        y2 <= Gy[in_data_reg[255:252]-1];
                        z2 <= Gz[in_data_reg[255:252]-1];                   
                    end else begin
                        step_cnt <= 4'd1;
                    end
                end
            end
            POINT_DOUBLE: begin
                case(cal_cnt)
                    6'd0: begin
                        mont_A_in_valid <= 1'b1;
                        mont_A_in_x <= x1;
                        mont_A_in_y <= x1;
                        mont_B_in_valid <= 1'b1;
                        mont_B_in_x <= y1;
                        mont_B_in_y <= y1;
                        mont_C_in_valid <= 1'b1;
                        mont_C_in_x <= z1;
                        mont_C_in_y <= z1;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd1: begin
                        if(mont_A_out_valid) begin
                            temp1 <= mont_A_out;//temp1=A1
                            temp2 <= mont_B_out;//temp2=B1
                            temp3 <= mont_C_out;//temp3=C1
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd2: begin
                        mont_A_in_valid <= 1'b1;
                        mont_A_in_x <= temp3;
                        mont_A_in_y <= temp3;
                        mont_B_in_valid <= 1'b1;
                        mont_B_in_x <= temp2;
                        mont_B_in_y <= temp2;
                        mont_C_in_valid <= 1'b1;
                        mont_C_in_x <= x1;
                        mont_C_in_y <= temp2;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd3:begin
                        adder_data_in_valid <= 1'b1;
                        adder_data_in_a <= temp1;
                        adder_data_in_b <= temp1;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd4:begin
                        if(adder_data_out_valid) begin
                            temp5 <= adder_data_out;
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd5:begin
                        adder_data_in_valid <= 1'b1;
                        adder_data_in_a <= temp1;
                        adder_data_in_b <= temp5;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd6:begin
                        if(adder_data_out_valid) begin
                            temp5 <= adder_data_out;//temp5=A2'
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd7:begin
                        if(mont_A_out_valid) begin
                            temp1 <= mont_A_out;//temp1=A2
                            temp2 <= mont_B_out;//temp2=B2
                            temp3 <= mont_C_out;//temp3=C2
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd8: begin
                        mont_A_in_valid <= 1'b1;
                        mont_A_in_x <= A_MONT;
                        mont_A_in_y <= temp1;
                        mont_B_in_valid <= 1'b1;
                        mont_B_in_x <= EIGHT_MONT;
                        mont_B_in_y <= temp2;
                        mont_C_in_valid <= 1'b1;
                        mont_C_in_x <= FOUR_MONT;
                        mont_C_in_y <= temp3;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd9:begin
                        if(mont_A_out_valid) begin
                            temp1 <= mont_A_out;//temp1=A3
                            temp6 <= mont_B_out;//temp6=B3
                            temp4 <= mont_C_out;//temp4=C3
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd10:begin
                        adder_data_in_valid <= 1'b1;
                        adder_data_in_a <= temp1;
                        adder_data_in_b <= temp5;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd11:begin
                        if(adder_data_out_valid) begin
                            temp1 <= adder_data_out;//temp1=M
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd12:begin
                        mont_A_in_valid <= 1'b1;
                        mont_A_in_x <= temp1;
                        mont_A_in_y <= temp1;
                        mont_B_in_valid <= 1'b1;
                        mont_B_in_x <= y1;
                        mont_B_in_y <= z1;
                        mont_C_in_valid <= 1'b1;
                        mont_C_in_x <= EIGHT_MONT;
                        mont_C_in_y <= temp3;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd13:begin
                        if(mont_A_out_valid) begin
                            temp2 <= mont_A_out;//temp2=A4
                            temp3 <= mont_B_out;//temp3=B4
                            temp5 <= mont_C_out;//temp5=C4
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd14:begin
                        suber_data_in_valid <= 1'b1;
                        suber_data_in_a <= temp2;
                        suber_data_in_b <= temp5;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd15:begin
                        if(suber_data_out_valid) begin
                            temp7 <= suber_data_out;//temp7=X3
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd16:begin
                        suber_data_in_valid <= 1'b1;
                        suber_data_in_a <= temp4;
                        suber_data_in_b <= temp7;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd17:begin
                        if(suber_data_out_valid) begin
                            temp2 <= suber_data_out;//temp2=S-X3
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd18:begin
                        mont_A_in_valid <= 1'b1;
                        mont_A_in_x <= temp1;
                        mont_A_in_y <= temp2;
                        mont_B_in_valid <= 1'b1;
                        mont_B_in_x <= TWO_MONT;
                        mont_B_in_y <= temp3;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd19:begin
                        if(mont_A_out_valid) begin
                            temp2 <= mont_A_out;//temp2=A5
                            temp3 <= mont_B_out;//temp3=B5=Z3
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd20:begin
                        suber_data_in_valid <= 1'b1;
                        suber_data_in_a <= temp2;
                        suber_data_in_b <= temp6;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd21:begin
                        if(suber_data_out_valid) begin
                            temp1 <= suber_data_out;//temp1=Y3
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd22:begin
                        x1 <= temp7;
                        y1 <= temp1;
                        z1 <= temp3;
                        cal_cnt <= cal_cnt + 1;
                        if(step_cnt == 7'd4)step_cnt <= 7'd0;
                        else step_cnt <= step_cnt + 1;
                    end
                    6'd23:begin
                        cal_cnt <= 6'd0;             
                    end
                    default:begin
                        cal_cnt <= 6'd0;
                    end
                endcase    
            end
            POINT_ADD: begin
                case(cal_cnt)   
                    6'd0: begin
                        mont_A_in_valid <= 1'b1;
                        mont_A_in_x <= z1;
                        mont_A_in_y <= z1;
                        mont_B_in_valid <= 1'b1;
                        mont_B_in_x <= z2;
                        mont_B_in_y <= z2;
                        mont_C_in_valid <= 1'b1;
                        mont_C_in_x <= y1;
                        mont_C_in_y <= z2;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd1: begin
                        if(mont_A_out_valid) begin
                            temp1 <= mont_A_out;//temp1=A1
                            temp2 <= mont_B_out;//temp2=B1
                            temp3 <= mont_C_out;//temp3=C1
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd2: begin
                        mont_A_in_valid <= 1'b1;
                        mont_A_in_x <= temp1;
                        mont_A_in_y <= x2;
                        mont_B_in_valid <= 1'b1;
                        mont_B_in_x <= x1;
                        mont_B_in_y <= temp2;
                        mont_C_in_valid <= 1'b1;
                        mont_C_in_x <= y2;
                        mont_C_in_y <= z1;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd3: begin
                        if(mont_A_out_valid) begin
                            temp4 <= mont_A_out;//temp4=A2
                            temp5 <= mont_B_out;//temp5=B2
                            temp6 <= mont_C_out;//temp6=C2
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd4:begin
                        suber_data_in_valid <= 1'b1;
                        suber_data_in_a <= temp4;
                        suber_data_in_b <= temp5;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd5:begin
                        if(suber_data_out_valid) begin
                            temp7 <= suber_data_out;//temp7=H
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd6:begin
                        mont_A_in_valid <= 1'b1;
                        mont_A_in_x <= temp7;
                        mont_A_in_y <= temp7;
                        mont_B_in_valid <= 1'b1;
                        mont_B_in_x <= temp2;
                        mont_B_in_y <= temp3;
                        mont_C_in_valid <= 1'b1;
                        mont_C_in_x <= temp1;
                        mont_C_in_y <= temp6;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd7:begin
                        if(mont_A_out_valid) begin
                            temp1 <= mont_A_out;//temp1=A3
                            temp2 <= mont_B_out;//temp2=B3
                            temp8 <= mont_B_out;//temp8=B3
                            temp3 <= mont_C_out;//temp3=C3
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd8:begin
                        suber_data_in_valid <= 1'b1;
                        suber_data_in_a <= temp3;
                        suber_data_in_b <= temp2;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd9:begin
                        if(suber_data_out_valid) begin
                            temp6 <= suber_data_out;//temp6=R
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd10:begin
                        mont_A_in_valid <= 1'b1;
                        mont_A_in_x <= temp1;
                        mont_A_in_y <= temp7;
                        mont_B_in_valid <= 1'b1;
                        mont_B_in_x <= temp5;
                        mont_B_in_y <= temp1;
                        mont_C_in_valid <= 1'b1;
                        mont_C_in_x <= temp6;
                        mont_C_in_y <= temp6;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd11:begin
                        if(mont_A_out_valid) begin
                            temp1 <= mont_A_out;//temp1=A4
                            temp2 <= mont_B_out;//temp2=B4
                            temp3 <= mont_C_out;//temp3=C4
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd12:begin
                        suber_data_in_valid <= 1'b1;
                        suber_data_in_a <= temp3;
                        suber_data_in_b <= temp1;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd13:begin
                        if(suber_data_out_valid) begin
                            temp5 <= suber_data_out;//temp5=C4-A4
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd14:begin
                        adder_data_in_valid <= 1'b1;
                        adder_data_in_a <= temp2;
                        adder_data_in_b <= temp2;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd15:begin
                        if(adder_data_out_valid) begin
                            temp4 <= adder_data_out;//temp4=2*B4
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd16:begin
                        suber_data_in_valid <= 1'b1;
                        suber_data_in_a <= temp5;
                        suber_data_in_b <= temp4;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd17:begin
                        if(suber_data_out_valid) begin
                            temp5 <= suber_data_out;//temp5=X3
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd18:begin
                        suber_data_in_valid <= 1'b1;
                        suber_data_in_a <= temp2;
                        suber_data_in_b <= temp5;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd19:begin
                        if(suber_data_out_valid) begin
                            temp4 <= suber_data_out;//temp4=T
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd20:begin
                        mont_A_in_valid <= 1'b1;
                        mont_A_in_x <= temp6;
                        mont_A_in_y <= temp4;
                        mont_B_in_valid <= 1'b1;
                        mont_B_in_x <= temp1;
                        mont_B_in_y <= temp8;
                        mont_C_in_valid <= 1'b1;
                        mont_C_in_x <= z1;
                        mont_C_in_y <= z2;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd21:begin
                        if(mont_A_out_valid) begin
                            temp1 <= mont_A_out;//temp1=A5
                            temp2 <= mont_B_out;//temp2=B5
                            temp3 <= mont_C_out;//temp3=C5
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd22:begin
                        mont_C_in_valid <= 1'b1;
                        mont_C_in_x <= temp7;
                        mont_C_in_y <= temp3;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd23:begin
                        suber_data_in_valid <= 1'b1;
                        suber_data_in_a <= temp1;
                        suber_data_in_b <= temp2;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd24:begin
                        if(suber_data_out_valid) begin
                            temp1 <= suber_data_out;//temp1=Y3
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd25:begin
                        if(mont_C_out_valid) begin
                            temp3 <= mont_C_out;//temp3=Z3
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd26:begin
                        x1 <= temp5;
                        y1 <= temp1;
                        z1 <= temp3;
                        step_cnt <= step_cnt + 7'd1;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd27:begin
                        cal_cnt <= 6'd0;             
                    end
                    default: begin
                        cal_cnt <= 6'd0;
                    end
                endcase
            end
            DONE: begin
                case(cal_cnt)
                    6'd0: begin
                        mont_A_in_valid <= 1'b1;
                        mont_A_in_x <= x1;
                        mont_A_in_y <= 1;
                        mont_B_in_valid <= 1'b1;
                        mont_B_in_x <= y1;
                        mont_B_in_y <= 1;
                        mont_C_in_valid <= 1'b1;
                        mont_C_in_x <= z1;
                        mont_C_in_y <= 1;
                        cal_cnt <= cal_cnt + 1;
                    end
                    6'd1: begin
                        if(mont_A_out_valid) begin
                            x1 <= mont_A_out;
                            y1 <= mont_B_out;
                            z1 <= mont_C_out;
                            cal_cnt <= cal_cnt + 1;
                        end
                    end
                    6'd2: begin
                        out_data_x <= x1;
                        out_data_y <= y1;
                        out_data_z <= z1;
                        out_valid <= 1'b1;
                    end
                endcase
            end
            default: begin
                
            end
        endcase
    end



endmodule
