// program 2    CSE141L   product C = OpA * OpB  
// operands are 8-bit two's comp integers, product is 16-bit two's comp integer
// revised 2025.11.12 to resolve big/little endian question -- now conforms to the assignment writeup
//   revision also adds reset port and connection to the DUT, again to conform to the assignment writeup
module test_bench;

// connections to DUT: clk (clock), reset, start (request), done (acknowledge) 
  bit  clk,
       reset = 'b1,				 // should set your PC = 0
       start = 'b1;				 // falling edge should initiate the program
  wire done;					 // you return 1 when finished

  logic signed[ 7:0] OpA, OpB;
  logic signed[15:0] Prod;	    // holds 2-byte product		  

  DUT D1(.clk  (clk  ),	        // your design goes here
         .reset(reset),
		 .start(start),
		 .done (done )); 

  always begin
    #50ns clk = 'b1;
	#50ns clk = 'b0;
  end

  initial begin				   // todo: wrap this in one big FOR loop
    #100ns;
    OpA =  2;		           // generate operands
    OpB = -4;				   // for now, try out different values 
    D1.dm.core[0] = OpA;
    D1.dm.core[1] = OpB;	   // load values into mem, copy to Tmp array
    #10ns   $display("%d, %d",OpA, OpB);
// 	compute correct answers
    #10ns  Prod = OpA * OpB;		      // compute prod.
    #10ns  reset = 'b0;
	#10ns start = 'b0; 							  
    #200ns wait (done);						          // avoid false done signals on startup
    if({D1.dm.core[3],D1.dm.core[2]} == Prod)
	    $display("Yes! %d * %d = %d",OpA,OpB,Prod);
	  else
	    $display("Boo! %d * %d should = %d",OpA,OpB,Prod);    
    #20ns start = 'b1;
	#10ns reset = 'b1; 
	$stop;
  end


endmodule