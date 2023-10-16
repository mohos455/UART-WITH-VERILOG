`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2023 03:36:54 PM
// Design Name: 
// Module Name: BRG
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


module BRG #(parameter BITS = 4) (
    input clk,
    input reset_n,
    input [BITS-1 : 0] TICKS,
    output tick_done
    );
    reg [BITS-1 : 0 ] state_reg, state_next;
    always @(posedge clk , negedge reset_n)
    begin
        if(!reset_n)
            state_reg <= 0;
        else
            state_reg <=state_next;
    end
    
    assign tick_done = ( state_reg == TICKS);
    always @(*)
        begin
            state_next = tick_done ? 'b0 : state_reg +1 ;
        end
endmodule
