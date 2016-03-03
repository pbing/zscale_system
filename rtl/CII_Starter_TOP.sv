/* FPGA top level
 *
 * KEY[0] external reset
 * 
 * I/O ports (see pk_poci.sv for addresses):
 * HEX
 * LEDG
 * LEDR
 * KEY
 * SW
 */

module CII_Starter_TOP
  (/* Clock Input */
   input  wire [1:0]  CLOCK_24,    // 24 MHz
   input  wire [1:0]  CLOCK_27,    // 27 MHz
   input  wire        CLOCK_50,    // 50 MHz
   input  wire        EXT_CLOCK,   // External Clock

   /* Push Button */
   input  wire [3:0]  KEY,         // Pushbutton[3:0]

   /* DPDT Switch */
   input wire  [9:0]  SW,          // Toggle Switch[9:0]

   /* 7-SEG Display */
   output wire [6:0]  HEX0,        // Seven Segment Digit 0
   output wire [6:0]  HEX1,        // Seven Segment Digit 1
   output wire [6:0]  HEX2,        // Seven Segment Digit 2
   output wire [6:0]  HEX3,        // Seven Segment Digit 3

   /* LED */
   output wire [7:0]  LEDG,        // LED Green[7:0]
   output wire [9:0]  LEDR,        // LED Red[9:0]

   /* UART */
   output wire        UART_TXD,    // UART Transmitter
   input  wire        UART_RXD,    // UART Receiver

   /* SDRAM Interface */
   inout  wire [15:0] DRAM_DQ,     // SDRAM Data bus 16 Bits
   output wire [11:0] DRAM_ADDR,   // SDRAM Address bus 12 Bits
   output wire        DRAM_LDQM,   // SDRAM Low-byte Data Mask
   output wire        DRAM_UDQM,   // SDRAM High-byte Data Mask
   output wire        DRAM_WE_N,   // SDRAM Write Enable
   output wire        DRAM_CAS_N,  // SDRAM Column Address Strobe
   output wire        DRAM_RAS_N,  // SDRAM Row Address Strobe
   output wire        DRAM_CS_N,   // SDRAM Chip Select
   output wire        DRAM_BA_0,   // SDRAM Bank Address 0
   output wire        DRAM_BA_1,   // SDRAM Bank Address 0
   output wire        DRAM_CLK,    // SDRAM Clock
   output wire        DRAM_CKE,    // SDRAM Clock Enable

   /* Flash Interface */
   inout  wire [7:0]  FL_DQ,       // FLASH Data bus 8 Bits
   output wire [21:0] FL_ADDR,     // FLASH Address bus 22 Bits
   output wire        FL_WE_N,     // FLASH Write Enable
   output wire        FL_RST_N,    // FLASH Reset
   output wire        FL_OE_N,     // FLASH Output Enable
   output wire        FL_CE_N,     // FLASH Chip Enable

   /* SRAMwire  Interface */
   inout  wire [15:0] SRAM_DQ,     // SRAM Data bus 16 Bits
   output wire [17:0] SRAM_ADDR,   // SRAM Address bus 18 Bits
   output wire        SRAM_UB_N,   // SRAM High-byte Data Mask
   output wire        SRAM_LB_N,   // SRAM Low-byte Data Mask
   output wire        SRAM_WE_N,   // SRAM Write Enable
   output wire        SRAM_CE_N,   // SRAM Chip Enable
   output wire        SRAM_OE_N,   // SRAM Output Enable

   /* SD Card Interface */
   inout  wire        SD_DAT,      // SD Card Data
   inout  wire        SD_DAT3,     // SD Card Data 3
   inout  wire        SD_CMD,      // SD Card Command Signal
   output wire        SD_CLK,      // SD Card Clock

   /* I2C */
   inout  wire        I2C_SDAT,    // I2C Data
   output wire        I2C_SCLK,    // I2C Clock

   /* PS2 */
   input  wire        PS2_DAT,     // PS2 Data
   input  wire        PS2_CLK,     // PS2 Clock

   /* USB JTAG link */
   input  wire        TDI,         // CPLD -> FPGA (data in)
   input  wire        TCK,         // CPLD -> FPGA (clk)
   input  wire        TCS,         // CPLD -> FPGA (CS)
   output wire        TDO,         // FPGA -> CPLD (data out)

   /* VGA */
   output wire        VGA_HS,      // VGA H_SYNC
   output wire        VGA_VS,      // VGA V_SYNC
   output wire [3:0]  VGA_R,       // VGA Red[3:0]
   output wire [3:0]  VGA_G,       // VGA Green[3:0]
   output wire [3:0]  VGA_B,       // VGA Blue[3:0]

   /* Audio CODEC */
   inout  wire        AUD_ADCLRCK, // Audio CODEC ADC LR Clock
   input  wire        AUD_ADCDAT,  // Audio CODEC ADC Data
   inout  wire        AUD_DACLRCK, // Audio CODEC DAC LR Clock
   output wire        AUD_DACDAT,  // Audio CODEC DAC Data
   inout  wire        AUD_BCLK,    // Audio CODEC Bit-Stream Clock
   output wire        AUD_XCK,     // Audio CODEC Chip Clock

   /* GPIO */
   inout  wire [35:0] GPIO_0,      // GPIO Connection 0
   inout  wire [35:0] GPIO_1);     // GPIO Connection 1

   /* common signals */
   wire reset;
   wire clk;

   /* Zscale signals */
   //logic      io_host_reset;
   logic        io_host_id = 1'b0;
   wire         io_host_csr_req_ready;
   logic        io_host_csr_req_valid = 1'b1;
   logic        io_host_csr_req_bits_rw = 1'b0;
   logic [11:0] io_host_csr_req_bits_addr = '0;
   logic [31:0] io_host_csr_req_bits_data = '0;
   logic        io_host_csr_resp_ready = 1'b0;
   wire         io_host_csr_resp_valid;
   wire[31:0]   io_host_csr_resp_bits;
   wire         io_host_debug_stats_csr;
   logic        init = 1'b1;

   /* POCI signals */
   wire presetn = ~reset;
   wire pclk    = clk;

   /* interfaces */
   if_poci pbus_leds();
   if_poci pbus_keys();
   
   sync_reset sync_reset
     (.clk,
      .key(KEY[0]),
      .reset);

   pll_20mhz pll
     (.inclk0 (CLOCK_50),
      .c0     (clk));

   ZscaleTop zscale_top
     (.clk,
      .reset,
      .io_host_reset(reset),
      .io_host_id,
      .io_host_csr_req_ready,
      .io_host_csr_req_valid,
      .io_host_csr_req_bits_rw,
      .io_host_csr_req_bits_addr,
      .io_host_csr_req_bits_data,
      .io_host_csr_resp_ready,
      .io_host_csr_resp_valid,
      .io_host_csr_resp_bits,
      .io_host_debug_stats_csr,
      .io_leds_paddr   (pbus_leds.paddr),
      .io_leds_pwrite  (pbus_leds.pwrite),
      .io_leds_psel    (pbus_leds.psel),
      .io_leds_penable (pbus_leds.penable),
      .io_leds_pwdata  (pbus_leds.pwdata),
      .io_leds_prdata  (pbus_leds.prdata),
      .io_leds_pready  (pbus_leds.pready),
      .io_leds_pslverr (pbus_leds.pslverr),
      .io_keys_paddr   (pbus_keys.paddr),
      .io_keys_pwrite  (pbus_keys.pwrite),
      .io_keys_psel    (pbus_keys.psel),
      .io_keys_penable (pbus_keys.penable),
      .io_keys_pwdata  (pbus_keys.pwdata),
      .io_keys_prdata  (pbus_keys.prdata),
      .io_keys_pready  (pbus_keys.pready),
      .io_keys_pslverr (pbus_keys.pslverr),
      .init);

   poci_keys poci_keys
     (.pclk,
      .presetn,
      .bus (pbus_keys),
      .key (KEY),
      .sw  (SW));

   poci_led_driver poci_led_driver
     (.pclk,
      .presetn,
      .bus  (pbus_leds),
      .hex  ({HEX3, HEX2, HEX1, HEX0}),
      .ledg (LEDG),
      .ledr (LEDR));
endmodule
