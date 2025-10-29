`timescale 1ns / 1ps

module uart_tb;

  // DUT signals
  reg clk, rst, wr, rd, rx;
  reg [2:0] addr;
  reg [7:0] din;
  wire tx;
  wire [7:0] dout;

  // Instantiate DUT
  all_mod dut (
    .clk(clk),
    .rst(rst),
    .wr(wr),
    .rd(rd),
    .rx(rx),
    .addr(addr),
    .din(din),
    .tx(tx),
    .dout(dout)
  );

  // Clock generation (10 ns period)
  always #5 clk = ~clk;

  // Reset task
  task reset_dut();
    begin
      rst = 1'b1;
      wr = 0; rd = 0; addr = 0; din = 0; rx = 1;
      repeat (5) @(posedge clk);
      rst = 1'b0;
      repeat (2) @(posedge clk);
      $display("[%0t] Reset complete", $time);
    end
  endtask

  // Initialize UART (baud + LCR)
  task init_uart();
    begin
      // Set DLAB = 1
      @(negedge clk);
      wr = 1; addr = 3'h3; din = 8'b1000_0000; // DLAB = 1

      // Set divisor = 0x0108
      @(negedge clk);
      addr = 3'h0; din = 8'h08;  // DLL
      @(negedge clk);
      addr = 3'h1; din = 8'h01;  // DLM

      // DLAB = 0, 8-bit, 1 stop, parity enabled, odd
      @(negedge clk);
      wr = 1; addr = 3'h3; din = 8'b0000_1100;
      @(negedge clk);
      wr = 0;
      $display("[%0t] UART initialized", $time);
    end
  endtask

  // Task: Transmit one byte
  task write_byte(input [7:0] data);
    begin
      @(negedge clk);
      wr = 1; addr = 3'h0; din = data;
      @(negedge clk);
      wr = 0;
      $display("[%0t] Wrote byte 0x%0h to TX FIFO", $time, data);
      @(posedge dut.uart_tx_inst.sreg_empty);
      repeat(10) @(posedge dut.uart_tx_inst.baud_pulse);
    end
  endtask

  // Task: Transmit multiple bytes (FIFO test)
  task fifo_overrun_test();
    integer i;
    @(negedge clk);
    wr = 1; addr = 3'h2; din = 8'b0000_0001; // enable FIFO
    begin
      $display("[%0t] Starting FIFO overrun test", $time);
      for (i = 0; i < 40; i++) begin
      @(negedge clk);
      wr = 1; addr = 3'h0; din = i;
      @(posedge clk); // allow DUT to sample wr
      @(negedge clk);
      wr = 0;
                            end
      repeat(100) @(posedge clk);
      $display("[%0t] FIFO overrun test completed", $time);
    end
  endtask

  // Task: Change parity and send test bytes
  task parity_test();
    begin
      $display("[%0t] Starting parity mode tests", $time);
      
      // Odd parity
      @(negedge clk);
      wr = 1; addr = 3'h3; din = 8'b0000_1100; // Odd
      @(negedge clk); wr = 0;
      write_byte(8'hA5);

      // Even parity
      @(negedge clk);
      wr = 1; addr = 3'h3; din = 8'b0001_1100; // Even
      @(negedge clk); wr = 0;
      write_byte(8'h5A);

      // Stick parity 
      @(negedge clk);
      wr = 1; addr = 3'h3; din = 8'b0011_1100;//Stick to 0
      @(negedge clk); wr = 0;
      write_byte(8'hFF);
    end
  endtask

  // Task: Change stop bit setting
  task stop_bit_test();
    begin
      $display("[%0t] Starting stop-bit configuration test", $time);
      // 2 stop bits
      @(negedge clk);
      wr = 1; addr = 3'h3; din = 8'b0000_1011; // 2 stop bits
      @(negedge clk); wr = 0;
      write_byte(8'h55);
    end
  endtask

  // Task: Reset test mid-transmission
  task reset_test();
    begin
      $display("[%0t] Starting reset test", $time);
      write_byte(8'hA0);
      #20;
      rst = 1'b1;
      #10;
      rst = 1'b0;
      $display("[%0t] DUT reset mid-transmission", $time);
    end
  endtask

  // Main Test Sequence
  initial begin
    clk = 0;
    reset_dut();
    init_uart();

    // Testcases
    write_byte(8'hF0);          // Simple TX
    fifo_overrun_test();        // FIFO behavior
    reset_dut();
    parity_test();              // Parity configurations
    stop_bit_test();            // Stop bit config
    reset_test();               // Reset behavior

    $display("[%0t] All UART tests completed", $time);
    $stop;
  end

endmodule
