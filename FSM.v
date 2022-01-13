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
    input prime,
    input done,
    input rco,
    output reg start_output,
    output reg up,
    output reg we,
    output reg p_up
    ); 
     
    //- next state & present state variables
    reg [2:0] NS, PS; 
    //- bit-level state representations
    parameter [2:0] w8=3'b000, starta=3'b001, looka=3'b010, storea=3'b011, reada=3'b100, finala=3'b101; 
    

    //- model the state registers
    always @ (negedge reset_n, posedge clk)
       if (reset_n == 0) 
          PS <= w8; 
       else
          PS <= NS; 
    
    
    //- model the next-state and output decoders
    always @ (*)
    begin
       start_output = 0; up = 0; we = 0; p_up = 0; // assign all outputs
       case(PS)
          w8: //--------------------------------------------------------------------------------------------------state 1(w8)
          begin    
             up = 0; 
             if (go_btn == 1) NS = starta; // if go is pressed, move to start state
             else NS = w8; // else stay in same state
          end
          
          starta: //--------------------------------------------------------------------------------------------------state 2(start)
             begin
                up = 1;
                start_output = 1;
                NS = looka;
             end   
             
          looka: //--------------------------------------------------------------------------------------------------state 3(look)
             begin
                start_output = 0;
                if (~done) NS = looka;
                else if (done == 1 && prime == 1) NS = storea;
                else if (done == 1 && prime == 0) NS = reada;
             end

          storea: //--------------------------------------------------------------------------------------------------state 4(store)
             begin
                p_up = 1;
                we = 1;
                if (rco) NS = finala;
                else if (~rco) NS = starta;
             end  

          reada: //--------------------------------------------------------------------------------------------------state 5(read)
             begin
                we = 0;
                if (rco) NS = finala;
                else if (~rco) NS = starta;
             end   

          finala: //--------------------------------------------------------------------------------------------------state 6(final)
             begin
             
             end  
             
          default: NS = w8; 
            
          endcase
      end              
endmodule


