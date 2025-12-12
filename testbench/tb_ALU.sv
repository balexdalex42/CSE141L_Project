`timescale 1ns/1ps

module tb_alu;
    logic [7:0] in1, in2;
    logic [1:0] alu_op;
    logic [1:0] branch_sel;
    logic       sub;
    logic       branch;
    logic       shift_left;
    logic [7:0] out_val;

    // Instantiate the ALU
    ALU dut (
        .in1(in1),
        .in2(in2),
        .alu_op(alu_op),
        .branch_sel(branch_sel),
        .sub(sub),
        .branch(branch),
        .shift_left(shift_left),
        .out_val(out_val)
    );

    // Test procedure
    initial begin
        $dumpfile("alu_dump.vcd"); 
        $dumpvars;

        // Initialize all signals
        in1 = 0; in2 = 0;
        alu_op = 0; branch_sel = 0;
        sub = 0; branch = 0; shift_left = 0;

        $display("Time\tType\tOp\tSub\tBr\tBrSel\tL\tIn1\tIn2\t\tOut\tExp\tDesc");

        // Test 1: Addition (10 + 15 = 25)
        in1 = 8'd10; in2 = 8'd15;
        alu_op = 2'b00; sub = 0; branch = 0;
        #10;
        $display("%0t\tADD\t%b\t%b\t%b\t%b\t%b\t%d\t%d\t\t%d\t25\tBasic Addition", 
                 $time, alu_op, sub, branch, branch_sel, shift_left, in1, in2, out_val);

        // Test 2: Subtraction (20 - 5 = 15)
        in1 = 8'd20; in2 = 8'd5;
        alu_op = 2'b00; sub = 1; branch = 0;
        #10;
        $display("%0t\tSUB\t%b\t%b\t%b\t%b\t%b\t%d\t%d\t\t%d\t15\tBasic Subtraction", 
                 $time, alu_op, sub, branch, branch_sel, shift_left, in1, in2, out_val);

        // Test 3: ANDB (Op 01) - Mask with LSB 1
        // 10101010 & 00000001 (LSB is 1) -> Output should be Input 1
        in1 = 8'b10101010; in2 = 8'b00000001;
        alu_op = 2'b01;
        #10;
        $display("%0t\tAND\t%b\t%b\t%b\t%b\t%b\t%h\t%h\t\t%h\t%h\tANDB (LSB=1)", 
                 $time, alu_op, sub, branch, branch_sel, shift_left, in1, in2, out_val, in1);

        // Test 4: XOR (Op 10)
        // 11110000 ^ 10101010 = 01011010 (0x5A)
        in1 = 8'b11110000; in2 = 8'b10101010;
        alu_op = 2'b10;
        #10;
        $display("%0t\tXOR\t%b\t%b\t%b\t%b\t%b\t%h\t%h\t\t%h\t5a\tBasic XOR", 
                 $time, alu_op, sub, branch, branch_sel, shift_left, in1, in2, out_val);

        // Test 5: Shift Left (shift_left = 1)
        // 3 << 2 = 12
        in1 = 8'd3; in2 = 8'd2;
        alu_op = 2'b11; shift_left = 1;
        #10;
        $display("%0t\tSHL\t%b\t%b\t%b\t%b\t%b\t%d\t%d\t\t%d\t12\tShift Left", 
                 $time, alu_op, sub, branch, branch_sel, shift_left, in1, in2, out_val);

        // Test 6: Shift Right (shift_left = 0)
        // 12 >> 2 = 3
        in1 = 8'd12; in2 = 8'd2;
        alu_op = 2'b11; shift_left = 0;
        #10;
        $display("%0t\tSHR\t%b\t%b\t%b\t%b\t%b\t%d\t%d\t\t%d\t3\tShift Right", 
                 $time, alu_op, sub, branch, branch_sel, shift_left, in1, in2, out_val);

        // Test 7: BEQ Check (branch_sel = 00 for Zero Flag) - Equal Case
        // 5 - 5 = 0. Zero flag should be 1. Output should be 1.
        in1 = 8'd5; in2 = 8'd5;
        alu_op = 2'b00; sub = 1; branch = 1; branch_sel = 2'b00;
        #10;
        $display("%0t\tBEQ\t%b\t%b\t%b\t%b\t%b\t%d\t%d\t\t%d\t1\tBranch Equal (True)", 
                 $time, alu_op, sub, branch, branch_sel, shift_left, in1, in2, out_val);

        // Test 8: BEQ Check - Not Equal Case
        // 5 - 4 = 1. Zero flag is 0. Output should be 0.
        in2 = 8'd4;
        #10;
        $display("%0t\tBEQ\t%b\t%b\t%b\t%b\t%b\t%d\t%d\t\t%d\t0\tBranch Equal (False)", 
                 $time, alu_op, sub, branch, branch_sel, shift_left, in1, in2, out_val);

        // Test 9: BLT Check (branch_sel = 01 for Sign Flag) - Negative Result
        // 10 - 20 = -10 (Negative). Sign flag is 1. Output should be 1.
        in1 = 8'd10; in2 = 8'd20;
        branch_sel = 2'b01; // Sign flag
        #10;
        $display("%0t\tBLT\t%b\t%b\t%b\t%b\t%b\t%d\t%d\t\t%d\t1\tBranch Less Than (True)", 
                 $time, alu_op, sub, branch, branch_sel, shift_left, in1, in2, out_val);

        // Test 10: BOV Check (branch_sel = 10 for Overflow)
        // 127 - (-1) = 128 (Overflow in signed 8-bit). Overflow flag is 1.
        in1 = 8'd127; in2 = 8'b11111111; // -1
        sub = 1; 
        branch_sel = 2'b10; // Overflow flag
        #10;
        $display("%0t\tBOV\t%b\t%b\t%b\t%b\t%b\t%d\t%d\t\t%d\t1\tBranch Overflow (True)", 
                 $time, alu_op, sub, branch, branch_sel, shift_left, in1, in2, out_val);

        $finish;
    end

endmodule