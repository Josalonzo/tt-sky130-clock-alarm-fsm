`timescale 1ns / 1ps

module alarm_fsm (
    input  wire       clk,
    input  wire       rst,         
    input  wire       H,           
    input  wire       B,           
    output reg        A,           
    output reg [1:0]  state  
);

    reg [1:0] next;

    // Registro de estado
    always @(posedge clk) begin
        if (rst)
            state <= 2'b00;     
        else
            state <= next;
    end

    // Lógica de siguiente estado
    always @(*) begin
        next = state; 

        case (state)

            // S00
            2'b00: begin
                if (H)
                    next = 2'b01;  
                else
                    next = 2'b00;  
            end

            // S01
            2'b01: begin
                if (B)
                    next = 2'b10;  
                else
                    next = 2'b01;  
            end

            // S10
            2'b10: begin
                next = 2'b00;
            end

            // Default (incluye 2'b11)
            default: begin
                next = 2'b00;
            end

        endcase
    end

    // Lógica de salida
    always @(*) begin
        case (state)
            2'b01: A = 1'b1; 
            default: A = 1'b0;
        endcase
    end

endmodule
