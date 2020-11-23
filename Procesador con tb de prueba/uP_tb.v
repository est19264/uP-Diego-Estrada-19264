// Electronica Digital 1
// Proyecto Procesador Testbench de prueba
// Diego Estrada 19264


module testbench();

    reg clock, reset;
    reg [3:0] pushbuttons;
    wire phase, c_flag, z_flag;
    wire [3:0] instr, oprnd, accu, data_bus, FF_out;
    wire [7:0] program_byte;
    wire [11:0] PC, address_RAM;

    integer immediateDelay = 16;
    integer jumpDelay = 656;
    integer memoryDelay = 276;

    uP uPmodule(.clock(clock),
                .reset(reset),
                .pushbuttons(pushbuttons),
                .phase(phase),
                .c_flag(c_flag),
                .z_flag(z_flag),
                .instr(instr),
                .oprnd(oprnd),
                .accu(accu),
                .data_bus(data_bus),
                .FF_out(FF_out),
                .program_byte(program_byte),
                .PC(PC),
                .address_RAM(address_RAM));

    always
        #1 clock = ~clock;


    initial begin
        $display("Testbench de prueba proyecto");
        $display("Clock     Reset      Pushbuttons   |    phase   c_flag   z_flag    instr     oprnd     data_bus     FF_out    accu     program_byte     PC      address_RAM");
        $monitor("%b            %b          $b         |    %b      $b       %b        $b         %b          $b           %b       $b      %b     $b        %b", clock, reset, pushbuttons, phase, c_flag, z_flag, instr, oprnd, data_bus, FF_out, accu, program_byte, PC, address_RAM);
        clock = 0; reset = 0; pushbuttons = 4'b0110;
        #1 reset = 1;
        #1 reset = 0;
        #3 reset = 0; pushbuttons = 4'b0101;
        #3 reset = 0; pushbuttons = 4'b0010;
        #3 reset = 0; pushbuttons = 4'b1001;
    
    end

    
    initial
    #30 $finish;

    initial begin
        $dumpfile("uP_tb.vcd");
        $dumpvars(0, testbench); 
    end

endmodule
