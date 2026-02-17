`timescale 1ns / 1ps

module clck_psc #(
    parameter integer CLK_FREQ = 50_000_000,
    parameter integer OUT_FREQ = 1
)(
    input  wire clk,
    input  wire rst,
    output reg  tick
);

    localparam integer COUNT_MAX = (OUT_FREQ <= 0) ? 1 : (CLK_FREQ / OUT_FREQ);

    function integer clog2;
        input integer value;
        integer i;
        begin
            clog2 = 0;
            for (i = value - 1; i > 0; i = i >> 1)
                clog2 = clog2 + 1;
        end
    endfunction

    localparam integer CW_RAW = clog2(COUNT_MAX);
    localparam integer CW     = (CW_RAW < 1) ? 1 : CW_RAW;

    reg [CW-1:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            counter <= {CW{1'b0}};
            tick    <= 1'b0;
        end else begin
            if (counter == (COUNT_MAX - 1)) begin
                counter <= {CW{1'b0}};
                tick    <= 1'b1;
            end else begin
                counter <= counter + {{(CW-1){1'b0}}, 1'b1};
                tick    <= 1'b0;
            end
        end
    end

endmodule
