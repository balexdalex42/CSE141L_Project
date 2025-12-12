import sys
import re

# SEKI ARCHITECTURE ASSEMBLER

def parse_register(reg_str, bit_width):
    """Parses a register string (e.g., '$3', 'R3', '3') and returns its integer value."""
    clean_reg = reg_str.upper().replace('$', '').replace('R', '').replace(',', '')
    
    try:
        val = int(clean_reg)
    except ValueError:
        raise ValueError(f"Invalid register format: {reg_str}")

    # specific constraints from ISA
    max_val = (1 << bit_width) - 1
    if val > max_val:
        raise ValueError(f"Register {reg_str} exceeds allowed {bit_width}-bit width (Max R{max_val}).")
    
    return val

def parse_immediate(imm_str, bit_width):
    """Parses immediate values (0d, 0x, 0b, or plain) and returns binary string."""
    clean_imm = imm_str.replace(',', '').lower()
    
    try:
        if clean_imm.startswith('0x'):
            val = int(clean_imm, 16)
        elif clean_imm.startswith('0b'):
            val = int(clean_imm, 2)
        elif clean_imm.startswith('0d'):
            val = int(clean_imm[2:])
        else:
            val = int(clean_imm)
    except ValueError:
        raise ValueError(f"Invalid immediate format: {imm_str}")

    # Check bounds for signed immediate (2's complement)
    min_val = -(1 << (bit_width - 1))
    max_val = (1 << (bit_width - 1)) - 1
    
    if not (min_val <= val <= max_val):
        raise ValueError(f"Immediate {val} out of range for {bit_width}-bit signed integer.")

    # Convert to 2's complement binary string
    if val < 0:
        val = (1 << bit_width) + val
        
    fmt = f"{{0:0{bit_width}b}}"
    return fmt.format(val)

def assemble(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    instructions = []
    labels = {}
    pc = 0

    # PASS 1: Symbol Table (Labels)
    clean_lines = []
    for line in lines:
        # Strip comments
        if '#' in line:
            line = line.split('#')[0]
        if '//' in line:
            line = line.split('//')[0]
        
        line = line.strip()
        if not line:
            continue
            
        # Check for label
        if line.endswith(':'):
            label_name = line[:-1]
            labels[label_name] = pc
            continue
        
        # If label is inline "LOOP: ADDI ..."
        if ':' in line:
            parts = line.split(':')
            label_name = parts[0].strip()
            labels[label_name] = pc
            line = parts[1].strip()

        clean_lines.append(line)
        pc += 1

    # PASS 2: Translation
    machine_code = []
    
    for i, line in enumerate(clean_lines):
        tokens = re.split(r'[\s,]+', line)
        mnemonic = tokens[0].upper()
        
        try:
            # === R-TYPE (Op: 3, Rs: 3, Rd: 3) ===
            if mnemonic in ['ADD', 'ANDB', 'XOR']:
                rd = parse_register(tokens[1], 3)
                rs = parse_register(tokens[2], 3)
                
                if mnemonic == 'ADD':   opcode = '111'
                elif mnemonic == 'ANDB': opcode = '110'
                elif mnemonic == 'XOR':  opcode = '101'
                
                bin_str = f"{opcode}{rs:03b}{rd:03b}"

            # S-TYPE (Op: 3, Sel: 1, Rs: 2, Rd: 3)
            elif mnemonic in ['SHL', 'SHR']:
                opcode = '100'
                rd = parse_register(tokens[1], 3)
                rs = parse_register(tokens[2], 2) # constrained to 2 bits
                
                sel = '0' if mnemonic == 'SHL' else '1'
                bin_str = f"{opcode}{sel}{rs:02b}{rd:03b}"

            # B-TYPE (Op: 3, Sel: 2, Rs: 1, Rd: 3)
            elif mnemonic in ['BEQ', 'BLT', 'BOV', 'LBMEM', 'LBLUT', 'SBMEM']:
                rd = parse_register(tokens[1], 3)
                rs = parse_register(tokens[2], 1) # constrained to 1 bit (R0 or R1)
                
                if mnemonic in ['BEQ', 'BLT', 'BOV']:
                    opcode = '010'
                    if mnemonic == 'BEQ': sel = '00'
                    elif mnemonic == 'BLT': sel = '01'
                    elif mnemonic == 'BOV': sel = '10'
                else:
                    opcode = '011'
                    if mnemonic == 'LBMEM': sel = '00'
                    elif mnemonic == 'LBLUT': sel = '01'
                    elif mnemonic == 'SBMEM': sel = '10'

                bin_str = f"{opcode}{sel}{rs:01b}{rd:03b}"

            # SPECIAL B-TYPE (No operands)
            elif mnemonic in ['START', 'DONE']:
                if mnemonic == 'START':
                    opcode = '010'
                else:
                    opcode = '011'
                bin_str = f"{opcode}110000"

            # I-TYPE (Op: 3, Imm: 6)
            elif mnemonic == 'ADDI':
                opcode = '000'
                imm_str = tokens[1]
                bin_str = f"{opcode}{parse_immediate(imm_str, 6)}"

            elif mnemonic == 'JUMP':
                opcode = '001'
                arg = tokens[1]
                
                # Handle Label
                if arg in labels:
                    target = labels[arg]
                    offset = target - i - 1 # PC is usually current + 1
                    bin_str = f"{opcode}{parse_immediate(str(offset), 6)}"
                else:
                    bin_str = f"{opcode}{parse_immediate(arg, 6)}"

            else:
                raise ValueError(f"Unknown instruction: {mnemonic}")

            machine_code.append(bin_str)

        except Exception as e:
            print(f"Error on line {i+1}: {line}")
            print(f"  {e}")
            sys.exit(1)

    with open(output_file, 'w') as f:
        for instr in machine_code:
            f.write(instr + '\n')
    
    print(f"Success! Machine code written to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python assembler.py <input.txt> <output.txt>")
    else:
        assemble(sys.argv[1], sys.argv[2])