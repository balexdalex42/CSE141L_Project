module Shifter(
        input logic[7:0]    in1,
                            in2,
        input logic left,

        output logic[7:0] out_val
    );

    //get the shift amount
    logic [2:0] shamt;

    assign shamt = in2[2:0];
    assign out_val = left? (in1 << shamt) : (in1 >> shamt);
    
endmodule