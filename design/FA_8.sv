`include "FA_1.sv"
//our 8-bit full adder for our ALU
module FA_8(
    input logic[7:0]    in1,
                        in2,
    input logic     cin,

    output logic[7:0]   sum,
    output logic    overflow
    );
    //internal wires for the adder
    logic cin1, cin2, cin3, cin4, cin5, cin6, cin7;
    //ripple carry adder
    FA_1 fa0(.in1(in1[0]), .in2(in2[0]), .cin(cin), .sum(sum[0]), .cout(cin1));
    FA_1 fa1(.in1(in1[1]), .in2(in2[1]), .cin(cin1), .sum(sum[1]), .cout(cin2));
    FA_1 fa2(.in1(in1[2]), .in2(in2[2]), .cin(cin2), .sum(sum[2]), .cout(cin3));
    FA_1 fa3(.in1(in1[3]), .in2(in2[3]), .cin(cin3), .sum(sum[3]), .cout(cin4));
    FA_1 fa4(.in1(in1[4]), .in2(in2[4]), .cin(cin4), .sum(sum[4]), .cout(cin5));
    FA_1 fa5(.in1(in1[5]), .in2(in2[5]), .cin(cin5), .sum(sum[5]), .cout(cin6));
    FA_1 fa6(.in1(in1[6]), .in2(in2[6]), .cin(cin6), .sum(sum[6]), .cout(cin7));
    FA_1 fa7(.in1(in1[7]), .in2(in2[7]), .cin(cin7), .sum(sum[7]), .cout(overflow));


endmodule