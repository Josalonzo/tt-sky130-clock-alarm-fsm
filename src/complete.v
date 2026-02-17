/*
 * Copyright (c) 2024 Jose Alonzo
 * SPDX-License-Identifier: Apache-2.0
 */
`timescale 1ns / 1ps

module tt_um_josalonzo_clockalarm #(
    parameter integer INIT_HOUR  = 0,
    parameter integer INIT_MIN   = 00,
    parameter integer ALARM_HOUR = 7,
    parameter integer ALARM_MIN  = 30,

    //50 MHz 
    parameter integer CLK_FREQ   = 50_000_000,
    parameter integer OUT_FREQ   = 1,


    parameter integer USE_POR    = 0,
    parameter integer POR_BITS   = 24
)(
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       clk,
    input  wire       rst_n
);

    // -------------------------
    // Mapeo de botones
    // -------------------------
    // ui_in[0] = reset button
    // ui_in[1] = silence alarm button
    wire btnC = ui_in[0];
    wire btnU = ui_in[1];

    // Reset interno activo alto:
    // TinyTapeout da rst_n:
    wire rst_from_tt = ~rst_n;

    // -------------------------
    // Reset final del diseño
    // -------------------------
    wire rst;
    wire por_rst;

    reg  [POR_BITS-1:0] por_cnt;

    generate
        if (USE_POR != 0) begin : GEN_POR
            always @(posedge clk) begin
                if (por_cnt != {POR_BITS{1'b1}})
                    por_cnt <= por_cnt + {{(POR_BITS-1){1'b0}}, 1'b1};
            end
            assign por_rst = (por_cnt != {POR_BITS{1'b1}});
        end else begin : GEN_NO_POR
            assign por_rst = 1'b0;
        end
    endgenerate

    // Reset = reset externo (rst_n) OR botón
    assign rst = rst_from_tt | por_rst | btnC;

    // -------------------------
    // Tick
    // -------------------------
    wire tick_1hz;

    clck_psc #(
        .CLK_FREQ(CLK_FREQ),
        .OUT_FREQ(OUT_FREQ)
    ) u_tick (
        .clk (clk),
        .rst (rst),
        .tick(tick_1hz)
    );

    // LED segundos
    reg led_sec;
    always @(posedge clk) begin
        if (rst)
            led_sec <= 1'b0;
        else if (tick_1hz)
            led_sec <= ~led_sec;
    end

    // -------------------------
    // Time
    // -------------------------
    wire [4:0] hour;
    wire [5:0] min;

    wire [3:0] Ht, Hu, Mt, Mu;

    time_mod #(
        .INIT_HOUR(INIT_HOUR),
        .INIT_MIN (INIT_MIN)
    ) u_time (
        .clk      (clk),
        .rst      (rst),
        .tick_1hz (tick_1hz),
        .hour     (hour),
        .min      (min),
        .Ht       (Ht),
        .Hu       (Hu),
        .Mt       (Mt),
        .Mu       (Mu)
    );

    // -------------------------
    // Alarm compare + FSM
    // -------------------------
    wire H_pulse;
    wire alarm_on;
    wire [1:0] fsm_state;

    compare #(
        .ALARM_HOUR(ALARM_HOUR),
        .ALARM_MIN (ALARM_MIN)
    ) u_cmp (
        .clk (clk),
        .rst (rst),
        .hour(hour),
        .min (min),
        .H   (H_pulse)
    );

    alarm_fsm u_fsm (
        .clk   (clk),
        .rst   (rst),
        .H     (H_pulse),
        .B     (btnU),
        .A     (alarm_on),
        .state (fsm_state)
    );

    // -------------------------
    // Salidas TinyTapeout
    // -------------------------
    // uo_out[0] = LED alarma
    // uo_out[1] = LED segundos
    assign uo_out[0] = alarm_on;
    assign uo_out[1] = led_sec;
    assign uo_out[7:2] = 6'b0;

    // No usamos IO bidireccional
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
