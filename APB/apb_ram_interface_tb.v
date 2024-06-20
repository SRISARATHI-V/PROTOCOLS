module apb_ram_interface_tb;

    // Parameters
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 10;

    // Signals
    reg PCLK;
    reg PSEL;
    reg PENABLE;
    reg PWRITE;
    reg [ADDR_WIDTH-1:0] PADDR;
    reg [DATA_WIDTH-1:0] PWDATA;
    wire [DATA_WIDTH-1:0] PRDATA;
    wire PREADY;
    wire PSLVERR;
  
    //Instantiate the APB RAM interface

    apb_ram_interface #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .PCLK(PCLK),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR)
    );
    // task based write operation 
    task automatic write_operation(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
    @(negedge PCLK);
    PSEL = 1;
    PWRITE = 1;
    PADDR = addr;
    PWDATA = data;
    @(negedge PCLK);
    PENABLE = 1;
    @(negedge PCLK);
    PSEL = 0;
    PENABLE = 0;
    PWRITE = 0;
endtask
  initial begin
        $dumpfile("dump.vcd");
    $dumpvars(1);
  end
  
// task based read operation
task automatic read_operation(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
    @(negedge PCLK);
    PSEL = 1;
    PWRITE = 0;
    PADDR = addr;
    @(negedge PCLK);
    PENABLE = 1;
    @(negedge PCLK);
    data = PRDATA;
    PSEL = 0;
    PENABLE = 0;
endtask

integer i;
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK; 
    end


  

initial begin
   

    PSEL = 0;
    PENABLE = 0;
    PWRITE = 0;
    PADDR = 0;
    PWDATA = 0;

    
    @(negedge PCLK);

  // perform write operation 6 times  
  for (i = 0; i < 6; i++) begin
        write_operation(10'h001 + i, 32'hDEADBEEF + i);
    end

  // perform read operation 6 times 
  for (i = 0; i < 6; i++) begin
      reg [DATA_WIDTH-1:0] data;
    
        
        read_operation(10'h001 + i, data);
       
    end

    $finish;
  end
endmodule
