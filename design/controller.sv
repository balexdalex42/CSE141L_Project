module controller(
        input logic [2:0]   opcode,
        input logic [1:0]   branch_bits,

        output logic    wr_en,
                        // carry_in,
                        sub,
                        alu_src,
                        //for my b and s type instructions (in exec/mem step)
                        shift_left,
                        branch_eq,
                        use_dm,
                        mem_read,
                        //for i-type
                        sel_rs,
                        //these last two are for the start and end of the program(s)
                        start,
                        done,            
        output logic [1:0]  alu_op,
                            sel_rd //also for b and s type, but in decode step


    );

    //always comb
endmodule