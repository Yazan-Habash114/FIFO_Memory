module fifo_test;
  reg               clk   ;
  reg               wr    ;
  reg               rd    ;
  reg               rst_n ;
  reg     [7:0] data_in   ;
  wire         fifo_full  ;
  wire         fifo_empty ;
  wire    fifo_threshold  ;
  wire    fifo_underflow  ;
  wire    fifo_overflow   ;
  wire   [7:0] data_out   ;


  integer i;


  fifo_memory uut (
    .clk(clk),
    .wr(wr),
    .rd(rd),
    .rst_n(rst_n),
    .data_in(data_in),
    .fifo_full(fifo_full),
    .fifo_empty(fifo_empty),
    .fifo_threshold(fifo_threshold),
    .fifo_underflow(fifo_underflow),
    .fifo_overflow(fifo_overflow),
    .data_out(data_out) 
  );

  task expected;
    input [7:0] exp_data;

    if (data_out !== exp_data) begin
      $display("TEST FAILED");
      $display("At time %0d data_in=%d data_out=%d", $time, data_in, data_out);
      $display("data should be %d", exp_data);
      $finish;
    end

    else begin 
      $display("At time %0d data_in=%d data_out=%d", $time, data_in, data_out);
    end 
  endtask
  
  task expected_empty;
    input exp_empty;
    if (fifo_empty !== exp_empty) begin
      $display("TEST FAILED not EMPTY");
      $display("At time %0d data_in=%b data_out=%d , empty=%d", $time, data_in, data_out,fifo_empty);
      $display("memory not empty %d",exp_empty);
      $finish;
    end else begin 
      $display("At time %0d data_in=%d data_out=%d empty=%d", $time, data_in, data_out,fifo_empty);
    end 
  endtask

  task expected_full;
    input exp_full;

    if (fifo_full !== exp_full) begin
      $display("TEST FAILED not FULL");
      $display("At time %0d data_in=%b data_out=%d , full=%d", $time, data_in, data_out,fifo_full);
      $display("memory not full %d",exp_full);
      $finish;
    end else begin 
      $display("At time %0d data_in=%d data_out=%d full=%d", $time, data_in, data_out,fifo_full);
    end 
  endtask

  task expected_threshold;
    input exp_threshold;

    if(fifo_threshold !== exp_threshold) begin
      $display("TEST FAILED");
      $display("At time %0d data_in=%b data_out=%d , threshold=%d", $time, data_in, data_out,fifo_threshold);
      $display(" expected %d",exp_threshold);
      $finish;
    end else begin 
      $display("At time %0d data_in=%d data_out=%d threshold=%d", $time, data_in, data_out,fifo_threshold);
    end 
  endtask

  task expected_underflow;
    input exp_underflow;

    if(fifo_underflow !== exp_underflow) begin
      $display("TEST FAILED");
      $display("At time %0d data_in=%b data_out=%d , underflow=%d", $time, data_in, data_out,fifo_underflow);
      $display(" expected %d",exp_underflow);
      $finish;
    end else begin 
      $display("At time %0d data_in=%d data_out=%d underflow=%d", $time, data_in, data_out,fifo_underflow);
    end 
  endtask

  task expected_overflow;
    input exp_overflow;

    if(fifo_overflow !== exp_overflow) begin
      $display("TEST FAILED");
      $display("At time %0d data_in=%b data_out=%d , overflow=%d", $time, data_in, data_out,fifo_overflow);
      $display(" expected %d",exp_overflow);
      $finish;
    end else begin 
      $display("At time %0d data_in=%d data_out=%d overflow=%d", $time, data_in, data_out,fifo_overflow);
    end 
  endtask

  initial repeat(200) begin
    #5 clk=1; #5 clk=0;
  end

  initial @(negedge clk) begin: TEST
    $dumpfile("dump.vcd"); $dumpvars;
    //first test for overflow and underflow 
    wr=1; rd=0; rst_n=1; data_in=17;@(negedge clk) expected_overflow(0);

    wr=0; rd=1; rst_n=1; data_in=17;@(negedge clk) expected_underflow(1);
    //empty check

    wr=0; rd=0; rst_n=1; data_in=1;@(negedge clk) expected_full(0);
    wr=0; rd=0; rst_n=0; data_in=1;@(negedge clk) expected_empty(1);
    //read and write check
    wr=1; rd=0; rst_n=1; data_in=1;@(negedge clk);


    wr=0; rd=0; rst_n=1; data_in=1;@(negedge clk) expected_empty(0);
    //1 
    wr=0; rd=1; rst_n=1; data_in=1;@(negedge clk) expected(1);

    wr=1; rd=0; rst_n=1; data_in=2;@(negedge clk);

    wr=1; rd=0; rst_n=1; data_in=3;@(negedge clk);

    wr=1; rd=0; rst_n=1; data_in=4;@(negedge clk);
    //2
    wr=0; rd=1; rst_n=1; data_in=1;@(negedge clk) expected(2);
    //3
    wr=0; rd=1; rst_n=1; data_in=2;@(negedge clk) expected(3);
    //4
    wr=0; rd=1; rst_n=1; data_in=3;@(negedge clk) expected(4);

    wr=0; rd=0; rst_n=1; data_in=1;@(negedge clk) expected_threshold(1);
    //1 
    //reset check
    wr=0; rd=0; rst_n=0; data_in=3;@(negedge clk);
    //5 empty check again
    wr=0; rd=0; rst_n=0; data_in=1;@(negedge clk) expected_empty(1);
    //6

    // full check

    wr=0; rd=0; rst_n=1; data_in=1;@(negedge clk) expected_full(0);
    for (i=0;i<17;i=i+1)begin
      wr=1; rd=0; rst_n=1; data_in=i+1;@(negedge clk);


    end

    wr=0; rd=0; rst_n=1; data_in=1;@(negedge clk) expected_full(1);

    //overflow check
    wr=1; rd=0; rst_n=1; data_in=17;@(negedge clk) expected_overflow(1);

    //threshold check
    wr=0; rd=0; rst_n=1; data_in=1;@(negedge clk) expected_threshold(0);
    //read check
    for (i=0;i<16;i=i+1)begin
      wr=0; rd=1; rst_n=1; data_in=i+1;@(negedge clk)expected(i+1);
    end
    //underflow check
    wr=0; rd=1; rst_n=1; data_in=17;@(negedge clk) expected_underflow(1);
    // check the flags at the middle of process
    wr=0; rd=0; rst_n=0; data_in=0;@(negedge clk);

    for (i=0;i<8;i=i+1)begin
      wr=1; rd=0; rst_n=1; data_in=i+1;@(negedge clk);


    end
    wr=0; rd=0; rst_n=1;@(negedge clk) expected_full(0);

    wr=0; rd=0; rst_n=1;@(negedge clk) expected_empty(0);

    wr=0; rd=0; rst_n=1;@(negedge clk) expected_threshold(0);

    wr=0; rd=0; rst_n=1;@(negedge clk) expected_underflow(0);

    wr=0; rd=0; rst_n=1;@(negedge clk) expected_overflow(0);

    for(i = 0; i < 8; i = i+1) begin
      wr=0; rd=1; rst_n=1; data_in=i+1;@(negedge clk)expected(i+1);
    end

    wr = 0;
    rd = 1;
    rst_n = 1;
    @(negedge clk) expected_underflow(1);

    $display("TEST PASSED");
    $finish;
  end

endmodule
