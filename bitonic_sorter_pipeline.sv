`timescale 1ns / 1ps

module bitonic_sorter_pipeline (
    input logic clk_i,
    input logic rst_i,
    input logic start_i,
    // output logic result_valid_o,
    input logic signed [31:0] array_i[8],
    output logic signed [31:0] array_o[8]
);

    logic signed [31:0]
        array_stage1[8], array_stage2[8], array_stage3[8], array_stage4[8], array_stage5[8];

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            foreach (array_stage1[i]) array_stage1[i] <= 0;
        end else begin
            array_stage1[0] <= (array_i[1] > array_i[0]) ? array_i[0] : array_i[1];
            array_stage1[1] <= (array_i[1] > array_i[0]) ? array_i[1] : array_i[0];
            array_stage1[2] <= (array_i[3] > array_i[2]) ? array_i[2] : array_i[3];
            array_stage1[3] <= (array_i[3] > array_i[2]) ? array_i[3] : array_i[2];
            array_stage1[4] <= (array_i[5] > array_i[4]) ? array_i[4] : array_i[5];
            array_stage1[5] <= (array_i[5] > array_i[4]) ? array_i[5] : array_i[4];
            array_stage1[6] <= (array_i[7] > array_i[6]) ? array_i[6] : array_i[7];
            array_stage1[7] <= (array_i[7] > array_i[6]) ? array_i[7] : array_i[6];
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            foreach (array_stage2[i]) array_stage2[i] <= 0;
        end else if (start_i) begin
            array_stage2[0] <= (array_stage1[3] > array_stage1[0]) ? array_stage1[0] : array_stage1[3];
            array_stage2[3] <= (array_stage1[3] > array_stage1[0]) ? array_stage1[3] : array_stage1[0];
            array_stage2[1] <= (array_stage1[2] > array_stage1[1]) ? array_stage1[1] : array_stage1[2];
            array_stage2[2] <= (array_stage1[2] > array_stage1[1]) ? array_stage1[2] : array_stage1[1];
            array_stage2[4] <= (array_stage1[7] > array_stage1[4]) ? array_stage1[4] : array_stage1[7];
            array_stage2[7] <= (array_stage1[7] > array_stage1[4]) ? array_stage1[7] : array_stage1[4];
            array_stage2[5] <= (array_stage1[6] > array_stage1[5]) ? array_stage1[5] : array_stage1[6];
            array_stage2[6] <= (array_stage1[6] > array_stage1[5]) ? array_stage1[6] : array_stage1[5];
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            foreach (array_stage3[i]) array_stage3[i] <= 0;
        end else if (start_i) begin
            array_stage3[0] <= (array_stage2[1] > array_stage2[0]) ? array_stage2[0] : array_stage2[1];
            array_stage3[1] <= (array_stage2[1] > array_stage2[0]) ? array_stage2[1] : array_stage2[0];
            array_stage3[2] <= (array_stage2[3] > array_stage2[2]) ? array_stage2[2] : array_stage2[3];
            array_stage3[3] <= (array_stage2[3] > array_stage2[2]) ? array_stage2[3] : array_stage2[2];
            array_stage3[4] <= (array_stage2[5] > array_stage2[4]) ? array_stage2[4] : array_stage2[5];
            array_stage3[5] <= (array_stage2[5] > array_stage2[4]) ? array_stage2[5] : array_stage2[4];
            array_stage3[6] <= (array_stage2[7] > array_stage2[6]) ? array_stage2[6] : array_stage2[7];
            array_stage3[7] <= (array_stage2[7] > array_stage2[6]) ? array_stage2[7] : array_stage2[6];
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            foreach (array_stage4[i]) array_stage4[i] <= 0;
        end else if (start_i) begin
            array_stage4[0] <= (array_stage3[7] > array_stage3[0]) ? array_stage3[0] : array_stage3[7];
            array_stage4[7] <= (array_stage3[7] > array_stage3[0]) ? array_stage3[7] : array_stage3[0];
            array_stage4[1] <= (array_stage3[6] > array_stage3[1]) ? array_stage3[1] : array_stage3[6];
            array_stage4[6] <= (array_stage3[6] > array_stage3[1]) ? array_stage3[6] : array_stage3[1];
            array_stage4[2] <= (array_stage3[5] > array_stage3[2]) ? array_stage3[2] : array_stage3[5];
            array_stage4[5] <= (array_stage3[5] > array_stage3[2]) ? array_stage3[5] : array_stage3[2];
            array_stage4[3] <= (array_stage3[4] > array_stage3[3]) ? array_stage3[3] : array_stage3[4];
            array_stage4[4] <= (array_stage3[4] > array_stage3[3]) ? array_stage3[4] : array_stage3[3];
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            foreach (array_stage5[i]) array_stage5[i] <= 0;
        end else if (start_i) begin
            array_stage5[0] <= (array_stage4[2] > array_stage4[0]) ? array_stage4[0] : array_stage4[2];
            array_stage5[2] <= (array_stage4[2] > array_stage4[0]) ? array_stage4[2] : array_stage4[0];
            array_stage5[1] <= (array_stage4[3] > array_stage4[1]) ? array_stage4[1] : array_stage4[3];
            array_stage5[3] <= (array_stage4[3] > array_stage4[1]) ? array_stage4[3] : array_stage4[1];
            array_stage5[4] <= (array_stage4[6] > array_stage4[4]) ? array_stage4[4] : array_stage4[6];
            array_stage5[6] <= (array_stage4[6] > array_stage4[4]) ? array_stage4[6] : array_stage4[4];
            array_stage5[5] <= (array_stage4[7] > array_stage4[5]) ? array_stage4[5] : array_stage4[7];
            array_stage5[7] <= (array_stage4[7] > array_stage4[5]) ? array_stage4[7] : array_stage4[5];
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            foreach (array_o[i]) array_o[i] <= 0;
        end else if (start_i) begin
            array_o[0] <= (array_stage5[1] > array_stage5[0]) ? array_stage5[0] : array_stage5[1];
            array_o[1] <= (array_stage5[1] > array_stage5[0]) ? array_stage5[1] : array_stage5[0];
            array_o[2] <= (array_stage5[3] > array_stage5[2]) ? array_stage5[2] : array_stage5[3];
            array_o[3] <= (array_stage5[3] > array_stage5[2]) ? array_stage5[3] : array_stage5[2];
            array_o[4] <= (array_stage5[5] > array_stage5[4]) ? array_stage5[4] : array_stage5[5];
            array_o[5] <= (array_stage5[5] > array_stage5[4]) ? array_stage5[5] : array_stage5[4];
            array_o[6] <= (array_stage5[7] > array_stage5[6]) ? array_stage5[6] : array_stage5[7];
            array_o[7] <= (array_stage5[7] > array_stage5[6]) ? array_stage5[7] : array_stage5[6];
        end
    end

endmodule
