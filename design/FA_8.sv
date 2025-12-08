`include "FA_4.sv"
//our 8-bit full adder for our ALU
module FA_8(
    input logic[7:0]    in1,
                        in2,
    input logic     cin,

    output logic[7:0]   sum,
    output logic    overflow
    );
    //internal wires for the adder
    logic cin1;
    //ripple carry adder
    FA_4 fa0(.in1(in1[3:0]), .in2(in2[3:0]), .cin(cin), .sum(sum[3:0]), .cout(cin1));
    FA_4 fa1(.in1(in1[7:4]), .in2(in2[7:4]), .cin(cin1), .sum(sum[7:4]), .cout(overflow));


endmodule