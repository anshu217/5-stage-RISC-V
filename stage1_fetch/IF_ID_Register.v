module IF_ID_Register (
    input  wire clk,
    input  wire rst,
    input  wire stall, 
    input  wire flush,          
    input [31:0] if_PC,
    input [31:0] if_PC_plus_4,
    input [31:0] if_instruction,
    output reg [31:0] id_PC,
    output reg [31:0] id_PC_plus_4,
    output reg [31:0] id_instruction
);
    localparam NOP = 32'h0000_0013;
    always @ (posedge clk) begin 
        if (rst || flush) begin 
            id_instruction <= NOP; 
            id_PC          <= 'd0;          // Flushing PC
            id_PC_plus_4   <= 'd0;
        end
        else if (!stall) begin 
            id_instruction <= if_instruction;
            id_PC          <= if_PC;
            id_PC_plus_4   <= if_PC_plus_4;
        end
    end
endmodule