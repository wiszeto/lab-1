`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer:  James Ratner
// 
// Create Date: 07/07/2018 08:05:03 AM
// Description: Generic FSM model with both Mealy & Moore outputs. 
//    Note: data widths of state variables are not specified 
//////////////////////////////////////////////////////////////////////////////////

module fsm_template(reset_n, x_in, clk, go_btn, start_output, up, done, prime, rco, we, mealy, moore); 
    input  reset_n, x_in, clk, go_btn, done, prime, rco, we; 
    output reg mealy, moore, start_output, up;
     
    //- next state & present state variables
    reg [2:0] NS, PS; 
    //- bit-level state representations
    parameter [2:0] w8=3'b000, start=3'b001, look=3'b010, store=3'b011, read=3'b100, final=3'b101; 
    

    //- model the state registers
    always @ (negedge reset_n, posedge clk)
       if (reset_n == 0) 
          PS <= w8; 
       else
          PS <= NS; 
    
    
    //- model the next-state and output decoders
    always @ (x_in,PS)
    begin
       mealy = 0; moore = 0; // assign all outputs
       case(PS)
          w8:
          begin
             moore = 1;        
             if (x_in == 1)
             begin
                mealy = 0;   
                NS = w8; 
             end  
             else
             begin
                mealy = 1; 
                NS = start; 
             end  
          end
          
          start:
             begin
                moore = 0;
                mealy = 1;
                NS = look;
             end   
             
          look:
             begin
                 moore = 1; 
                 if (x_in == 1)
                 begin
                    mealy = 1; 
                    NS = start; 
                 end  
                 else
                 begin
                    mealy = 0; 
                    NS = w8; 
                 end  
             end
             
          default: NS = w8; 
            
          endcase
      end              
endmodule


