//effectively a 12-bit register
module PC(
        input logic [11:0]  in,
        input logic     clk,
                        reset,
                        start,
        //TBD
        output logic [11:0] out_val
    );

    logic [11:0] pc_reg; 
    
    assign out_val = pc_reg;

    always_ff @(posedge clk || posedge reset) begin
        if(reset) begin
            pc_reg <= 12'd0;
        end else begin
            if(!start)
                pc_reg <= in;
        end
    end

endmodule