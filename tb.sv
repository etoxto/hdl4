/*
 * tb.v
 *
 *  Created on: 17.10.2019
 *      Author: Alexander Antonov <antonov.alex.alex@gmail.com>
 *     License: See LICENSE file for details
 */


`timescale 1ns / 1ps

`define HALF_PERIOD 5						//external 100 MHZ
`define DIVIDER_115200 32'd8680
`define DIVIDER_19200 32'd52083
`define DIVIDER_9600 32'd104166
`define DIVIDER_4800 32'd208333
`define DIVIDER_2400 32'd416666


module tb ();
    //
    logic CLK_100MHZ, RST, rx;
    logic [15:0] SW;
    logic [15:0] LED;

    always #`HALF_PERIOD CLK_100MHZ = ~CLK_100MHZ;

    always #1000 SW = SW + 8'h1;

    NEXYS4_DDR #(
        .SIM("YES")
    ) DUT (
        .CLK100MHZ(CLK_100MHZ),
        .CPU_RESETN(!RST),
        .SW(SW),
        .LED(LED),
        .UART_TXD_IN(rx),
        .UART_RXD_OUT()
    );

    ////reset all////
    task RESET_ALL();
        begin
            CLK_100MHZ = 1'b0;
            RST = 1'b1;
            rx = 1'b1;
            #(`HALF_PERIOD / 2);
            RST = 1;
            #(`HALF_PERIOD * 6);
            RST = 0;
            while (DUT.srst) WAIT(10);
        end
    endtask

    ////wait////
    task WAIT(input logic [15:0] periods);
        begin
            integer i;
            for (i = 0; i < periods; i = i + 1) begin
                #(`HALF_PERIOD * 2);
            end
        end
    endtask

    `define UDM_RX_SIGNAL rx
    `define UDM_BLOCK DUT.udm
    `include "udm.svh"
udm_driver udm = new();

    /////////////////////////
    // main test procedure //
    localparam CSR_LED_ADDR = 32'h00000000;
    localparam CSR_SW_ADDR = 32'h00000004;
    localparam TESTMEM_ADDR = 32'h80000000;

    localparam CSR_INPUT_ARRAY0 = 32'h00000008;
    localparam CSR_INPUT_ARRAY1 = 32'h0000000C;
    localparam CSR_INPUT_ARRAY2 = 32'h00000010;
    localparam CSR_INPUT_ARRAY3 = 32'h00000014;
    localparam CSR_INPUT_ARRAY4 = 32'h00000018;
    localparam CSR_INPUT_ARRAY5 = 32'h0000001C;
    localparam CSR_INPUT_ARRAY6 = 32'h00000020;
    localparam CSR_INPUT_ARRAY7 = 32'h00000024;

    localparam CSR_OUTPUT_ARRAY0 = 32'h00000028;
    localparam CSR_OUTPUT_ARRAY1 = 32'h0000002C;
    localparam CSR_OUTPUT_ARRAY2 = 32'h00000030;
    localparam CSR_OUTPUT_ARRAY3 = 32'h00000034;
    localparam CSR_OUTPUT_ARRAY4 = 32'h00000038;
    localparam CSR_OUTPUT_ARRAY5 = 32'h0000003C;
    localparam CSR_OUTPUT_ARRAY6 = 32'h00000040;
    localparam CSR_OUTPUT_ARRAY7 = 32'h00000044;

    localparam CSR_START_SORT = 32'h00000048;
    localparam CSR_RESULT_VALID = 32'h0000004C;

    initial begin
        logic [31:0] wrdata[];
        integer ARRSIZE = 10;

        $display("### SIMULATION STARTED ###");

        SW = 8'h30;
        RESET_ALL();
        WAIT(10);

        udm.cfg(`DIVIDER_115200, 2'b00);
        udm.check();
        udm.hreset();
        WAIT(10);


        udm.wr32(CSR_INPUT_ARRAY0, 0);
        udm.wr32(CSR_INPUT_ARRAY1, -111);
        udm.wr32(CSR_INPUT_ARRAY2, 234);
        udm.wr32(CSR_INPUT_ARRAY3, 100);
        udm.wr32(CSR_INPUT_ARRAY4, 363455);
        udm.wr32(CSR_INPUT_ARRAY5, 2525);
        udm.wr32(CSR_INPUT_ARRAY6, -1);
        udm.wr32(CSR_INPUT_ARRAY7, 6);
        udm.wr32(CSR_START_SORT, 1);
        WAIT(10);
        udm.wr32(CSR_INPUT_ARRAY0, 120);
        udm.wr32(CSR_INPUT_ARRAY1, 2111);
        udm.wr32(CSR_INPUT_ARRAY2, -234);
        udm.wr32(CSR_INPUT_ARRAY3, -100);
        udm.wr32(CSR_INPUT_ARRAY4, 0);
        udm.wr32(CSR_INPUT_ARRAY5, -2525);
        udm.wr32(CSR_INPUT_ARRAY6, 0);
        udm.wr32(CSR_INPUT_ARRAY7, 6);
        udm.wr32(CSR_START_SORT, 1);
        WAIT(10);
        udm.rd32(CSR_OUTPUT_ARRAY0);
        udm.rd32(CSR_OUTPUT_ARRAY1);
        udm.rd32(CSR_OUTPUT_ARRAY2);
        udm.rd32(CSR_OUTPUT_ARRAY3);
        udm.rd32(CSR_OUTPUT_ARRAY4);
        udm.rd32(CSR_OUTPUT_ARRAY5);
        udm.rd32(CSR_OUTPUT_ARRAY6);
        udm.rd32(CSR_OUTPUT_ARRAY7);
        WAIT(10);

        $display("### TEST PROCEDURE FINISHED ###");
        $stop;
    end


endmodule
