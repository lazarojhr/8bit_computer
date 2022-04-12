# This is an 8 bit computer created in Logisim-Evolution

![alt text](screenshots/Computer.png?raw=true)

## RAM
    
    * 00 to 3F -- Program space -- 16 bits
    * 40 to FF -- User space    -- 8 bits

## INSTRUCTION SET
    
    * 16 bit WORD

        * 5 bits -- OPCODE
        * 3 bits -- LOCATION -- ACC 000 | REG_0 001 | REG_1 010 | REG_2 011 | REG_3 100 | REG_4 101 | INPUT_PORT 110 | OUTPUT_PORT 111
        * 8 bits -- ADDRESS or LITERAL

## ASSEMBLER
    
    * The very simple "assembler" was writen in BASH shell script.
    * The instructions are under the documentation directory in the file called assembly_instructions.txt
    * Example programs are under the examples directory.

## HOW TO USE

    * Write your program.
    * Call the assembler script located under the assembler directory. Pass it the name of your assembly code file and a name for the output file.
    * Load the output file into the ROM by right clicking the ROM and selecting load.
    * Run the "Transfer ROM to RAM" circuit by making the "Start_Transfer" Pin HIGH (CLK must be running).
    * Stop the "Transfer ROM to RAM" by making the "Start_Transfer" Pin LOW.
    * The RAM now has the program stored.
    * Run the computer (The computer runs as long as the CLK is running and the MASTER_RESET and the CLEAR_RAM_MDR_MAR Pins are LOW).
