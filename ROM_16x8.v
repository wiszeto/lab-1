`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 12/17/2021 12:09:56 PM
// Design Name: 
// Module Name: ROM_16X8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Simple 16x8 ROM
//
// Instantiation Template
//
//   ROM_16x8 my_ROM (
//      .addr  (xxxx),  
//      .data  (xxxx),  
//      .rd_en (xxxx)    );
// 
// Dependencies: 
// 
// Revision:
// Revision 1.00 - File Created (12-17-2021)
//
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ROM_16x8(
   input [3:0] addr,   // address
   output [7:0] data,  // data
   input rd_en         // read enable
);
          
   reg [7:0] ROM [0:15];  // ROM definition     

   initial begin
        $readmemh("exp1_ROM.mem", ROM, 0, 15);
   end

   assign data = (rd_en) ? ROM[addr] : 8'h00;
  
endmodule
