`timescale 1ns / 1ps

// Compara hora actual con hora de alarma
// Genera pulso H (1 ciclo) cuando coincide
module compare #(
    parameter integer ALARM_HOUR = 7,   // hora alarma
    parameter integer ALARM_MIN  = 30   // minuto alarma
)(
    input  wire       clk,
    input  wire       rst,

    input  wire [4:0] hour,   // 0..23
    input  wire [5:0] min,    // 0..59

    output reg        H       // pulso cuando coincide
);

    wire match_now;
    reg  match_prev;

    // Detecta coincidencia nivel
    assign match_now = (hour == ALARM_HOUR) && (min == ALARM_MIN);

    always @(posedge clk) begin
        if (rst) begin
            match_prev <= 1'b0;
            H          <= 1'b0;
        end else begin
            match_prev <= match_now;

            // Pulso de 1 ciclo cuando pasa de 0 -> 1
            H <= match_now & ~match_prev;
        end
    end

endmodule
