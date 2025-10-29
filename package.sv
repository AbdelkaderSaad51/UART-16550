package registers;
 ////////////FCR
   typedef struct packed {
    logic  [1:0] rx_trigger;        //Receive trigger
    logic [1:0] reserved;          //reserved
    logic       dma_mode;          //DMA mode select
    logic       tx_rst;            //Transmit FIFO Reset
    logic       rx_rst;            //Receive FIFO Reset
    logic       ena;               //FIFO enabled
  } fcr_t; //FIFO Control Register
 
 ////////////// LCR
   typedef struct packed {
    logic       dlab;    
    logic       set_break;     
    logic       stick_parity;     
    logic       eps; 
    logic       pen;
    logic       stb; 
    logic [1:0] wls; 
  } lcr_t;   
  
 ////////////// LSR
   typedef struct packed {
    logic       rx_fifo_error;
    logic       temt;              //Transmitter Emtpy
    logic       thre;              //Transmitter Holding Register Empty
    logic       bi;                //Break Interrupt
    logic       fe;                //Framing Error
    logic       pe;                //Parity Error
    logic       oe;                //Overrun Error
    logic       dr;                //Data Ready
  } lsr_t; //Line Status Register
  
  ////struct to hold all registers
 typedef struct {
 fcr_t       fcr; 
 lcr_t       lcr; 
 lsr_t       lsr; 
 logic [7:0] scr; 
 } csr_t;
  
  
 typedef struct packed {
    logic [7:0] dmsb;               //Divisor Latch MSB
    logic [7:0] dlsb;               //Divisor Latch LSB
  } div_t;
    
endpackage : registers