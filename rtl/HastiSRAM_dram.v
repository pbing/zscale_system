/* dram */

module HastiSRAM_ram
  (input  wire        CLK,
   input  wire        RST,
   input  wire        init,
   input  wire [9:0]  W0A,
   input  wire        W0E,
   input  wire [31:0] W0I,
   input  wire [31:0] W0M,
   input  wire [9:0]  R1A,
   input  wire        R1E,
   output wire [31:0] R1O);

   wire [9:0] address = (W0E) ? W0A : R1A;

   wire [3:0] byteena = {|W0M[31:24], |W0M[23:16], |W0M[15:8], |W0M[7:0]};

   sram1kx32 ram 
     (.address(address),
      .byteena(byteena),
      .clock  (CLK),
      .data   (W0I),
      .wren   (W0E),
      .q      (R1O));
endmodule
