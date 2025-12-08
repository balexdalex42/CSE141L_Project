//1-bit full adder; used to build our 8-bit full adder
module FA_1(
    input logic     in1,
                    in2,
                    cin,

    output logic    sum,
    output logic    cout
    );

    assign sum = in1 ^ in2 ^ cin;
    assign cout = (in1 & in2) | (in1 & cin) | (in2 & cin);
endmodule