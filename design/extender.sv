`include "mux_1.sv"
//input width obviously cannot be more than 8
module extender #(parameter INPUT_WIDTH = 1)(
        input logic [INPUT_WIDTH-1:0]   in,
        input logic     is_sign_ext,
        
        output logic [7:0]    out_val
    );

    logic [7:0] zero_ext, sign_ext;
    logic sign_bit;

    assign sign_bit = in[INPUT_WIDTH-1];

    assign zero_ext = {(8-INPUT_WIDTH){0}, in};
    assign sign_ext = {(8-INPUT_WIDTH){sign_bit}, in};
    mux_1 #(.DATA_WIDTH(8)) extend_selector(.in0(zero_ext), .in1(sign_ext), .sel(is_sign_ext), .out_val(out_val));

endmodule


