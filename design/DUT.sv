module DUT(
    input logic 	clk,
        			reset, 
        			start,

  	output logic 	done
  	);

	//from our controller
	logic 	wmem_en,	// data_mem write enable
			wreg_en, // reg-file write en
			sub, //sub flag from control
			alu_src, 
			shift_left,
			use_lut,
			branch,
			sel_rd,
			alu_mem_sel,
			sel_pc_next,
			done_flag,
			wpc_en;     

	logic [1:0] 	alu_op,
					branch_sel,
					sel_rs;

	logic [2:0] 	rs_addr,
					rd_addr; //these are the register addresses

	logic [5:0] 	imm; //immediate value low 6 bits of instr

	logic [7:0] 	rs_out, //decode stage
					rd_out, 
					alu_out, //exec stage
					mem_stage_out, //mem stage
					wb_out; //wb stage

	logic [8:0] 	instr;

	logic [11:0] 	pc_in, // input for our PC
					pc_out,
					instr_addr, //instr_mem address pointer 
					branch_out;

	//MOST IMPORTANT OUTPUT:
	assign done = done_flag;
	//CONNECTING OUR MODULES

	//creating prog_ct
	
	PC prog_ct(
		.in(pc_in),
		.clk(clk),
		.reset(reset),
		.wpc_en(wpc_en),
		.out_val(pc_out));
	
	// beq rd rs PC + 1 + 1
	// if not eq (jumps)
	//if eq (jumps)
	//instantiating our instruction mem
	assign instr_addr = pc_out;
	instr_mem im(
		.address(instr_addr),
		.out_val(instr));

	//creating our control unit
	controller control_unit(
		//inputs
		.opcode(instr[8:6]),
		.branch_bits(instr[5:4]),
		.start(start),
		//outputs
		.wr_en(wreg_en),
		.sub(sub),
		.alu_src(alu_src), //to choose either Rs and Immediate
		//for my b and s type instructions (in exec/mem step)
		.shift_left(shift_left),
		.use_lut(use_lut),
		.mem_write(wmem_en),
		.branch(branch),
		//for i-type(), do we choose Rd or R0
		.sel_rd(sel_rd),
		//for mux that chooses mem read or alu read
		.alu_mem_sel(alu_mem_sel),
		//for PC + 1 or PC + 1 + jump amt
		.sel_pc_next(sel_pc_next),
		//end of the program(s)
		.done(done_flag), 
		//enable for program counter
		.wpc_en(wpc_en),

		//outputs
		.alu_op(alu_op),
		.branch_sel(branch_sel),
		.sel_rs(sel_rs));

	//
	//Decode Stage

	//what feeds the regfile
	//rs
	logic [2:0] rs_1b_to_full, rs_2b_to_full;
	extender #(.INPUT_WIDTH(1), .DATA_WIDTH(3)) rs_1b_ext( //For B-Type
		.in(instr[3]), 
      .is_sign_ext(1'd0), 
		.out_val(rs_1b_to_full));
		
	extender #(.INPUT_WIDTH(2), .DATA_WIDTH(3)) rs_2b_ext( //for S-Type
		.in(instr[4:3]), 
      .is_sign_ext(1'd0), 
		.out_val(rs_2b_to_full));

	mux_2  #(.DATA_WIDTH(3)) rs_sel_mux(
		.in0(instr[5:3]), //R-Type
		.in1(rs_2b_to_full), //S-Type
		.in2(rs_1b_to_full), //B-Type
		.in3(instr[5:3]), //default (not needed)
		.sel(sel_rs),
		.out_val(rs_addr));
	//rd
  	logic [2:0] zero_rd; //for I-type instr
  	assign zero_rd  = 3'd0;
	mux_1 #(.DATA_WIDTH(3)) rd_sel_mux(
		.in0(instr[2:0]), 
		.in1(zero_rd), 
		.sel(sel_rd), 
		.out_val(rd_addr));
	
	//reg-file
	reg_file regs(
		.read_addr1(rs_addr),
		.read_addr2(rd_addr),
		.write_addr(rd_addr),
		.write_val(wb_out),
		.clk(clk),
		.wr_en(wreg_en),
		.reset(reset),
		.read_val1(rs_out),
		.read_val2(rd_out)
	);

	//
	//Exec Stage
	//

	//determining input 2 of ALU 
	assign imm = instr[5:0]; //our 6-bit immediate, we need to choose to add to Rd with Rs or imm
	logic [7:0] imm_full; //we want our imm to be an 8-bit sign-ext val
	extender #(.INPUT_WIDTH(6)) imm_ext(
		.in(imm), 
      	.is_sign_ext(1'd1), 
		.out_val(imm_full));

	logic [7:0] alu_src_out; //will be the output of the alu_src mux (we need to choose Rs or sign-ext imm)
	mux_1 alu_src_mux(
		.in0(rs_out),
		.in1(imm_full), 
		.sel(alu_src), 
		.out_val(alu_src_out));

	ALU alu(
		.in1(rd_out),
		.in2(alu_src_out),
		.alu_op(alu_op),
		.branch_sel(branch_sel),
		.sub(sub),
		.branch(branch),
		.shift_left(shift_left),
		//output
		.out_val(alu_out)
	);

	//branching logic; when we branch we take our output from ALU and extend it, and either choose that or our OG PC
	extender #(.INPUT_WIDTH(8), .DATA_WIDTH(12)) alu_sign_extender12(
		.in(alu_out),
      	.is_sign_ext(1'd1), //0 = zero_ext, 1 = sign_ext
		.out_val(branch_out));

	//mem stage
	//

	// instantiate data memory
	logic [7:0] 	mem_addr,    // data_mem address pointer
					dat_in,  // data_mem data ports
					dat_out,
					lut_out; //output of our lut

	assign mem_addr = rs_out;
	assign dat_in = rd_out;

	dat_mem dm(
		.clk(clk),
		.wmem_en(wmem_en),
		.addr(mem_addr),
		.dat_in(dat_in), //for store operation (Rd's val)
		.dat_out(dat_out));

	//our LUTS for program 1

	LUT_4 upper_lut(
		.addr(mem_addr[7:4]),
		.out_val(lut_out[7:4]));

	LUT_4 lower_lut(
		.addr(mem_addr[3:0]),
		.out_val(lut_out[3:0]));

	//now we need to select our memory read signal (from lut (1) or mem(0))
	mux_1 mem_stage_mux(
		.in0(dat_out), 
		.in1(lut_out), 
		.sel(use_lut), 
		.out_val(mem_stage_out));

	//
	//writeback stage
	//

	mux_1 wb_mux(
		.in0(alu_out), //from alu
		.in1(mem_stage_out), //from mem
		.sel(alu_mem_sel), //refer to controller: alu_mem_sel, choose alu output (0) or mem read (1)
		.out_val(wb_out));
	//

	//
	//NEXT PC LOGIC
	//

	logic [11:0] pc_next;
	logic pc_next_cin, unused_wire;

	//12-bit FA to calc PC_next = PC + 1
	FA_4 PC_next_calc_low( //calculates low 4 bits
		.in1(pc_out[3:0]),
      	.in2(4'd1),
		.cin(1'd0),
		.sum(pc_next[3:0]),
		.cout(pc_next_cin)); 

	FA_8 PC_next_calc_high( //calcs high 8 bits
		.in1(pc_out[11:4]),
		.in2(8'd0),
      	.cin(pc_next_cin),
		.sum(pc_next[11:4]),
		.overflow(unused_wire));//we don't need this output

	//calculate new PC with branch/jump:  PC w/ jump = PC+1+jamt
	logic [11:0] pc_with_jbr;
	logic pc_with_jbr_cin, unused_wire2;

	FA_4 PC_jbr_calc_low( //note branch_out is a 12-bit sign-ext value
		.in1(pc_next[3:0]),
		.in2(branch_out[3:0]),
      	.cin(1'd0),
		.sum(pc_with_jbr[3:0]),
		.cout(pc_with_jbr_cin));

	FA_8 PC_jbr_calc_high(
		.in1(pc_next[11:4]),
		.in2(branch_out[11:4]),
		.cin(pc_with_jbr_cin),
		.sum(pc_with_jbr[11:4]),
		.overflow(unused_wire2)); //not needed

	//now we can select whether or not we want pc + 1 OR pc + 1 + branch_out

	mux_1 #(.DATA_WIDTH(12)) next_branch(
		.in0(pc_next), 
		.in1(pc_with_jbr), 
		.sel(sel_pc_next), 
		.out_val(pc_in));

endmodule