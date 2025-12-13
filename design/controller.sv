module controller(
        input logic [2:0]   opcode,
        input logic [1:0]   branch_bits,
        input logic     start, //for starting logic
        //our control signals
        output logic    wr_en, //for reg
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
                        //for choosing next PC val
                        sel_pc_next,
                        //end of the program(s)
                        done,
                        //enable for program counter
                        wpc_en, 

        output logic [1:0]  alu_op,
                            branch_sel,
                            sel_rs //for B, S, and I instructions

    );

    //wr_en (for register write enabling)
    logic wr_en_init; //before we consider done and start flags
    always_comb begin
        case(opcode) //we don't want to write when doing a jump, branch, store, or done
            //jump and branching
            3'b010,
            3'b001: wr_en_init = 0;
            //sbmem or done
            3'b011:
                wr_en_init = ~branch_bits[1]; //if 0x -> loadmem or loadlut
            default:
                wr_en_init = 1; //if anything else (R-Type, S-Type, ADDI: wr_en = 1)
        endcase
        wr_en = wr_en_init & ~start & ~done;
    end

    //sub (for comparison in ALU)
    assign sub = (opcode == 3'b010) & ~(branch_bits[1]); //if branch bits is 2'b0x then we know it's beq or blt

    //alu_src (for alu_src_mux): choose Rs (0), choose Immediate (1) (this feeds into in_2 of ALU)
    assign alu_src = (opcode[2:1] == 2'b00); //I-Types are 00X

    //shift_left for our shifter in ALU
    assign shift_left = branch_bits[1];

    //use_lut, will determine whether to read from memory(0) or lut (1)
    assign use_lut = branch_bits[0]; //using LUT=01 , 11 case doesn't matter because it isn't a mem access!

    //mem_write, only for the store byte instrution
    assign mem_write = (opcode == 3'b011) & (branch_bits == 2'b10) & ~start & ~done; //don't write to mem

    //for whether or not it's a branch instruction
    assign branch = (opcode == 3'b010);

    //select rd (as well as reg write), select whether we want to write into Rd (0) or R0 (1) (for ADDI)
    assign sel_rd = (opcode[2:1] == 2'b00);

    //alu_mem_sel, choose alu output (0) or mem read (1)
    assign alu_mem_sel = (opcode == 3'b011) & (~branch_bits[1]); //seeing if opcode is mem op and  if lbmem or lblut instr (have 0x)

    //sel_pc_next PC + 1 (0) or PC + 1 + branch_out (1)
    assign sel_pc_next = branch | (opcode == 3'b001); //if jump instr or branch

    //done
    assign done = (opcode == 3'b011) & (branch_bits == 2'b11); //this terminates the program

    //wpc_en (make sure we aren't in the start state or the done start)
    assign wpc_en = ~(start | done);
    //alu_op (please refer to ALU.sv for the use of these control bits)

    always_comb begin
        case(opcode)
            3'b000,
            3'b001,
            3'b010,
            3'b011,
            3'b111: alu_op = 2'b00; //all adds where branches, mem accesses, addi, jump, add use the add function
            
            3'b110: alu_op = 2'b01; //andb
            
            3'b101: alu_op = 2'b10; //xor

            3'b100: alu_op = 2'b11; //shift

            default: alu_op = 2'b00; //will not happen
        endcase
    end

    //branch_sel, choosing which flag we should care about in our branch (eq (00), lt(01), overflow(10))
    assign branch_sel = branch_bits;

    //sel_rs logic; sel_rs will determine how many of the bits of [5:3] we want to use in our instruction
    always_comb begin
        //R/S Type classifier (R: 111, 110, 101) (S:100)
        if(opcode[2]) begin
            if(opcode[1] | opcode[0]) //R-type
                sel_rs = 2'b00;
            else                        //S-type
                sel_rs = 2'b01; //we want to rs to be zero ext instr[4:3]
        end else begin
            if(opcode[1]) //B Type (011, 010)
                sel_rs = 2'b10; //we want RS to be zero ext instr[3]
            else
                sel_rs = 2'b11; //since I-types don't use RS, this isn't important
        end
    end

    
endmodule