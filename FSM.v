`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer:  James Ratner
// 
// Create Date: 07/07/2018 08:05:03 AM
// Description: Generic FSM model with both Mealy & Moore outputs. 
//    Note: data widths of state variables are not specified 
//////////////////////////////////////////////////////////////////////////////////

module FSM(clk, clr, go_btn, start_output, up, done, prime, rco, we, p_up); 
    input  clk, go_btn, done, prime, rco; 
    output start_output, up, we, clr, p_up;
     
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
    always @ (PS) // <------------------------------------------change this.
    begin
       start_output = 0; up = 0; we = 0; clr = 0; p_up = 0;// assign all outputs
       case(PS)
          w8: //--------------------------------------------------------------------------------------------------state 1(w8)
          begin     
             up = 0; 
             if (go_btn == 1) NS = start; // if go is pressed, move to start state
             else NS = w8; // else stay in same state
          end
          
          start: //--------------------------------------------------------------------------------------------------state 2(start)
             begin
                up = 1;
                start_output = 1;
                NS = look;
             end   
             
          look: //--------------------------------------------------------------------------------------------------state 3(look)
             begin
                start_output = 0;
                if (~done) NS = look;
                else if (done == 1 && prime == 0) NS = store;
                else if (done == 1 && prime == 1) NS = read;
             end

          store: //--------------------------------------------------------------------------------------------------state 4(store)
             begin
                p_up = 1;
                we = 1;
                if (rco) NS = final;
                else if (~rco) NS = start;
             end  

          read: //--------------------------------------------------------------------------------------------------state 5(read)
             begin
                we = 0;
                if (rco) NS = final;
                else if (~rco) NS = start;
             end   

          final: //--------------------------------------------------------------------------------------------------state 6(final)
             begin
                clr = 1;
             end   

          default: NS = w8; 
            
          endcase
      end              
endmodule


