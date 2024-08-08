`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Saideep
// 
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Test bench Code
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb;

//All inputsare Reg and Outputs are Wire

reg clk=0;
reg [7:0] Raw_data;
reg start= 0;
wire  [7:0] Extracted_data;
wire transmit_done, receive_done;

wire txrx; //  This acts as a wire b/w TX and RX

TX_RX DUT (clk,Raw_data,start,txrx,txrx,Extracted_data,transmit_done,receive_done); // Implicit Declaration 
integer i = 0;


 initial 
 begin
 start = 1;
 for(i = 0; i < 10; i = i + 1) begin
 Raw_data = $urandom_range(10 , 200);
 
 @(posedge transmit_done); // wait for pose edge
 @(posedge receive_done); // wait for neg edge

 end
 $stop; 
 end
 
 always #5 clk = ~clk;
 
 endmodule


