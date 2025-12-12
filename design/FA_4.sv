//our 8-bit full adder for our ALU
module FA_4(
    input logic[3:0]    in1,
                        in2,
    input logic     cin,

    output logic[3:0]   sum,
    output logic    cout
    );
    //internal wires for the adder
    logic cin1, cin2, cin3;
    //ripple carry adder
    FA_1 fa0(.in1(in1[0]), .in2(in2[0]), .cin(cin), .sum(sum[0]), .cout(cin1));
    FA_1 fa1(.in1(in1[1]), .in2(in2[1]), .cin(cin1), .sum(sum[1]), .cout(cin2));
    FA_1 fa2(.in1(in1[2]), .in2(in2[2]), .cin(cin2), .sum(sum[2]), .cout(cin3));
    FA_1 fa3(.in1(in1[3]), .in2(in2[3]), .cin(cin3), .sum(sum[3]), .cout(cout));

endmodule