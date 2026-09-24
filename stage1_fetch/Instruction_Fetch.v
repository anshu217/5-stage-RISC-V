`timescale 1ns/1ps
module  Instruction_Fetch (
    input wire clk, 
    input wire rst,  
    input wire stall, 
    input wire branch_taken,
    input wire [31:0] branch_target,
    output reg [31:0] PC, 
    output wire [31:0] next_PC,
    output wire [31:0] PC_plus_4, 
    output wire [31:0] instruction
);
    reg [31:0] imem [0:63];
    assign PC_plus_4  =  PC + 32'd4;
    assign next_PC = branch_taken ? branch_target : PC_plus_4;  
    assign instruction = imem[PC[7:2]];
    always @ (posedge clk) begin 
        if (rst) begin 
            PC <= 'd0; 
        end  
        else if (!stall) begin 
            PC <= next_PC;
        end
    end
    initial begin
    imem[0] = 32'h00500093; // addi x1, x0, 5
    imem[1] = 32'h00a00113; // addi x2, x0, 10
    imem[2] = 32'h002081b3; // add  x3, x1, x2
    imem[3] = 32'h40208233; // sub  x4, x1, x2
    imem[4] = 32'h003102b3; // add  x5, x2, x3
    imem[5] = 32'h00000013; // nop
end
endmodule
