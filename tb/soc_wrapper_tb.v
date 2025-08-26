`timescale 1 ns / 1 ps

module soc_wrapper_tb #(
    // Width of data bus in bits
    parameter DATA_WIDTH = 64,
     // Width of address bus in bits
    parameter ADDR_WIDTH = 34,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
   
    parameter BRAM_ADDR_WIDTH = 16,
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
  
  wire                   s_axi_aw_ready;
  wire                   s_axi_aw_valid;
  wire [ID_WIDTH-1:0]    s_axi_aw_id;
  wire [ADDR_WIDTH-1:0]  s_axi_aw_addr;
  wire [7:0]             s_axi_aw_len;
  wire [2:0]             s_axi_aw_size;
  wire [1:0]             s_axi_aw_burst;
  wire                   s_axi_aw_lock;
  wire [3:0]             s_axi_aw_cache;
  wire [2:0]             s_axi_aw_prot;
  //wire [3:0]             s_axi_aw_qos; 
  
  wire                   s_axi_w_valid;
  wire                   s_axi_w_ready;
  wire [DATA_WIDTH-1:0]  s_axi_w_data;
  wire [STRB_WIDTH-1:0]  s_axi_w_strb;
  wire                   s_axi_w_last;
  
  wire                   s_axi_b_ready;
  wire                   s_axi_b_valid;
  wire [ID_WIDTH-1:0]    s_axi_b_id;
  wire [1:0]             s_axi_b_resp;
  
  wire                   s_axi_ar_ready;
  wire                   s_axi_ar_valid;
  wire [ID_WIDTH-1:0]    s_axi_ar_id;
  wire [ADDR_WIDTH-1:0]  s_axi_ar_addr;
  wire [7:0]             s_axi_ar_len;
  wire [2:0]             s_axi_ar_size;
  
  wire [1:0]             s_axi_ar_burst;
  wire                   s_axi_ar_lock;
  wire [3:0]             s_axi_ar_cache;
  wire [2:0]             s_axi_ar_prot;
  //wire [3:0]             s_axi_ar_qos; 
  
  wire                   s_axi_r_ready;
  wire                   s_axi_r_valid;
  wire [ID_WIDTH-1:0]    s_axi_r_id;
  wire [DATA_WIDTH-1:0]  s_axi_r_data;
  wire [1:0]             s_axi_r_resp;
  wire                   s_axi_r_last;
 
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
        
     
        .mem_axi4_awready(s_axi_aw_ready),
        .mem_axi4_awvalid(s_axi_aw_valid),
        .mem_axi4_awid(s_axi_aw_id),
        .mem_axi4_awaddr(s_axi_aw_addr),
        .mem_axi4_awlen(s_axi_aw_len),
        .mem_axi4_awsize(s_axi_aw_size),
        .mem_axi4_awburst(s_axi_aw_burst),
        .mem_axi4_awlock(s_axi_aw_lock),   // 1
        .mem_axi4_awcache(s_axi_aw_cache),  // 4          
        .mem_axi4_awprot(s_axi_aw_prot),    // 3
        .mem_axi4_awqos(), //BRAM does not support qos
        
        .mem_axi4_wready(s_axi_w_ready),
        .mem_axi4_wvalid(s_axi_w_valid), 
        .mem_axi4_wdata(s_axi_w_data),
        .mem_axi4_wstrb(s_axi_w_strb),
        .mem_axi4_wlast(s_axi_w_last),
               
        .mem_axi4_bready(s_axi_b_ready),
        .mem_axi4_bvalid(s_axi_b_valid),
        .mem_axi4_bid(s_axi_b_id),
        .mem_axi4_bresp(s_axi_b_resp),
        
        .mem_axi4_arvalid(s_axi_ar_valid),
        .mem_axi4_arready(s_axi_ar_ready),
        .mem_axi4_arid(s_axi_ar_id),
        .mem_axi4_araddr(s_axi_ar_addr),
        .mem_axi4_arlen(s_axi_ar_len),
        .mem_axi4_arsize(s_axi_ar_size),
        .mem_axi4_arburst(s_axi_ar_burst),
        .mem_axi4_arlock(s_axi_ar_lock),   // 1
        .mem_axi4_arcache(s_axi_ar_cache),  // 4          
        .mem_axi4_arprot(s_axi_ar_prot),    // 3
        .mem_axi4_arqos(),  // BRAM does not support qos
        
        .mem_axi4_rready(s_axi_r_ready),
        .mem_axi4_rvalid(s_axi_r_valid),
        .mem_axi4_rid(s_axi_r_id),
        .mem_axi4_rdata(s_axi_r_data),
        .mem_axi4_rresp(s_axi_r_resp),
        .mem_axi4_rlast(s_axi_r_last),
        .mem_ok(mem_ok),
        .sys_reset(1'b0)); // this 
        
   axi_ram  #(
     .DATA_WIDTH(DATA_WIDTH),
     .ADDR_WIDTH(BRAM_ADDR_WIDTH), // NOTE: THE SIZE
     .STRB_WIDTH(STRB_WIDTH),
     .ID_WIDTH(ID_WIDTH)
   ) axi_ram_inst (
   .clk(clock),
   .rst(!<CONFIG>_inst_aresetn),
   .s_axi_awready(s_axi_aw_ready), 
   .s_axi_awvalid(s_axi_aw_valid),
   .s_axi_awid(s_axi_aw_id),
   .s_axi_awaddr(s_axi_aw_addr[BRAM_ADDR_WIDTH-1:0]),
   .s_axi_awlen(s_axi_aw_len),
   .s_axi_awsize(s_axi_aw_size),
   .s_axi_awburst(s_axi_aw_burst),
   .s_axi_awlock(s_axi_aw_lock),
   .s_axi_awcache(s_aw_cache),
   .s_axi_awprot(s_aw_prot),
   .s_axi_wvalid(s_axi_w_valid),
   .s_axi_wready(s_axi_w_ready),
   .s_axi_wdata(s_axi_w_data),
   .s_axi_wstrb(s_axi_w_strb),
   .s_axi_wlast(s_axi_w_last),
   .s_axi_bready(s_axi_b_ready),
   .s_axi_bvalid(s_axi_b_valid),
   .s_axi_bid(s_axi_b_id),
   .s_axi_bresp(s_axi_b_resp),
   .s_axi_arready(s_axi_ar_ready),
   .s_axi_arvalid(s_axi_ar_valid),
   .s_axi_arid(s_axi_ar_id),
   .s_axi_araddr(s_axi_ar_addr[BRAM_ADDR_WIDTH-1:0]),
   .s_axi_arlen(s_axi_ar_len),
   .s_axi_arsize(s_axi_ar_size),
   .s_axi_arburst(s_axi_ar_burst),
   .s_axi_arlock(s_axi_ar_lock),
   .s_axi_arcache(s_axi_ar_cache),
   .s_axi_arprot(s_axi_ar_prot),
   .s_axi_rready(s_axi_r_ready),
   .s_axi_rvalid(s_axi_r_valid),
   .s_axi_rid(s_axi_r_id),
   .s_axi_rdata(s_axi_r_data),
   .s_axi_rresp(s_axi_r_resp),
   .s_axi_rlast(s_axi_r_last)
);
           
endmodule
