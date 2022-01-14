`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Top(
    input clk,
    input BTN,
    output [7:0] seg,
    output [3:0] an
  );
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

  //Slowing down the clk to 2Hz clk
  clk_2n_div_test #(.n(25)) MY_DIV (.clockin(clk), .fclk_only(1'b0), .clockout(slw_clk));  // on = in sim, off = board -- for fclk_only
  
  //Counter to read the ROM 
  Counter_Up_Only #(4) rom_cntr(.clk(slw_clk), .clr(clr), .up(up), .ld(1'b0), .D(1'b0), .count(count), .rco(rco));
  ROM_16x8 ROM(.addr(count), .data(ROM_data_out[7:0]), .rd_en(1'b1));
  
  //Checking if the data from the ROM is prime
  prime_num_check check(.clk(slw_clk), .test(1'b0), .start(start), .num({2'b00, ROM_data_out}), .DONE(done), .PRIME(prime));
  FSM fsm(.reset_n(clr), .go_btn(BTN), .clk(slw_clk), .done(done), .rco(rco), .start_output(start), .up(up), .we(we), .p_up(p_up), .prime(prime));
  
  //Prime Count, counts the number of primes in the ROM
  Counter_Up_Only #(4) prime_cntr(.clk(slw_clk), .clr(clr), .up(p_up), .ld(1'b0), .D(1'b0), .count(p_count));
  
  //Deciding to use the prime_count or done_count to read/store in the RAM
  mux_2t1_nb #(4) mux1(.D0(p_count[3:0]), .D1(d_count[3:0]), .SEL(rco), .D_OUT(mux_addr[3:0]));
  
  //Deciding to use the data from the ROM or RAM to put into the display
  mux_2t1_nb #(8) mux_data_in(.D0(ROM_data_out), .D1(dout[7:0]), .SEL(rco), .D_OUT(mux_data[7:0]));
  //Done count, after going through the ROM will use it to read all the primes from the RAM
  
  Counter_Up_Only #(4) done_cntr(.clk(slw_clk), .clr(EQ), .up(d_up), .ld(1'b0), .D(1'b0), .count(d_count));
  ram_single_port #(.n(4),.m(8)) my_ram(.data_in(ROM_data_out), .addr(mux_addr), .we(we), .clk(slw_clk), .data_out(dout)); 
  
  //Comparing to see if the d_count == p_count if so EQ on, and it clears d_count
  Comparator #(4) compar(.a(p_count[3:0]), .b(d_count[3:0]), .eq(EQ));
  
  univ_sseg display(.cnt1({6'b000000, mux_data[7:0]}), .cnt2({3'b000, mux_addr[3:0]}), .valid(1'b1), .dp_en(1'b0), .mod_sel(2'b01), .sign(1'b0), .clk(clk), .ssegs(seg[7:0]), .disp_en(an[3:0]));
endmodule
