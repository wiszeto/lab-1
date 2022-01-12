`timescale 1ps/1ps

module lab1_top(
    input clk,
    input clr, //for first counter, this is a button
    input BTN,
    output [3:0]an,
    output [6:0]seg
    );

    logic [3:0] count;
    logic [3:0] p_count;
    logic [3:0] d_count;
    logic WE;
    logic RCO;
    logic sel;
    logic prime;
    logic done;
    logic EQ;
    logic [7:0]RAM_data_out;
    logic [7:0]ROM_data_out;
    logic [3:0]mux1_out;
    logic [7:0]mux2_out;
    logic slw_clk;
    logic start;
    logic up;

    clk_div2 clk_div(.clk(clk), .sclk(slw_clk));
    Counter_Up_Only #(8) cntr(.clk(slw_clk), .clr(clr), .up(up), .count(count[3:0]), .rco(RCO));
    ROM_16x8 ROM(.addr(count[3:0]), .data(ROM_data_out[7:0]), .rd_en(1'b1));
    wire[1:0] a = 2'b00;
    wire[9:0] prime_in;
    assign prime_in = {a, ROM_data_out};
    prime_num_check check(.start(start), .test(1'b0), .num(prime_in), .DONE(done), .PRIME(prime)); // num is 10 bits wide???, rom data out is only 8 bit wide
    prime_count #(4) p_cntr(.clk(slw_clk), .clr(1'b0), .p_up(prime), .count(p_count[3:0]));
    done_count #(4) d_cntr(.clk(slw_clk), .d_up(RCO), .clr(EQ), .count(d_count[3:0]));
    mux_2t1_nb #(4) mux1(.D0(p_count[3:0]), .D1(d_count[3:0]), .SEL(RCO), .D_OUT(mux1_out[3:0]));
    Comparator compar(.a(p_count[3:0]), .b(d_count[3:0]), eq(EQ));
    ram_single_port #(16, 8) RAM(.data_in(ROM_data_out[7:0]), .addr(mux1_out[3:0]), .we(WE), .clk(slw_clk), .data_out(RAM_data_out[7:0]));
    mux2t1_nb #(8) mux2(.D0(ROM_data_out[7:0]), .D1(RAM_data_out[7:0]), .SEL(RCO), .D_OUT(mux2_out[7:0]));
    univ_sseg display(.cnt1(mux2_out[7:0]), .cnt2(mux1_out[3:0]), .valid(1'b1), .dp_en(1'b0), .mod_sel(2'b01), .sign(1'b0), .clk(slw_clk), .ssegs(seg), .disp_en(an));
    FSM fsm(.clk(slw_clk), .clr(clr), .go_btn(BTN), .start_output(start), .up(up), .done(done), .prime(prime), .rco(rco), .we(WE), p_up(p_up));
