/* Interfaces */

interface if_poci;
   import pk_poci::*;

   logic [addr_width - 1:0] paddr;
   logic                    pwrite;
   logic                    psel;
   logic                    penable;
   logic [data_width - 1:0] pwdata;
   logic [data_width - 1:0] prdata;
   logic                    pready;
   logic                    pslverr;

   /* non flipped */
   modport n
     (output paddr,
      output pwrite,
      output psel,
      output penable,
      output pwdata,
      input  prdata,
      input  pready,
      input  pslverr);

   /* non flipped */
   modport f
     (input  paddr,
      input  pwrite,
      input  psel,
      input  penable,
      input  pwdata,
      output prdata,
      output pready,
      output pslverr);
endinterface:if_poci
