`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/12/2022 03:04:21 PM
// Design Name: 
// Module Name: sim_lab1
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


module sim_lab1(
    );
    
    reg clk;
    reg clr; //for first counter; this is a button
    reg BTN;
    wire [3:0]an;
    wire [6:0]seg;
    
    
    lab1_top lab(.clk(clk), .clr(clr), .BTN(BTN), .an(an), .seg(seg));
    
    
    initial
    begin
    clk = 0;
    forever #5 clk = ~clk;
    end
    
    initial
    begin
    clr = 0;
    #20
    clr = 1;
    #60
    clr = 0;
    
    
    end
endmodule
