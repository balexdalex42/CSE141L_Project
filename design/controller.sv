module controller(
        input logic [2:0]   opcode,
        input logic [1:0]   branch_bits,
        //our control signals
        output logic    wr_en,
                        sub,
                        alu_src, //to choose either Rs and Immediate
                        //for my b and s type instructions (in exec/mem step)
                        shift_left,
                        use_lut,
                        mem_write,
                        branch,
                        //for i-type, do we choose Rd or R0
                        sel_rd,
                        //for mux that chooses mem read or alu read
                        alu_mem_sel,
                        //these last two are for the start and end of the program(s)
                        start,
                        done,            
        output logic [1:0]  alu_op,
                            branch_sel,
                            sel_rs //for B, S, and I instructions



    );

    //wr_en (for registers)
    assign wr_en = opcode[2] || (~|opcode[1:0]);

    //sub (for comparison in ALU)
    assign sub = (opcode == 3'b010) && ~(branch_bits[1]); //if branch bits is 2'b0x then we know it's beq or blt

    //alu_src (if 0 then we will choose Rd, if not we will choose Immediate)
    assign alu_src = (opcode[2:1] == 2'b00);

    //shift_left for our shifter in ALU
    assign shift_left = branch_bits[1];

    //use_lut, will determine whether to read from memory(0) or lut (1)
    assign use_lut = branch_bits[0];

    //mem_write, only for the store byte instrution
    assign mem_write = (opcode == 3'b011) && (branch_bits == 2'b10);

    //for whether or not it's a branch instruction
    assign branch = (opcode == 3'b010);

    //select rd (as well as reg write), select whether we want to write into Rd or R0 (for ADDI)
    assign sel_rd = (opcode[2:1] == 2'b00);

    //alu_mem_sel, choose alu output (0) or mem read (1)
    assign alu_mem_sel = (opcode == 3'b011) && (~branch_bits[1]); //seeing if opcode is mem op and branchbit[1] is 0 

    //start
    assign start = (opcode == 3'b010) && (&branch_bits);

    //done
    assign done = (opcode == 3'b011) && (&branch_bits);

    //alu_op (please refer to ALU.sv for the use of these control bits)

    always_comb begin
        case(opcode)
            3'b000,
            3'b001,
            3'b010,
            3'b011,
            3'b111: alu_op = 2'b00; //all adds where branches, mem accesses, addi, jump, add use the add function
            
            3'b101: alu_op = 2'b01; //andb

            3'b110: alu_op = 2'b10; //xor

            3'b100: alu_op = 2'b11; //shift
        endcase
    end

    //branch_sel, choosing which flag we should care about in our branch (eq, lt, overflow)
    assign branch_sel = branch_bits;
    //sel_rs logic; sel_rs will determine how many of the bits of [5:3] we want to use in our instruction
    always_comb begin
        //R/S Type classifier (R: 111, 110, 101) (S:100)
        if(opcode[2]) begin
            if(opcode[1] | opcode[0])
                sel_rs = 2'b00;
            else
                sel_rs = 2'b01;
        end else begin
            if(opcode[1]) //B Type (011, 010)
                sel_rs = 2'b10;
            else
                sel_rs = 2'b11; //this case doesn't really matter
        end
    end

    
endmodule