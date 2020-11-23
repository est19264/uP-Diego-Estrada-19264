// Electronica Digital 1
// Proyecto Procesador
// Diego Estrada 19264


// Flip Flop D de un bit
module FlipFlopD1(
    input wire clk, reset, Enable, I1,
    output reg O1);

    always @ (posedge clk or posedge reset) begin
        if (reset) 
            O1 <= 1'b0;
        else if (Enable)
            O1 <= I1;
        end
endmodule


// FlipFlop Tipo D de dos bits.
module FlipFlopD2(
    input wire clk, reset, enabled,
    input wire [1:0]I2,
    output wire [1:0]O2);

    FlipFlopD1 B1(clk, reset, enabled, I2[0], O2[0]);
    FlipFlopD1 B2(clk, reset, enabled, I2[1], O2[1]);
endmodule


// FlipFlop Tipo D de cuatro bits.
module FlipFlopD4(
    input wire clk, reset, enabled,
    input wire [3:0]I3,
    output wire [3:0]O3);

    FlipFlopD2 C1(clk, reset, enabled, I3[3:2], O3[3:2]);
    FlipFlopD2 C2(clk, reset, enabled, I3[1:0], O3[1:0]);
endmodule


// Flip Flop T
module FlipFlopT(
    input wire clk, reset, enabled,
    output wire O1);

    FlipFlopD1 D1(clk, reset, enabled, ~O1, O1);
endmodule


// Modulo para FlipFlop de 1 bit para phase
module FlipFlopD_1(
    input wire clk, reset, I, 
    output reg O);

    always @ (posedge clk or posedge reset) begin
        if (reset) 
            O <= 1'b0;
        else 
            O <= I;
    end
endmodule


// Contador de 12 bits
module Counter(
    input wire clk, reset, Enable, P,
    input wire [11:0]load,
    output reg [11:0]exit);

        always @ (posedge clk or posedge reset)begin 
            if (reset == 1) 
                exit <= 12'b000000000000;
            
            else if(Enable == 1 && ~P) 
                exit <= exit + 1;
            
            else if(P == 1) // Mientras non sea 1, el valor va a ser el de load
                exit <= load;
            end
endmodule


// Memoria ROM de 4kx8
module ROM_4kx8 (
    input wire [11:0] I,
    output wire [7:0] O);
    reg [7:0] memo[0:4095];

    initial begin 
        $readmemh("memory.list", memo);
    end

    assign O = memo[I];

endmodule 


// Modulo de Fetch(registro)
module Fetch(
    input wire clk, reset, Enable2,
    input wire [7:0]I,
    output wire [3:0]O1,
    output wire [3:0]O2);

        FlipFlopD4 C1(clk, reset, Enable2, I[7:4], O1);
        FlipFlopD4 C2(clk, reset, Enable2, I[3:0], O2);
endmodule


//Buffer Tri Estado de cuatro bits
module BufferTri(
    input wire Enable,
    input wire [3:0]inputs,
    output wire [3:0]outputs);

        assign outputs = (Enable) ? inputs:4'bz;
endmodule


// Decode
module Dec(
    input wire [6:0]I,
    output wire [12:0]R);
    reg [12:0] O;

        always @ (I)begin
                O = 0;
                casez (I)
                    7'b????_??0: O <= 13'b1000_000_001000;    //ANY
                    7'b0000_1?1: O <= 13'b0100_000_001000;    //JC
                    7'b0000_0?1: O <= 13'b1000_000_001000;    
                    7'b0001_1?1: O <= 13'b1000_000_001000;    //JNC
                    7'b0001_0?1: O <= 13'b0100_000_001000;    
                    7'b0010_??1: O <= 13'b0001_001_000010;    //CMPI
                    7'b0011_??1: O <= 13'b1001_001_100000;    //CMPM
                    7'b0100_??1: O <= 13'b0011_010_000010;    //LIT
                    7'b0101_??1: O <= 13'b0011_010_000100;    //IN
                    7'b0110_??1: O <= 13'b1011_010_100000;    //LD
                    7'b0111_??1: O <= 13'b1000_000_111000;    //ST
                    7'b1000_?11: O <= 13'b0100_000_001000;    //JZ
                    7'b1000_?01: O <= 13'b1000_000_001000;
                    7'b1001_?11: O <= 13'b1000_000_001000;    //JNZ
                    7'b1001_?01: O <= 13'b0100_000_001000;
                    7'b1010_??1: O <= 13'b0011_011_000010;    //ADDI
                    7'b1011_??1: O <= 13'b1011_011_100000;    //ADDM
                    7'b1100_??1: O <= 13'b0100_000_001000;    //JMP
                    7'b1101_??1: O <= 13'b0000_000_001001;    //OUT
                    7'b1110_??1: O <= 13'b0011_100_000010;    //NANDI
                    7'b1111_??1: O <= 13'b1011_100_100000;    //NANDM
                    default: O <= 13'b1111111111111;
                endcase
        end
        assign R = O;
endmodule


// Memoria RAM
module RAM (
    input wire Enable, write,
    input wire [11:0] addres,
    output wire [3:0] data);

    reg [3:0]RAM[0:4095];
    reg [3:0]dataout;
    assign data = (Enable && ~write) ? dataout: 4'bzzzz;

    always @(Enable, write, addres, data) begin
        if (Enable & ~write)
            dataout = RAM[addres];
        if (Enable && write)
            RAM[addres] = data;
    end

    initial begin
        RAM[0] = 4'b0011;
    end
endmodule


// Modulo para la ALU
module ALU(
    input [3:0] I1,
    input [3:0] I2,
    input [2:0] com,
    output carry, zero,
    output [3:0] res);
    
    reg [4:0] regr;
    
    always @ (I1, I2, com)
        case (com)
            3'b000: regr = I1;
            3'b001: regr = I1 - I2;
            3'b010: regr = I2;
            3'b011: regr = I1 + I2;
            3'b100: regr = {1'b0, ~(I1 & I2)};
            default: regr = 5'b10101;
        endcase
    
    assign res = regr[3:0];
    assign carry = regr[4];
    assign zero = ~(regr[3] | regr[2] | regr[1] | regr[0]);
    
endmodule


// Modulo para el Acumulador
module Accu(
    input wire clk, reset, Enable,
    input wire [3:0]I, 
    output wire [3:0]O);

      FlipFlopD2 D1(clk, reset, Enable, I[3:2], O[3:2]);
      FlipFlopD2 D2(clk, reset, Enable, I[1:0], O[1:0]);
endmodule


// Modulo para Flags
module Flags(
    input wire clock, reset, En,
    input wire D1, D2,
    output wire Ze, C);

        FlipFlopD1 S1(clock, reset, En, D1, Ze);
        FlipFlopD1 S2(clock, reset, En, D2, C);

endmodule


// Modulo para Phase
module Phase(
    input wire clk, reset, 
    output wire O);
    
        FlipFlopD_1 D1(clk, reset, ~Q, Q);
endmodule


// Modulo principal del procesador
module uP(
    input wire clock, reset,
    input wire [3:0]pushbuttons,
    output wire phase, c_flag, z_flag,
    output wire [3:0] instr, oprnd, accu, data_bus, FF_out,
    output wire [7:0] program_byte,
    output wire [11:0] PC, address_RAM);

        wire [3:0] O_ALU;
        wire [12:0]O_DEC;
        wire [6:0]I_DEC;
        wire A, B;

        assign address_RAM = {oprnd, program_byte};
        assign I_DEC = {instr, c_flag, z_flag, phase};

        FlipFlopD4      OFFD4(clock, reset, O_DEC[0], data_bus, FF_out);
        FlipFlopT       Phase(clock, reset, 1'b1, phase);
        Counter         Program_Counter(clock, reset, O_DEC[12], O_DEC[11], address_RAM, PC);
        ROM_4kx8        ROM(PC, program_byte);
        RAM             RAM(O_DEC[5], O_DEC[4], address_RAM, data_bus);
        Fetch           Fetch(clock, reset, ~phase, program_byte, instr, oprnd);
        BufferTri       BFetch(O_DEC[1], oprnd, data_bus);
        BufferTri       BIn(O_DEC[2], pushbuttons, data_bus);
        BufferTri       BALU(O_DEC[3], O_ALU , data_bus);
        Dec             Decoder(I_DEC, O_DEC);
        ALU             ALU(accu, data_bus, O_DEC[8:6], B, A, O_ALU);
        Accu            Accumulator(clock, reset, O_DEC[10], O_ALU, accu);
        Flags           C_Flag(clock, reset, O_DEC[9], A, B, z_flag, c_flag);
endmodule   