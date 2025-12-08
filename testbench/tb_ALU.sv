`timescale 1ns/1ps

module tb_alu;
    // Signals
    logic [7:0] in1, in2;
    logic [1:0] alu_op;
    logic       sub;
    logic [7:0] out_val;

    // Instantiate the ALU
    ALU dut (
        .in1(in1),
        .in2(in2),
        .alu_op(alu_op),
        .sub(sub),
        .out_val(out_val)
    );

    // Test procedure
    initial begin
        $dumpfile("alu_dump.vcd"); 
        $dumpvars;

        // Initialize
        in1 = 0;
        in2 = 0;
        alu_op = 0;
        sub = 0;

        $display("Time\tOp\tSub\tIn1\tIn2\t\tOut_Val\tExpected\tDescription");
        $display("-------------------------------------------------------------------------------------");

        // Test 1: Addition (Op 00, Sub 0)
        // 10 + 15 = 25
        in1 = 8'd10;
        in2 = 8'd15;
        alu_op = 2'b00;
        sub = 0;
        #10;
        $display("%0t\tADD\t%b\t%d\t%d\t\t%d\t25\t\tBasic Addition", 
                 $time, alu_op, sub, in1, in2, out_val);

        // Test 2: Subtraction (Op 00, Sub 1)
        // 20 - 5 = 15
        in1 = 8'd20;
        in2 = 8'd5;
        alu_op = 2'b00;
        sub = 1;
        #10;
        $display("%0t\tADD\t%b\t%d\t%d\t\t%d\t15\t\tBasic Subtraction", 
                 $time, alu_op, sub, in1, in2, out_val);

        // Test 3: ANDB (Op 01) - Mask with LSB 1
        // in1 & {8{in2[0]}} -> 10101010 & 11111111 = 10101010
        in1 = 8'b10101010;
        in2 = 8'b00000001; // LSB is 1
        alu_op = 2'b01;
        sub = 0; 
        #10;
        $display("%0t\tANDB\t%b\t%h\t%h\t\t%h\t%h\t\tPass Value (in2[0]=1)", 
                 $time, alu_op, sub, in1, in2, out_val, in1);

        // Test 4: ANDB (Op 01) - Mask with LSB 0
        // in1 & {8{in2[0]}} -> 10101010 & 00000000 = 0
        in1 = 8'b10101010;
        in2 = 8'b11111110; // LSB is 0
        alu_op = 2'b01;
        #10;
        $display("%0t\tANDB\t%b\t%h\t%h\t\t%h\t00\t\tZero Value (in2[0]=0)", 
                 $time, alu_op, sub, in1, in2, out_val);

        // Test 5: XOR (Op 10)
        // 11110000 ^ 10101010 = 01011010 (0x5A)
        in1 = 8'b11110000;
        in2 = 8'b10101010;
        alu_op = 2'b10;
        #10;
        $display("%0t\tXOR\t%b\t%b\t%b\t%h\t5a\t\tBitwise XOR", 
                 $time, alu_op, sub, in1, in2, out_val);

        // Test 6: Shift (Op 11) 
        in1 = 8'b00000011; // 3
        in2 = 8'd2;        // Shift amount 2
        alu_op = 2'b11;
        sub = 0;           
        #10;
        $display("%0t\tSHFT\t%b\t%d\t%d\t\t%d\t12\t\tCheck Shift Left (3<<2)", 
                 $time, alu_op, sub, in1, in2, out_val);

        // Test 7: Shift Other Way (Op 11, Sub 1)
        in1 = 8'b00001100; // 12
        in2 = 8'd2;        // Shift amount 2
        alu_op = 2'b11;
        sub = 1;           
        #10;
        $display("%0t\tSHFT\t%b\t%d\t%d\t\t%d\t3\t\tCheck Shift Right (12>>2)", 
                 $time, alu_op, sub, in1, in2, out_val);

        $finish;
    end

endmodule