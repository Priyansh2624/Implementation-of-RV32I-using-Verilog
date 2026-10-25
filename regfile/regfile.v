`timescale 1ns / 1ps
module regfile(
    input clk,
    input rst,
    input [4:0] rs1_addr,rs2_addr, //input address
    input reg_write,
    input [4:0]rd_addr, //read address
    input [31:0] rd_data, // input data
    output [31:0] rs1_data, rs2_data //output read data
    );
    integer i;
    reg [31:0] regs [0:31]; //memory array 32bits x 32 registers
    always@(posedge clk) begin
       if(rst) begin
       for(i=0;i<32;i=i+1)
       regs[i]<=32'd0;
       end
       else if(reg_write && rd_addr!=5'b00000)begin
       regs[rd_addr]<=rd_data;
       end
    end
   assign rs1_data = (rs1_addr==5'd0)?32'd0:regs[rs1_addr];
   assign rs2_data= (rs2_addr==5'd0)?32'd0:regs[rs2_addr];
endmodule
