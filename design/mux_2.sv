//2-to-4 mux
module mux_2 #(parameter DATA_WIDTH = 8)(
        input logic [DATA_WIDTH-1:0]    in0,
                                        in1,
                                        in2,
                                        in3,
        input logic [1:0]   sel,

        output logic [DATA_WIDTH-1:0]   out_val
    );
    
    logic [DATA_WIDTH-1:0] out0, out1;
    //level 1
    mux_1 #(.DATA_WIDTH(DATA_WIDTH)) mux0(.in0(in0), .in1(in1), .sel(sel[0]), .out_val(out0));
    mux_1 #(.DATA_WIDTH(DATA_WIDTH)) mux1(.in0(in2), .in1(in3), .sel(sel[0]), .out_val(out1));
    //level 2
    mux_1 #(.DATA_WIDTH(DATA_WIDTH)) mux2(.in0(out0), .in1(out1), .sel(sel[1]), .out_val(out_val));

endmodule 