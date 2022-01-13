`timescale 1ps/1ps

module lab1_top(
    input clk,
    input clr, //for first counter, this is a button
    input BTN,
    output [3:0]an,
    output [7:0]seg
    );

    wire [3:0] count;
    wire [3:0] p_count;
    wire [3:0] d_count;
    wire WE;
    wire RCO;
    wire sel;
    wire prime;
    wire done;
    wire EQ;
    wire p_up;
    wire [7:0]RAM_data_out;
    wire [7:0]ROM_data_out;
    wire [3:0]mux1_out;
    wire [7:0]mux2_out;
    wire slw_clk;
    wire start;
    wire up;

    clk_2n_div_test #(.n(1)) MY_DIV (.clockin(clk), .fclk_only(1), .clockout(slw_clk));  // on = in sim, off = board -- for fclk_only
    Counter_Up_Only #(.n(4)) cntr(.clk(slw_clk), .clr(clr), .up(up), .count(count[3:0]), .rco(RCO));
    ROM_16x8 ROM(.addr(count[3:0]), .data(ROM_data_out[7:0]), .rd_en(1'b1));
    assign start = 1;
    
    prime_num_check check(.clk(slw_clk), .start(start), .test(1'b1), .num({2'b00, ROM_data_out}), .DONE(done), .PRIME(prime)); // on = in sim, off = board -- for test || also missing clock?
    prime_count #(4) p_cntr(.clk(slw_clk), .clr(1'b0), .p_up(p_up), .count(p_count[3:0]));
    done_count #(4) d_cntr(.clk(slw_clk), .d_up(RCO), .clr(EQ), .count(d_count[3:0]));
    mux_2t1_nb #(4) mux1(.D0(p_count[3:0]), .D1(d_count[3:0]), .SEL(RCO), .D_OUT(mux1_out[3:0]));
    Comparator #(4) compar(.a(p_count[3:0]), .b(d_count[3:0]), .eq(EQ));
    ram_single_port #(.n(16), .m(8)) RAM(.data_in(ROM_data_out[7:0]), .addr(mux1_out[3:0]), .we(WE), .clk(slw_clk), .data_out(RAM_data_out[7:0]));
    mux_2t1_nb #(8) mux2(.D0(ROM_data_out[7:0]), .D1(RAM_data_out[7:0]), .SEL(RCO), .D_OUT(mux2_out[7:0]));
    univ_sseg display(.cnt1({6'b000000, mux2_out[7:0]}), .cnt2({3'b000, mux1_out[3:0]}), .valid(1'b1), .dp_en(1'b0), .mod_sel(2'b01), .sign(1'b0), .clk(slw_clk), .ssegs(seg[7:0]), .disp_en(an[3:0]));
    FSM fsm(.reset_n(clr), .clk(slw_clk), .go_btn(BTN), .done(done), .prime(prime), .rco(RCO), .start_output(start), .up(up), .we(WE), .p_up(p_up));
endmodule 
