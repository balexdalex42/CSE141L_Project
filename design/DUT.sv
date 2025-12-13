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
			next_branch_selector,
			done_flag;     

	logic [1:0] 	alu_op,
					branch_sel,
					sel_rs;

	logic [2:0] 	rs_addr,
					rd_addr; //these are the register addresses

	logic [5:0] 	imm;

	logic [7:0] 	rs_out,
					rd_out,
					alu_out,
					mem_addr,    // data_mem address pointer
					dat_in,  // data_mem data ports
					dat_out,
					lut_out, //output of our lut
					mem_stage_out,
					wb_out; //output of alu

	logic [8:0] 	instr;

	logic [11:0] 	pc_in, // input for our PC
					pc_out,
					pc_next,
					pc_next_branch,
					instr_addr, //instr_mem address pointer 
					branch_out;

	//CONNECTING OUR MODULES

	//creating prog_ct
	assign instr_addr = pc_out;
	PC prog_ct(
		.clk(clk),
		.reset(reset),
		.start(start),
		.in(pc_in),
		.out_val(pc_out));

	logic pc_cin1;
	FA_8 PC_next1(
		.in1(pc_out[7:0]),
		.in2(8'd1),
		.cin(0),
		.sum(pc_next[7:0]),
		.overflow(pc_cin1));

	logic fake_wire2;
	FA_4 PC_next2(
		.in1(pc_out[11:8]),
		.in2(0),
		.cin(pc_cin1),
		.sum(pc_next[11:8]),
		.cout(fake_wire2)); //we don't need this output
	
	// beq rd rs PC + 1 + 1
	// if not eq (jumps)
	//if eq (jumps)
	//instantiating our instruction mem
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
		//for PC + 1 or PC + 1 + branch selector
		.next_branch_selector(next_branch_selector),
		//end of the program(s)
		.done(done_flag), 
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
		.is_sign_ext(0), 
		.out_val(rs_1b_to_full));
		
	extender #(.INPUT_WIDTH(2), .DATA_WIDTH(3)) rs_2b_ext( //for S-Type
		.in(instr[4:3]), 
		.is_sign_ext(0), 
		.out_val(rs_2b_to_full));

	mux_2  #(.DATA_WIDTH(3)) rs_sel_mux(
		.in0(instr[5:3]), //R-Type
		.in1(rs_2b_to_full), //S-Type
		.in2(rs_1b_to_full), //B-Type
		.in3(instr[5:3]), //default (not needed)
		.sel(sel_rs),
		.out_val(rs_addr));
	//rd
	logic zero_rd = 3'd0; //for I-type instr
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
	logic [8:0] imm_full;
	extender #(.INPUT_WIDTH(6)) imm_ext(
		.in(imm), 
		.is_sign_ext(1), 
		.out_val(imm_full));

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
		.is_sign_ext(1), //0 = zero_ext, 1 = sign_ext
		.out_val(branch_out));

	//making a 12-bit full adder
	logic pc_cin2;
	FA_8 PC_next_branch1(
		.in1(pc_next[7:0]),
		.in2(branch_out[7:0]),
		.cin(0),
		.sum(pc_next_branch[7:0]),
		.overflow(pc_cin2));

	logic fake_wire;
	FA_4 PC_next_branch2(
		.in1(pc_next[11:8]),
		.in2(branch_out[11:8]),
		.cin(pc_cin2),
		.sum(pc_next_branch[11:8]),
		.cout(fake_wire)); //not needed
	//now we can select whether or not we want pc + 1 OR pc + 1 + branch_out

	mux_1 #(.DATA_WIDTH(12)) next_branch(
		.in0(pc_next), 
		.in1(pc_next_branch), 
		.sel(next_branch_selector), 
		.out_val(pc_in));

	//mem stage
	//

	// instantiate data memory
	assign mem_addr = rs_out;
	assign dat_in = rd_out;
	dat_mem dm(
		.clk(clk),
		.wen(wmem_en),
		.addr(mem_addr),
		.dat_in(dat_in),
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

endmodule
										