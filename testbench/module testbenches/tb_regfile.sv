`timescale 1ns/1ps

module tb_reg_file;
    // Signals
  	logic [2:0] read_addr1, read_addr2, write_addr;
    logic [7:0] write_val;
    logic clk, wr_en, reset;
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

        // Test 4: Asynchronous Reset Test
        // We currently have data in R3 (99) and R5 (100).
        // We will pull reset HIGH and expect them to become 0 immediately.
        #5;
        reset = 1;
        wr_en = 0; // Turn off write during reset
        #5; // Wait a bit (still inside a clock cycle or across edges)
        
        // Check R3 and R5
        read_addr1 = 3;
        read_addr2 = 5;
        #1;
        $display("%0t\t%b\t%d\t\t%d\t\t%d\t\t%d\tTest 4: Reset High (expect 0s)", 
                  $time, wr_en, write_addr, write_val, read_val1, read_val2);
        
        // Release reset
        reset = 0;
        #5;

        // Test 5: Write All Registers (Loop)
        // Write value (i + 10) to Register[i]
        $display("\n--- Starting Full Bank Write Loop ---");
        wr_en = 1;
        for (i = 0; i < 8; i = i + 1) begin
            write_addr = i;
            write_val = i + 10;
            @(posedge clk); // Wait for clock edge to write
        end
        wr_en = 0; // Disable write

        // Test 6: Read All Registers (Loop)
        // Verify every register holds the correct unique value
        $display("--- Starting Full Bank Read Loop ---");
        for (i = 0; i < 8; i = i + 1) begin
            read_addr1 = i;
            #1; // Wait for combinational logic
            if (read_val1 !== (i + 10)) 
                $display("ERROR at Reg[%0d]: Expected %0d, Got %0d", i, i+10, read_val1);
            else
                $display("Reg[%0d] OK: %0d", i, read_val1);
        end

        // Test 7: Zero Register Check (if R0 is hardwired, which it isn't in your code, but common in MIPS)
        // In your code, R0 is a normal register. Let's verify we can write max value 255 to it.
        wr_en = 1;
        write_addr = 0;
        write_val = 8'hFF;
        @(posedge clk);
        wr_en = 0;
        read_addr1 = 0;
        #1;
        $display("%0t\t%b\t%d\t\t%d\t\t%d\t\t%d\tTest 7: R0 Max Value (expect 255)", 
                  $time, wr_en, write_addr, write_val, read_val1, read_val2);

        $display("\nAll tests completed.");
        $finish;
    end
	
endmodule
