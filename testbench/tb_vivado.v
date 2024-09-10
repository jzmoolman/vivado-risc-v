`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2024 10:54:13 AM
// Design Name: 
// Module Name: tb_rocketchip
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


module tb_rocketchip();
    reg clk;
    reg clk_ok;
    wire out;
    
    
    localparam CLK_PERIOD = 10;
    
    initial clk = 1'b0;
    initial clk_ok = 1'b1;
    always # ( CLK_PERIOD/2.0)
       clk =~clk;
       
   Rocket64x1 dut (
       .clock(clk),
       .clock_ok(clk_ok)
   );
       

endmodule
