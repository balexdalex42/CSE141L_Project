//1-to-2 mux
module mux_1 #(parameter DATA_WIDTH = 8)(
        input logic [DATA_WIDTH-1:0]    in0,
                                        in1,
        input logic   sel,

        output logic [DATA_WIDTH-1:0]   out_val
    );

    assign out_val = sel? in1 : in0;

endmodule 