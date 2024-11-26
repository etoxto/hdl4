/*
 * NEXYS4_DDR.sv
 *
 *  Created on: 01.01.2020
 *      Author: Alexander Antonov <antonov.alex.alex@gmail.com>
 *     License: See LICENSE file for details
 */
 
interface MemSplit32 ();
    logic req;
    logic ack;
    logic [31:0] addr;
    logic we;
    logic [31:0] wdata;
    logic [3:0] be;
    logic resp;
    logic [31:0] rdata;

    modport Master  (output req, input ack, output addr, output we, output wdata, output be, input resp, input rdata);
    modport Slave   (input req, output ack, input addr, input we, input wdata, input be, output resp, output rdata);
endinterface


module NEXYS4_DDR
#( parameter SIM = "NO" )
(
	input 	CLK100MHZ
    , input   CPU_RESETN
    
    , input   [15:0] SW
    , output logic  [15:0] LED

    , input   UART_TXD_IN
    , output  UART_RXD_OUT
);

localparam UDM_BUS_TIMEOUT = (SIM == "YES") ? 100 : (1024*1024*100);
localparam UDM_RTX_EXTERNAL_OVERRIDE = (SIM == "YES") ? "YES" : "NO";

logic clk_gen;
logic pll_locked;

sys_clk sys_clk
(
    .clk_in1(CLK100MHZ)
    , .reset(!CPU_RESETN)
    , .clk_out1(clk_gen)
    , .locked(pll_locked)
);

logic arst;
assign arst = !(CPU_RESETN & pll_locked);

logic srst;
reset_sync reset_sync
(
	.clk_i(clk_gen),
	.arst_i(arst),
	.srst_o(srst)
);

logic udm_reset;

MemSplit32 udm_bus();

udm
#(
    .BUS_TIMEOUT(UDM_BUS_TIMEOUT)
    , .RTX_EXTERNAL_OVERRIDE(UDM_RTX_EXTERNAL_OVERRIDE)
) udm (
	.clk_i(clk_gen)
	, .rst_i(srst)

	, .rx_i(UART_TXD_IN)
	, .tx_o(UART_RXD_OUT)

	, .rst_o(udm_reset)
	
	, .bus_req_o(udm_bus.req)
	, .bus_we_o(udm_bus.we)
	, .bus_addr_bo(udm_bus.addr)
	, .bus_be_bo(udm_bus.be)
	, .bus_wdata_bo(udm_bus.wdata)
	, .bus_ack_i(udm_bus.ack)
	, .bus_resp_i(udm_bus.resp)
	, .bus_rdata_bi(udm_bus.rdata)
);

// bitonic_sorter

logic start;

logic signed [31:0] input_array [8];
logic signed [31:0] output_array[8];

bitonic_sorter_pipeline bitonic_sorter_pipeline (
    .clk_i(clk_gen),
    .rst_i(srst),
    .start_i(start),
    .array_i(input_array),
    .array_o(output_array)
);

localparam CSR_LED_ADDR         = 32'h00000000;
localparam CSR_SW_ADDR          = 32'h00000004;

localparam CSR_INPUT_ARRAY0     = 32'h00000008;
localparam CSR_INPUT_ARRAY1     = 32'h0000000C;
localparam CSR_INPUT_ARRAY2     = 32'h00000010;
localparam CSR_INPUT_ARRAY3     = 32'h00000014;
localparam CSR_INPUT_ARRAY4     = 32'h00000018;
localparam CSR_INPUT_ARRAY5     = 32'h0000001C;
localparam CSR_INPUT_ARRAY6     = 32'h00000020;
localparam CSR_INPUT_ARRAY7     = 32'h00000024;

localparam CSR_OUTPUT_ARRAY0    = 32'h00000028;
localparam CSR_OUTPUT_ARRAY1    = 32'h0000002C;
localparam CSR_OUTPUT_ARRAY2    = 32'h00000030;
localparam CSR_OUTPUT_ARRAY3    = 32'h00000034;
localparam CSR_OUTPUT_ARRAY4    = 32'h00000038;
localparam CSR_OUTPUT_ARRAY5    = 32'h0000003C;
localparam CSR_OUTPUT_ARRAY6    = 32'h00000040;
localparam CSR_OUTPUT_ARRAY7    = 32'h00000044;

localparam CSR_START_SORT    = 32'h00000048;
localparam CSR_RESULT_VALID    = 32'h0000004C;

localparam TESTMEM_ADDR         = 32'h80000000;

localparam TESTMEM_WSIZE_POW    = 10;
localparam TESTMEM_WSIZE        = 2**TESTMEM_WSIZE_POW;

logic udm_testmem_enb;
assign udm_testmem_enb = ((udm_bus.addr >= TESTMEM_ADDR) && (udm_bus.addr < (TESTMEM_ADDR + (TESTMEM_WSIZE*4))));
logic [31:0] udm_testmem_rdata;

logic testmem_p1_we;
logic [TESTMEM_WSIZE_POW-1:0] testmem_p1_addr;
logic [31:0] testmem_p1_wdata;
logic [31:0] testmem_p1_rdata;

// testmem's port1 is inactive
assign testmem_p1_we = 1'b0;
assign testmem_p1_addr = 0;
assign testmem_p1_wdata = 0;

ram_dual #(
    .init_type("none")
    , .init_data("nodata.hex")
    , .dat_width(32)
    , .adr_width(TESTMEM_WSIZE_POW)
    , .mem_size(TESTMEM_WSIZE)
) testmem (
    .clk(clk_gen)

    , .dat0_i(udm_bus.wdata)
    , .adr0_i(udm_bus.addr[31:2])
    , .we0_i(udm_bus.req && udm_bus.we && udm_testmem_enb)
    , .dat0_o(udm_testmem_rdata)

    , .dat1_i(testmem_p1_wdata)
    , .adr1_i(testmem_p1_addr)
    , .we1_i(testmem_p1_we)
    , .dat1_o(testmem_p1_rdata) 
);

assign udm_bus.ack = udm_bus.req;   // bus always ready to accept request
logic udm_csr_resp, udm_testmem_resp;
logic [31:0] udm_csr_rdata;

// bus request
always @(posedge clk_gen)
    begin
    udm_csr_resp <= 1'b0;
    udm_testmem_resp <= 1'b0;
    
    if (srst)
        begin
        LED <= 16'hffff;
        end
    
    else
        begin
        
        if (udm_bus.req && udm_bus.ack)
            begin
          
            if (udm_bus.we)     // writing
                begin
                if (udm_bus.addr == CSR_LED_ADDR) LED <= udm_bus.wdata;
                if (udm_bus.addr == CSR_INPUT_ARRAY0) input_array[0] <= udm_bus.wdata;
                if (udm_bus.addr == CSR_INPUT_ARRAY1) input_array[1] <= udm_bus.wdata;
                if (udm_bus.addr == CSR_INPUT_ARRAY2) input_array[2] <= udm_bus.wdata;
                if (udm_bus.addr == CSR_INPUT_ARRAY3) input_array[3] <= udm_bus.wdata;
                if (udm_bus.addr == CSR_INPUT_ARRAY4) input_array[4] <= udm_bus.wdata;
                if (udm_bus.addr == CSR_INPUT_ARRAY5) input_array[5] <= udm_bus.wdata;
                if (udm_bus.addr == CSR_INPUT_ARRAY6) input_array[6] <= udm_bus.wdata;
                if (udm_bus.addr == CSR_INPUT_ARRAY7) input_array[7] <= udm_bus.wdata;
                if (udm_bus.addr == CSR_START_SORT) start <= udm_bus.wdata;
                end
            else                // reading
                begin
                if (udm_bus.addr == CSR_LED_ADDR)
                    begin
                    udm_csr_resp <= 1'b1;
                    udm_csr_rdata <= LED;
                    end
                if (udm_bus.addr == CSR_SW_ADDR)
                    begin
                    udm_csr_resp <= 1'b1;
                    udm_csr_rdata <= SW;
                    end
                 if (udm_bus.addr == CSR_OUTPUT_ARRAY0)
                    begin
                    udm_csr_resp <= 1'b1;
                    udm_csr_rdata <= output_array[0];
                    end   
                  if (udm_bus.addr == CSR_OUTPUT_ARRAY1)
                    begin
                    udm_csr_resp <= 1'b1;
                    udm_csr_rdata <= output_array[1];
                    end                  
                if (udm_bus.addr == CSR_OUTPUT_ARRAY2)
                    begin
                    udm_csr_resp <= 1'b1;
                    udm_csr_rdata <= output_array[2];
                    end                  
                if (udm_bus.addr == CSR_OUTPUT_ARRAY3)
                    begin
                    udm_csr_resp <= 1'b1;
                    udm_csr_rdata <= output_array[3];
                    end                  
                if (udm_bus.addr == CSR_OUTPUT_ARRAY4)
                    begin
                    udm_csr_resp <= 1'b1;
                    udm_csr_rdata <= output_array[4];
                    end                  
                if (udm_bus.addr == CSR_OUTPUT_ARRAY5)
                    begin
                    udm_csr_resp <= 1'b1;
                    udm_csr_rdata <= output_array[5];
                    end                  
                if (udm_bus.addr == CSR_OUTPUT_ARRAY6)
                    begin
                    udm_csr_resp <= 1'b1;
                    udm_csr_rdata <= output_array[6];
                    end                  
                if (udm_bus.addr == CSR_OUTPUT_ARRAY7)
                    begin
                    udm_csr_resp <= 1'b1;
                    udm_csr_rdata <= output_array[7];
                    end    
                udm_testmem_resp <= udm_testmem_enb;
                end
            end
        
        end
    end

// bus response
assign udm_bus.resp = udm_csr_resp | udm_testmem_resp;
assign udm_bus.rdata = (udm_csr_rdata & {32{udm_csr_resp}}) | (udm_testmem_rdata & {32{udm_testmem_resp}});

endmodule
