`include "mux_1.sv"
//input width obviously cannot be more than 8
module extender #(parameter INPUT_WIDTH = 1, parameter DATA_WIDTH = 8)(
        input logic [INPUT_WIDTH-1:0]   in,
        input logic     is_sign_ext,

        output logic [DATA_WIDTH-1:0]    out_val
    );

    logic [DATA_WIDTH-1:0] zero_ext, sign_ext;
    logic sign_bit;

    assign sign_bit = in[INPUT_WIDTH-1];

    assign zero_ext = {(DATA_WIDTH-INPUT_WIDTH){0}, in};
    assign sign_ext = {(DATA_WIDTH-INPUT_WIDTH){sign_bit}, in};
    mux_1 #(.DATA_WIDTH(DATA_WIDTH)) extend_selector(.in0(zero_ext), .in1(sign_ext), .sel(is_sign_ext), .out_val(out_val));
    
endmodule


