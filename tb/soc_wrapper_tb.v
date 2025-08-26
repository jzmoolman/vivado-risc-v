`timescale 10 ns / 1 ps

module soc_wrapper #(
    // Width of data bus in bits
    parameter DATA_WIDTH = 64,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 13,
    // Width of ID signal
    parameter ID_WIDTH = 4)
   (clock,
    mem_ok,
    reset,
    rsta_busy_0);
    
  input clock;
  input mem_ok;
  input reset;
  output rsta_busy_0;

  wire <CONFIG>_inst_aresetn;
  
  wire                   s_axi_awready;
  wire                   s_axi_awvalid;
  wire [ID_WIDTH-1:0]    s_axi_awid;
  wire [ADDR_WIDTH-1:0]  s_axi_awaddr;
  wire [7:0]             s_axi_awlen;
  wire [2:0]             s_axi_awsize;
  wire [1:0]             s_axi_awburst;
  wire                   s_axi_awlock;
  wire [3:0]             s_axi_awcache;
  wire [2:0]             s_axi_awprot;
  wire                   s_axi_wvalid;
  wire                   s_axi_wready;
  wire [DATA_WIDTH-1:0]  s_axi_wdata;
  wire [STRB_WIDTH-1:0]  s_axi_wstrb;
  wire                   s_axi_wlast;
  wire                   s_axi_bready;
  wire                   s_axi_bvalid;
  wire [ID_WIDTH-1:0]    s_axi_bid;
  wire [1:0]             s_axi_bresp;
  wire                   s_axi_arready;
  wire                   s_axi_arvalid;
  wire [ID_WIDTH-1:0]    s_axi_arid;
  wire [ADDR_WIDTH-1:0]  s_axi_araddr;
  wire [7:0]             s_axi_arlen;
  wire [2:0]             s_axi_arsize;
  wire                   s_axi_rready;
  wire                   s_axi_rvalid;
  wire [3:0]             s_axi_rid;
  wire [DATA_WIDTH-1:0]  s_axi_rdata;
  wire [1:0]             s_axi_rresp;
  wire                   s_axi_rlast;
 
  <CONFIG> rocket_inst
       (.aresetn(<CONFIG>_inst_aresetn),
        .clock(clock),
        .clock_ok(clk_wiz_0_locked),
        .dma_axi4_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dma_axi4_arburst({1'b0,1'b1}),
        .dma_axi4_arcache({1'b0,1'b0,1'b1,1'b1}),
        .dma_axi4_arid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dma_axi4_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dma_axi4_arlock(1'b0),
        .dma_axi4_arprot({1'b0,1'b0,1'b0}),
        .dma_axi4_arqos({1'b0,1'b0,1'b0,1'b0}),
        .dma_axi4_arsize({1'b1,1'b0,1'b1}),
        .dma_axi4_arvalid(1'b0),
        .dma_axi4_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dma_axi4_awburst({1'b0,1'b1}),
        .dma_axi4_awcache({1'b0,1'b0,1'b1,1'b1}),
        .dma_axi4_awid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dma_axi4_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dma_axi4_awlock(1'b0),
        .dma_axi4_awprot({1'b0,1'b0,1'b0}),
        .dma_axi4_awqos({1'b0,1'b0,1'b0,1'b0}),
        .dma_axi4_awsize({1'b1,1'b0,1'b1}),
        .dma_axi4_awvalid(1'b0),
        .dma_axi4_bready(1'b0),
        .dma_axi4_rready(1'b0),
        .dma_axi4_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dma_axi4_wlast(1'b0),
        .dma_axi4_wstrb({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .dma_axi4_wvalid(1'b0),
        .interrupts({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .io_axi4_arready(1'b0),
        .io_axi4_awready(1'b0),
        .io_axi4_bid({1'b0,1'b0,1'b0,1'b0}),
        .io_axi4_bresp({1'b0,1'b0}),
        .io_axi4_bvalid(1'b0),
        .io_axi4_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .io_axi4_rid({1'b0,1'b0,1'b0,1'b0}),
        .io_axi4_rlast(1'b0),
        .io_axi4_rresp({1'b0,1'b0}),
        .io_axi4_rvalid(1'b0),
        .io_axi4_wready(1'b0),
        .io_ok(1'b1),
        
     
        .mem_axi4_awready(s_axi_awready),
        .mem_axi4_awvalid(s_axi_awvalid),
        .mem_axi4_awid(s_axi_awid),
        .mem_axi4_awaddr(s_axi_awaddr),
        .mem_axi4_awlen(s_axi_awlen),
        .mem_axi4_awsize(s_axi_awsize),
        .mem_axi4_awburst(s_axi_awburst),
        .mem_axi4_wvalid(s_axi_wvalid), 
        .mem_axi4_wready(s_axi_wready),
        .mem_axi4_wdata(s_axi_wdata),
        .mem_axi4_wstrb(s_axi_wstrb),
        .mem_axi4_wlast(s_axi_wlast),
        .mem_axi4_bready(s_axi_bready),
        .mem_axi4_bvalid(s_axi_bvalid),
        .mem_axi4_bid(s_axi_bid),
        .mem_axi4_bresp(s_axi_bresp),       
        .mem_axi4_arvalid(s_axi_arvalid),
        .mem_axi4_arready(s_axi_arready),
        .mem_axi4_arid(s_axi_arid),
        .mem_axi4_araddr(s_axi_araddr),
        .mem_axi4_arlen(s_axi_arlen),
        .mem_axi4_arsize(s_axi_arsize),
        .mem_axi4_arburst(s_axi_arburst),
        .mem_axi4_rready(s_axi_rready),
        .mem_axi4_rvalid(s_axi_rvalid),
        .mem_axi4_rid(s_axi_rid),
        .mem_axi4_rdata(s_axi_rdata),
        .mem_axi4_rresp(s_axi_rresp),
        .mem_axi4_rlast(s_axi_rlast),
        .mem_ok(mem_ok),
        .sys_reset(1'b0));
        
   axi_ram axi_ram_inst (
   .clk(clock),
   .rst(!<CONFIG>_inst_aresetn),
   .s_axi_awready(s_axi_awready), 
   .s_axi_awvalid(s_axi_awvalid),
   .s_axi_awid(s_axi_awid),
   .s_axi_awaddr(s_axi_awaddr[ADDR_WIDTH-1:0]),
   .s_axi_awlen(s_axi_awlen),
   .s_axi_awsize(s_axi_awsize),
   .s_axi_awburst(s_axi_awburst),
   .s_axi_awlock(),
   .s_axi_awcache(),
   .s_axi_awprot(),
   .s_axi_wvalid(s_axi_wvalid),
   .s_axi_wready(s_axi_wready),
   .s_axi_wdata(s_axi_wdata),
   .s_axi_wstrb(s_axi_wstrb),
   .s_axi_wlast(s_axi_wlast),
   .s_axi_bready(s_axi_bready),
   .s_axi_bvalid(s_axi_bvalid),
   .s_axi_bid(s_axi_bid),
   .s_axi_bresp(s_axi_bresp),
   .s_axi_arready(s_axi_arready),
   .s_axi_arvalid(s_axi_arvalid),
   .s_axi_arid(s_axi_arid),
   .s_axi_araddr(s_axi_araddr[ADDR_WIDTH-1:0]),
   .s_axi_arlen(s_axi_arlen),
   .s_axi_arsize(s_axi_arsize),
   .s_axi_arburst(s_axi_arburst),
   .s_axi_arlock(),
   .s_axi_arcache(),
   .s_axi_arprot(),
   .s_axi_rready(s_axi_rready),
   .s_axi_rvalid(s_axi_rvalid),
   .s_axi_rid(s_axi_rid),
   .s_axi_rdata(s_axi_rdata),
   .s_axi_rresp(s_axi_rresp),
   .s_axi_rlast(s_axi_r_last)
);
           
endmodule
