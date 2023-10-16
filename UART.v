`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2023 04:58:35 PM
// Design Name: 
// Module Name: UART
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


module UART
#(parameter D_bits = 8 , S_TICKS = 16)(
    input clk,
    input reset_n,
    
    input rx,
    input rd_uart,
    output [D_bits -1 : 0] rd_data,
    output rx_empty,
    
    
    input [D_bits -1 : 0] w_data,
    input wr_uart,
    output tx,
    output tx_full
    
    );
    
    integer TICKS = 163;
    wire tick;
    
    BRG #(.BITS(4)) BRG0(
            .clk(clk),
            .reset_n(reset_n), 
            .TICKS(TICKS),
            .tick_done(tick)
            );
            
   //reciver
   
   wire RX_done;
   wire [D_bits -1 : 0] rx_data;
   UART_RX #(.D_bits(D_bits),.S_TICKS(S_TICKS)) RX_UART(
        .clk(clk),
         .reset_n(reset_n), 
         .rx(rx),
         .tick(tick),
         .RX_done(RX_done),
         .dataout(rx_data) 
   );
      
  fifo_generator_0 RX_UART_FIFO (
  .clk(clk),      // input wire clk
  .srst(reset_n),    // input wire srst
  .din(rx_data),      // input wire [7 : 0] din
  .wr_en(RX_done),  // input wire wr_en
  .rd_en(rd_uart),  // input wire rd_en
  .dout(rd_data),    // output wire [7 : 0] dout
  .full(),    // output wire full
  .empty(rx_empty)  // output wire empty
);


// TX
wire tx_fifo_empty , TX_done_Tick;
wire [D_bits -1 : 0] tx_in;
UART_TX #(.D_bits(D_bits),.S_TICKS(S_TICKS)) TX_UART(
        .clk(clk),
       .reset_n(reset_n),
       .tx_start(~tx_fifo_empty),
       .tx_n(tx_in),
       .tick(tick),
       .TX(tx),
        .TX_done_Tick(TX_done_Tick)
);

fifo_generator_0 TX_UART_FIFO (
  .clk(clk),      // input wire clk
  .srst(reset_n),    // input wire srst
  .din(w_data),      // input wire [7 : 0] din
  .wr_en(wr_uart),  // input wire wr_en
  .rd_en(TX_done_Tick),  // input wire rd_en
  .dout(tx_in),    // output wire [7 : 0] dout
  .full(tx_full),    // output wire full
  .empty(tx_fifo_empty)  // output wire empty
);
endmodule
