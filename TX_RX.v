`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Saideep
//
// Design Name: 
// Module Name: TX_RX
// Project Name: USART Transimitter and Reciever Design
// Target Devices: 
// Tool Versions: 
// Description: This is Project part of my Verilog Learning Journey!
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TX_RX(
input clk,
input [7:0] Raw_data, //ACtual data to be sent
input start,
input rx, // Reciever part to recieve the data bit by bit.
output reg tx,//Sends data Bit by bit to reciever.
output [7:0] Extracted_data,
output transmit_done, receive_done
);

parameter clk_value = 100_000;
parameter baud = 9600;

parameter wait_count = clk_value / baud;
integer count=0;
integer bit_done=0;

parameter idle = 0, send = 1, check = 2;
reg [1:0] state = idle;
 
//9600 Baud Genertor for every 1/9600 = 104us a trigger is generated setting bit-done = 1

always@(posedge clk)
begin
if(state == idle)
begin
 count <=0;
end
 
else begin
    if(count == wait_count)
        begin
            bit_done <= 1'b1;
            count <=0;
         end
    
    else
        begin
            count <= count+1;
            bit_done <= 1'b0;
            
        end
    
    end
end


//USART Transmitter Design

integer bit_index = 0;

reg [9:0] transmit_data; // contains {stop Raw_data start}
always@(posedge clk)
begin
case(state)
idle:
begin

tx  <= 1'b1; // by default this will be 1
transmit_data   <= 0;
bit_index <=  0;

  if(start == 1'b1)
     begin
         
         transmit_data  <= {1'b1, Raw_data, 1'b0};
         state <=send;
     end
  
  else
     begin
        state <= idle;
     end
end


send:
     begin

        tx <= transmit_data[bit_index];
        state <= check;
     end

check:
    begin
    
    if(bit_index <= 9)
        begin
        if(bit_done == 1'b1)
          begin
             state <= send;
             bit_index <= bit_index + 1; 
             
          end
        end
     else
        begin
          state <= idle;
          bit_index <= 0;
        end
        $monitor("Transmited Data %0d",Raw_data);
    end
default :
     state <= idle;
endcase
end

assign transmit_done = (bit_index == 9  && bit_done== 1 )?1'b1:1'b0;

//USART Reciver Design/////////////////////////////////////////////////////////////////////
integer receive_index = 0;
integer rcount=0;
parameter ridle = 0, rwait = 1, rec = 2;
reg [9:0] received_data; 
reg [1:0] rstate = ridle;

always@(posedge clk)
begin
case(rstate)
ridle:
    begin
    received_data <= 0;
    rcount<=0;
    receive_index <= 0;
    
    if(rx == 1'b0)
        begin
        rstate <= rwait;     
        end
    else
        begin
        rstate <= ridle;
        end    
    end
rwait:
    begin
    if(rcount < wait_count/2)
        begin
        
        rcount <=rcount+1;
        rstate <= rwait;
        end
    else
        begin
        rcount<=0;
        rstate <= rec;
        received_data <= {rx,received_data[9:1]}; 
        end
    end
rec:
    begin
     if(receive_index <= 9)
        begin
        if(bit_done == 1'b1)
            begin
            receive_index = receive_index+1;
            rstate <= rwait;
            end

        end
     else
        begin
         rstate <= ridle;
         receive_index <= 0;
         $display("Recieved Data %0d", Extracted_data);
       
        end    
        
    end
default: rstate<= ridle;
    
endcase


end
assign receive_done = (receive_index == 9  && bit_done== 1 )?1'b1:1'b0;
assign Extracted_data  = received_data[8:1];
endmodule
