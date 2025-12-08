`timescale 1ns/1ps

module tb_reg_file;
    // Signals
  	logic [2:0] read_addr1, read_addr2, write_addr;
    logic [7:0] write_val;
    logic clk, wr_en;
    logic [7:0] read_val1, read_val2;

    // Instantiate the register file
    reg_file dut (
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_val(write_val),
        .clk(clk),
        .wr_en(wr_en),
        .read_val1(read_val1),
        .read_val2(read_val2)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Test procedure
    initial begin
      $dumpfile("dump.vcd"); 
      $dumpvars;
        // Initialize
        wr_en = 0;
        write_addr = 0;
        write_val = 0;
        read_addr1 = 0;
        read_addr2 = 1;

        $display("Time\twr_en\twrite_addr\twrite_val\tread_val1\tread_val2");

        // Wait a bit
        #2;
        $display("%0t\t%b\t%d\t\t%d\t\t%d\t\t%d", 
                  $time, wr_en, write_addr, write_val, read_val1, read_val2);

        // Test 1: write 42 to register 3
        write_addr = 3;
        write_val = 8'd42;
        wr_en = 1;
        #10; // wait one clock cycle

        // Check read
        read_addr1 = 3;
        read_addr2 = 0;
        #1; // small delay for combinational read
        $display("%0t\t%b\t%d\t\t%d\t\t%d\t\t%d", 
                  $time, wr_en, write_addr, write_val, read_val1, read_val2);

        // Test 2: disable write and try writing 99 to reg 5
        wr_en = 1;
        write_addr = 3;
        write_val = 8'd99;
        #10; // next clock

        read_addr1 = 5;
        read_addr2 = 3;
        #1;
        $display("%0t\t%b\t%d\t\t%d\t\t%d\t\t%d", 
                  $time, wr_en, write_addr, write_val, read_val1, read_val2);

        // Test 3: write 100 to reg 5 with wr_en=1
        wr_en = 1;
        #10; // next clock

        #1; // allow combinational read
        $display("%0t\t%b\t%d\t\t%d\t\t%d\t\t%d", 
                  $time, wr_en, write_addr, write_val, read_val1, read_val2);

        $finish;
    end
	
endmodule
