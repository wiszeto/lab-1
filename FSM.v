`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer:  James Ratner
// 
// Create Date: 07/07/2018 08:05:03 AM
// Design Name: 
// Module Name: fsm_template
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Generic FSM model with both Mealy & Moore outputs. 
//    Note: data widths of state variables are not specified 
//
// Dependencies: 
// 
// Revision:
// Revision 1.00 - File Created (07-07-2018) 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FSM(
    input reset_n, //clr
    input go_btn, 
    input clk, 
    input done,
    input rco,
    input prime,
    output reg start_output,
    output reg up,
    output reg we,
    output reg p_up,
    output reg d_up
    ); 
     
    //- next state & present state variables
    reg [2:0] NS, PS; 
    //- bit-level state representations
    parameter [2:0] w8=3'b000, counta=3'b001, checka=3'b010, storea=3'b011, finala=3'b100; 
    
    
    //- model the state registers
    always @ (negedge reset_n, posedge clk)
       if (reset_n == 1) 
          PS <= w8; 
       else
          PS <= NS; 
    
    
    //- model the next-state and output decoders
    always @ (*)
    begin
       start_output = 0; up = 0; we = 0; p_up = 0; d_up = 0;// assign all outputs
       case(PS)
          w8: //--------------------------------------------------------------------------------------------------state 0(w8)
          begin
             up = 0;
             if (go_btn == 1) NS = counta; // if go is pressed, move to start state
             else NS = w8; // else stay in same state
          end
          
          counta: //--------------------------------------------------------------------------------------------------state 1(start)
             begin
             p_up = 0;
             we = 0;
             start_output = 0;
             if (done == 1) 
             begin
             up = 1;
             end
             start_output = 1;
             NS = checka;
             
             
             end   
             
          checka: //--------------------------------------------------------------------------------------------------state 2(check)
             begin
             up = 0;
             we = 0;
             p_up = 0;
             start_output = 0;
             if (done == 1) 
             begin
             if (prime) p_up = 1;
             NS = storea;
             end
             else if (done == 1 && prime == 0) NS = counta;
             else NS = checka;
             end
          storea: //--------------------------------------------------------------------------------------------------state 3(store)
             begin
             we = 1;
             NS = counta;
             end 
          finala: //--------------------------------------------------------------------------------------------------state 4(final)
             begin
             d_up =1;
             end 
          
          default: NS = w8; 
            
          endcase
      end              
endmodule


