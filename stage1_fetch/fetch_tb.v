<<<<<<< HEAD
`timescale 1ns/1ps
`include "IF_ID_Register.v"
`include "Instruction_Fetch.v"

module tb_fetch () ;
    reg        clk;
    reg        rst;
    reg        stall;
    reg        flush;
    reg        branch_taken;
    reg [31:0] branch_target;

    wire [31:0] PC;
    wire [31:0] next_PC;
    wire [31:0] PC_plus_4;
    wire [31:0] instruction;
    wire [31:0] id_PC;
    wire [31:0] id_PC_plus_4;
    wire [31:0] id_instruction;
    
    Instruction_Fetch DUT1 (
        .clk          (clk),
        .rst          (rst),
        .stall        (stall),
        .branch_taken (branch_taken),
        .branch_target(branch_target),
        .PC           (PC),
        .next_PC      (next_PC),
        .PC_plus_4    (PC_plus_4),
        .instruction  (instruction)
    );

    IF_ID_Register DUT2 (
        .clk           (clk),
        .rst           (rst),
        .stall         (stall),
        .flush         (flush),
        .if_PC         (PC),
        .if_PC_plus_4   (PC_plus_4),
        .if_instruction(instruction),
        .id_PC         (id_PC),
        .id_PC_plus_4   (id_PC_plus_4),
        .id_instruction(id_instruction)
    );

    always #5 clk =~clk;
        
    initial begin
        $dumpfile("fetch_test.vcd");
        $dumpvars(0, tb_fetch);

        // Initialize signals
        clk           = 0;
        rst           = 1;
        stall         = 0;
        flush         = 0;
        branch_taken  = 0;
        branch_target = 32'd0;

        // Realease reset
        #20; rst = 0;
        #30;

        //stall
        stall = 1; #20;
        stall = 0; #10;

        // branch taken
        branch_target = 32'h0000_0008;
        branch_taken  = 1; #10;
        branch_taken  = 0; #10;

        //flush
        flush = 1; #10;
        flush = 0;
        #30;
        $finish;
    end

=======
`timescale 1ns/1ps
`include "IF_ID_Register.v"
`include "Instruction_Fetch.v"

module tb_fetch () ;
    reg        clk;
    reg        rst;
    reg        stall;
    reg        flush;
    reg        branch_taken;
    reg [31:0] branch_target;

    wire [31:0] PC;
    wire [31:0] next_PC;
    wire [31:0] PC_plus_4;
    wire [31:0] instruction;
    wire [31:0] id_PC;
    wire [31:0] id_PC_plus_4;
    wire [31:0] id_instruction;
    
    Instruction_Fetch DUT1 (
        .clk          (clk),
        .rst          (rst),
        .stall        (stall),
        .branch_taken (branch_taken),
        .branch_target(branch_target),
        .PC           (PC),
        .next_PC      (next_PC),
        .PC_plus_4    (PC_plus_4),
        .instruction  (instruction)
    );

    IF_ID_Register DUT2 (
        .clk           (clk),
        .rst           (rst),
        .stall         (stall),
        .flush         (flush),
        .if_PC         (PC),
        .if_PC_plus_4   (PC_plus_4),
        .if_instruction(instruction),
        .id_PC         (id_PC),
        .id_PC_plus_4   (id_PC_plus_4),
        .id_instruction(id_instruction)
    );

    always #5 clk =~clk;
        
    initial begin
        $dumpfile("fetch_test.vcd");
        $dumpvars(0, tb_fetch);

        // Initialize signals
        clk           = 0;
        rst           = 1;
        stall         = 0;
        flush         = 0;
        branch_taken  = 0;
        branch_target = 32'd0;

        // Realease reset
        #20; rst = 0;
        #30;

        //stall
        stall = 1; #20;
        stall = 0; #10;

        // branch taken
        branch_target = 32'h0000_0008;
        branch_taken  = 1; #10;
        branch_taken  = 0; #10;

        //flush
        flush = 1; #10;
        flush = 0;
        #30;
        $finish;
    end

>>>>>>> b5d2ff7c0eaf276085ffe92987a275a5a59546a7
endmodule