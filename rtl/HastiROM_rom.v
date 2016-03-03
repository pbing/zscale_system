/* bootmem */

module HastiROM_rom
  (input  wire        CLK,
   input  wire        RST,
   input  wire        init,
   input  wire [9:0]  R0A,
   input  wire        R0E,
   output wire [31:0] R0O);

   rom1kx32 rom
     (.address(R0A),
      .clock  (CLK),
      .q      (R0O));
endmodule
