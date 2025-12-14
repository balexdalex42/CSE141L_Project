# CSE141L_Project (David Hong and Alexander Tatoian)
## Running the Program in EDAPlayground
Here is a [link to our EDA playground](https://www.edaplayground.com/x/hNGj) for ease of use (please put testbenches you want to use there):   
https://www.edaplayground.com/x/hNGj  

In something like EDAPlayground, add all the files in the `design` directory and import them to the design (right-hand side of the IDE). Next, put this into design.sv:
```
`include "ALU.sv"
`include "controller.sv"
`include "dat_mem.sv"
`include "DUT.sv"
`include "extender.sv"
`include "FA_1.sv"
`include "FA_4.sv"
`include "FA_8.sv"
`include "instr_mem.sv"
`include "LUT_4.sv"
`include "mux_1.sv"
`include "mux_2.sv"
`include "PC.sv"
`include "reg_file.sv"
`include "shifter.sv"
```
Next, upload your testbenches onto the lefthand side of the IDE. And similarly put this into the testbench.sv:  
```
// `include "test_bench_hamming.sv"
//`include "test_bench_prod2.sv"
// `include "test_bench_prod3.sv"
```   
Make sure to just uncomment whichever testbench you would like to run. Please use the Siemmens Questa simulator.
Also inside of each test_bench make sure to add:
```
$readmemb("prog2_mcode.txt", D1.im.instr_core);
```
Make sure to use the correct machine code (given in the `machine_code` directory).   
NOTE: `DUT.sv` is the top level module that is our processor.   

We were able to get a functional assembler as well (`assembler.py`). You will not need the assembler because we already give the machine code for each program in the `machine_code` repository...

## Results
We were able to get program 1 fully functional. We believe we were very close to completing program 2 and 3, but think there are small logic errors in our assembly code for them which produces an incorrect output. Overall, the hardware works as expected and there are testbenches and other small assembly files that we used to test the branching, jumping, and looping, as well as our other R-type, S-type, and ADDI functions. What ended up being the biggest struggle in this entire project, was to come up with a solid ISA, which we couldn't really finish until the end of week 7. This is because without the ISA, you can't program your most important thing, which is the controller (maybe second to the entire DUT). We think that the definite second biggest challenge was the assembly writing, where we had around 100 lines of assembly per program, each of which is very confusing and hard to debug. We faced a really big problem which ended up being very silly: our programs would not end even though our **done** signal was handled by the controller correctly. It ended up being that the done flag was never connected to the DUT!