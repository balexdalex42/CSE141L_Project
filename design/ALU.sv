`include "FA_8.sv"
`include "shifter.sv"
`include "mux_1.sv"
`include "mux_2.sv"
`include "extender.sv"
module ALU(
        input logic [7:0]   in1, in2,
        input logic [1:0]   alu_op,
                            branch_sel,

        input logic     sub,
                        branch,
                        shift_left,


        output logic [7:0]    out_val
    );

    //our internal ALU outputs
    logic [7:0] branch_out, fa_out, add_out, add_in2, andb_out, xor_out, shift_out;
    //our flags
    logic overflow, zero, sign, left, selected_flag;

    //output section via our mux
    // always_comb begin
    //     case(alu_op)
    //         2'b00: out_val = add_out;
    //         2'b01: out_val = andb_out;
    //         2'b10: out_val = xor_out;
    //         2'b11: out_val = shift_out;
    //     endcase
    // end
    
    mux2 alu_op_mux(.in0(add_out), .in1(andb_out), .in2(xor_out), .in3(shift_out), .sel(alu_op), .out_val(out_val));


    //add section
    assign add_in2 = sub? ~in2 : in2;
    FA_8 adder(.in1(in1), .in2(add_in2), .cin(sub), .sum(fa_out), .overflow(overflow));
    //determine other flags as well
    always_comb begin
        zero = (fa_out == 8'd0);
        sign = fa_out[7];
    end
    //select flag based on control bits
    mux2 #(.DATA_WIDTH(1)) flag_selector(.in0(zero), .in1(sign), .in2(overflow), .in3(zero), .sel(branch_sel), .out_val(selected_flag));
    //zero extend them
    extender #(.INPUT_WIDTH(1)) zero_ext(.in(selected_flag), .is_sign_ext(0), .out_val(branch_out));
    //now we choose either branch_out or fa_out
    mux1 add_selector(.in0(fa_out), .in1(branch_out), .sel(branch), .out_val(add_out));
    //andb section
    assign andb_out = in1 & {8{in2[0]}};

    //xor section
    assign xor_out = in1 ^ in2;

    //shift left/right
    Shifter shifter(.in1(in1), .in2(in2), .left(shift_left), .out_val(shift_out));
endmodule