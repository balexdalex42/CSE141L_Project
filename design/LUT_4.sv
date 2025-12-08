module LUT_4(
    input logic [3:0]   addr,
    output logic [3:0]  val
    );

    always_comb begin : blockName
        case(addr)
            //hamming dist 0
            4'b0000 : val = 4'd0;
            //hamming dist 1
            4'b0001,
            4'b0010,
            4'b0100
            4'b1000 : val = 4'd1;
            //hamming dist 2
            4'b0011,
            4'b0101,
            4'b1001,
            4'b0110,
            4'b1010,
            4'b1100 : val = 4'd2;
            //hamming dist 3
            4'b0111,
            4'b1011,
            4'b1101,
            4'b1110 : val = 4'd3;
            //hamming dist 4
            4'b1111 : val = 4'd4;
        endcase
    end
endmodule