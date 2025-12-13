// data memory module
module dat_mem(
	input logic 	clk,
                	wmem_en,
  	input logic [7:0] 	addr,
              			dat_in,

  	output logic [7:0] 	dat_out
	);

  	logic[7:0] core[256];

  	always_ff @(posedge clk)
      if(wmem_en) core[addr] <= dat_in;

  	assign dat_out = core[addr];

endmodule