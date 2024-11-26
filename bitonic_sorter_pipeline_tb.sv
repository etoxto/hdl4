`timescale 1ns / 1ps

module bitonic_sorter_pipeline_tb;

    logic clk;
    logic rst;
    logic start;
    logic signed [31:0] input_array[8];
    logic signed [31:0] output_array[8];

    bitonic_sorter_pipeline bitonic_sorter_pipeline (
        .clk_i  (clk),
        .rst_i  (rst),
        .start_i(start),
        .array_i(input_array),
        .array_o(output_array)
    );

    initial begin
        clk = 0;
        forever #5 clk <= ~clk;
    end

    initial begin
        rst = 1;
        #10;
        rst = 0;
        #10;
        // 1st example
        foreach (input_array[i]) input_array[i] = 8 - i;
        start = 1;
        #10;
        // 2nd example
        input_array[0] = 325;
        input_array[1] = 0;
        input_array[2] = -345345;
        input_array[3] = 1;
        input_array[4] = 325;
        input_array[5] = 0;
        input_array[6] = 325;
        input_array[7] = 8;
        #100;
        $stop;
    end

endmodule
