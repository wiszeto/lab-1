`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Top(
    input clk,
    input clr,
    input BTN,
    output [7:0] seg,
    output [3:0] an
  );

  wire data;
  wire start;
  wire rco;
  wire [3:0] count;
  wire [7:0] ROM_data_out;
  wire slw_clk;
  wire up;
  wire p_up;
  wire prime;
  wire we;
  wire [7:0] dout;
  wire done;
  wire [3:0] p_count;
  wire [3:0] d_count;
  wire [3:0] mux_addr;
  wire [7:0] mux_data;
  wire EQ;

  clk_2n_div_test #(.n(25)) MY_DIV (.clockin(clk), .fclk_only(1'b1), .clockout(slw_clk));  // on = in sim, off = board -- for fclk_only
  Counter_Up_Only #(4) cntr(.clk(slw_clk), .clr(clr), .up(up), .ld(1'b0), .D(1'b0), .count(count), .rco(rco));
  ROM_16x8 ROM(.addr(count), .data(ROM_data_out[7:0]), .rd_en(1'b1));
  prime_num_check check(.clk(slw_clk), .test(1'b1), .start(start), .num({2'b00,ROM_data_out}), .DONE(done), .PRIME(prime));
  FSM fsm(.reset_n(clr), .go_btn(BTN), .clk(slw_clk), .done(done), .rco(rco), .start_output(start), .up(up), .we(we), .p_up(p_up), .prime(prime));
  Counter_Up_Only #(4) cntr1(.clk(slw_clk), .clr(clr), .up(p_up), .ld(1'b0), .D(1'b0), .count(p_count));
  Counter_Up_Only #(4) cntr2(.clk(slw_clk), .clr(EQ), .up(d_up), .ld(1'b0), .D(1'b0), .count(d_count));
  ram_single_port #(.n(4),.m(8)) my_ram(.data_in(ROM_data_out), .addr(p_count), .we(we), .clk(slw_clk), .data_out(dout)); 
  mux_2t1_nb #(4) mux1(.D0(p_count[3:0]), .D1(d_count[3:0]), .SEL(RCO), .D_OUT(mux_addr[3:0]));
  mux_2t1_nb #(8) mux_data_in(.D0(ROM_data_out), .D1(dout[7:0]), .SEL(RCO), .D_OUT(mux_data[7:0]));
  Comparator #(4) compar(.a(p_count[3:0]), .b(d_count[3:0]), .eq(EQ));
  univ_sseg display(.cnt1({6'b000000, dout[7:0]}), .cnt2({3'b000, count[3:0]}), .valid(1'b1), .dp_en(1'b0), .mod_sel(2'b01), .sign(1'b0), .clk(slw_clk), .ssegs(seg[7:0]), .disp_en(an[3:0]));
endmodule
