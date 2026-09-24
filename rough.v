`timescale 1ns / 1ps

module Instruction_Fetch (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,          // Active high: PC ko freeze karta hai (load-use hazard)
    input  wire        branch_taken,   // Active high: 1 hone par PC branch_target par jump karega
    input  wire [31:0] branch_target,  // Target address jo EX stage se calculate hokar aayega
    output reg  [31:0] PC,             // Current instruction ka address
    output wire [31:0] next_PC,        // Agla instruction address (MUX output)
    output wire [31:0] PC_plus_4,      // Sequential next address
    output wire [31:0] instruction     // Memory se nikli hui 32-bit instruction
);

    // 64-word depth ki Instruction Memory (har word 32 bits ka)
    reg [31:0] imem [0:63];

    // 1. Next sequential address calculation
    assign PC_plus_4 = PC + 32'd4;

    // 2. 2-to-1 MUX: Branch lena hai ya agla sequential address
    assign next_PC = (branch_taken) ? branch_target : PC_plus_4;

    // 3. Instruction memory read (Word alignment: lower 2 bits [1:0] drop karte hain)
    // PC[7:2] use karke 64 locations (0 to 63) index hoti hain
    assign instruction = imem[PC[7:2]];

    // 4. Program Counter (PC) Register
    always @(posedge clk) begin
        if (rst) begin
            PC <= 32'd0;                // Reset par address 0x00000000 load hoga
        end else if (!stall) begin
            PC <= next_PC;             // Agar stall nahi hai, toh agle address par jao
        end
        // Agar stall == 1 hai, toh PC apni current value hold karega (freeze)
    end

endmodule


`timescale 1ns / 1ps

module IF_ID_Register (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,          // Active high: Pipeline ko freeze rakhta hai
    input  wire        flush,          // Active high: Branch mispredict par instruction ko NOP banata hai
    input  wire [31:0] if_PC,          // Fetch stage se aane wala current PC
    input  wire [31:0] if_PC_plus_4,    // Fetch stage se aane wala PC + 4
    input  wire [31:0] if_instruction, // Fetch stage se aane wali raw instruction
    output reg  [31:0] id_PC,          // Decode stage ke liye latched PC
    output reg  [31:0] id_PC_plus_4,    // Decode stage ke liye latched PC + 4
    output reg  [31:0] id_instruction  // Decode stage ke liye latched instruction
);

    // RISC-V RV32I standard NOP (addi x0, x0, 0)
    localparam NOP = 32'h0000_0013;

    always @(posedge clk) begin
        // Reset ya Flush dono conditions me NOP insert hoga
        if (rst || flush) begin
            id_PC          <= 32'd0;
            id_PC_plus_4   <= 32'd0;
            id_instruction <= NOP;
        end 
        // Jab stall NAHI hai tabhi naye values aage propagate honge
        else if (!stall) begin
            id_PC          <= if_PC;
            id_PC_plus_4   <= if_PC_plus_4;
            id_instruction <= if_instruction;
        end
        // Agar stall == 1 hai, toh flip-flops previous value preserve rakhenge
    end

endmodule


`timescale 1ns / 1ps

module tb_fetch ();

    // Stimulus drive karne ke liye registers
    reg        clk;
    reg        rst;
    reg        stall;
    reg        flush;
    reg        branch_taken;
    reg [31:0] branch_target;

    // Submodules ke outputs monitor karne ke liye wires
    wire [31:0] PC;
    wire [31:0] next_PC;
    wire [31:0] PC_plus_4;
    wire [31:0] instruction;

    wire [31:0] id_PC;
    wire [31:0] id_PC_plus_4;
    wire [31:0] id_instruction;

    // 1. Fetch stage instance
    Instruction_Fetch uut_fetch (
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

    // 2. IF/ID Pipeline Register instance (Fetch ke outputs register ke inputs banenge)
    IF_ID_Register uut_if_id (
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

    // 3. Clock generator: 10ns time period (100 MHz clock)
    always #5 clk = ~clk;

    // 4. Test Scenarios
    initial begin
        // GTKWave waveform dump setup
        $dumpfile("fetch_test.vcd");
        $dumpvars(0, tb_fetch);

        // Pre-load instruction memory with sample RV32I machine instructions
        uut_fetch.imem[0] = 32'h00500093; // addi x1, x0, 5     (Address 0x00)
        uut_fetch.imem[1] = 32'h00a00113; // addi x2, x0, 10    (Address 0x04)
        uut_fetch.imem[2] = 32'h002081b3; // add  x3, x1, x2    (Address 0x08)
        uut_fetch.imem[3] = 32'h40208233; // sub  x4, x1, x2    (Address 0x0C)
        uut_fetch.imem[4] = 32'h003102b3; // add  x5, x2, x3    (Address 0x10)
        uut_fetch.imem[5] = 32'h00000013; // nop                (Address 0x14)

        // Initialize signals
        clk           = 0;
        rst           = 1;
        stall         = 0;
        flush         = 0;
        branch_taken  = 0;
        branch_target = 32'd0;

        // --- Scenario 1: Apply Reset ---
        #20;
        rst = 0; // Reset release, execution begins from PC = 0x00

        // --- Scenario 2: Normal Sequential Streaming ---
        // Instructions sequentially advance: 0x0 -> 0x4 -> 0x8
        #30;

        // --- Scenario 3: Test Hazard Stall ---
        // Stall 2 clock cycles ke liye assert hoga (PC and ID reg freeze hone chahiye)
        stall = 1;
        #20;
        stall = 0; // Resume execution
        #10;

        // --- Scenario 4: Test Branch Taken ---
        // Jump to instruction at address 0x08 directly
        branch_target = 32'h0000_0008;
        branch_taken  = 1;
        #10;
        branch_taken  = 0; // De-assert branch
        #10;

        // --- Scenario 5: Test Branch Flush ---
        // Flush wrong instruction out of pipeline register (injects NOP)
        flush = 1;
        #10;
        flush = 0;

        // Let simulation run for a couple more cycles, then terminate
        #30;
        $finish;
    end

endmodule