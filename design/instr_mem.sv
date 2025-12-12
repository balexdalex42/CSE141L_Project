//programs instruction memory
module instr_mem(
        input logic [11:0]  address,

        output logic [8:0] out_val
    );

    logic [8:0] instr_core[4095:0];

    assign out_val =  instr_core[address];

endmodule