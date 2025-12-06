module LUT_4(
    input logic [3:0] addr,
    output logic [3:0] val
);

    always_comb begin : blockName
        case(addr)
            4'b0000 : val = 4'd0;
            4'b0001 : val = 4'd1;
            4'b0010 : val = 4'd1;
            4'b0100 : val = 4'd1;
            4'b1000 : val = 4'd1;
            4'b0011 : val = 4'd2;
            4'b0101 : val = 4'd2;
            4'b1001 : val = 4'd2;
            4'b0110 : val = 4'd2;
            4'b1010 : val = 4'd2;
            4'b1100 : val = 4'd2;
            4'b0111 : val = 4'd3;
            4'b1011 : val = 4'd3;
            4'b1101 : val = 4'd3;
            4'b1110 : val = 4'd3;
            4'b1111 : val = 4'd4;
        endcase
    end
endmodule