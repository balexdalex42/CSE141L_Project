`include "FA_8.sv"
`include "Shifter.sv"

module ALU(
        input logic [7:0]   in1, in2,
        input logic [1:0]   alu_op,
        input logic     sub,

        output logic [7:0]    out_val
    );

    //our internal ALU outputs
    logic [7:0] add_out, add_in2, andb_out, xor_out, shift_out;
    //our flags
    logic overflow, zero, sign, left;

    //output section
    always_comb begin
        case(alu_op)
            2'b00: out_val = add_out;
            2'b01: out_val = andb_out;
            2'b10: out_val = xor_out;
            2'b11: out_val = shift_out;
        endcase
    end


    //add section
    assign add_in2 = sub? ~in2 : in2;
    FA_8 adder(.in1(in1), .in2(add_in2), .cin(sub), .sum(add_out), .overflow(overflow));
    always_comb begin
        zero = (add_out == 8'd0);
        sign = add_out[7];
    end
    //andb section
    assign andb_out = in1 & {8{in2[0]}};

    //xor section
    assign xor_out = in1 ^ in2;

    //shift left/right
    Shifter shifter(.in1(in1), .in2(in2), .left(left), .out_val(shift_out))
endmodule