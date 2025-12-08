module reg_file(
    //our read and write addresses
    input logic [2:0]   read_addr1,
                        read_addr2, 
                        write_addr,
    input logic [7:0]   write_val,
    //clk and write enable
    input logic     clk,
                    wr_en,
                    reset,
    //vals we read          
    output logic [7:0]  read_val1,
                        read_val2
    );

    //defining that we have a 8 8-bit registers
    logic [7:0] regs [0:7]; 

    assign read_val1 = regs[read_addr1];
    assign read_val2 = regs[read_addr2];

    always_ff @(posedge clk || posedge reset) begin
        //reset logic
        if(reset) begin
            regs[0] <= 8'd0;
            regs[1] <= 8'd0;
            regs[2] <= 8'd0;
            regs[3] <= 8'd0;
            regs[4] <= 8'd0;
            regs[5] <= 8'd0;
            regs[6] <= 8'd0;
            regs[7] <= 8'd0;
        end else begin
            if (wr_en) begin
                regs[write_addr] <= write_val;
            end
        end
    end

endmodule