/*
    All digital PoR
    Mohamed Shalan (mshalan@aucegypt.edu)
*/

`timescale 1ns/1ps
`default_nettype none

// Enable the following only to simulate
`define VERIFY

module shift #(parameter LENGTH=16)
(
    input clk,
    input in,
    input [LENGTH-1:0] cmp,
    output out
);

    reg [LENGTH-1:0] shift_reg;

    always @(posedge clk)
        shift_reg <= {in, shift_reg[LENGTH-1:1]};

    assign out = (shift_reg == cmp);

endmodule

module ADPOR #(parameter LENGTH=16)
(
    input clk,
    output rst_n
);
    wire cmp1, cmp2, cmp3, cmp4;
    shift reg1 (.clk(clk), .in(1'b1), .cmp({LENGTH{1'b1}}), .out(cmp1));
    shift reg2 (.clk(clk), .in(1'b0), .cmp({LENGTH{1'b0}}), .out(cmp2));
    shift reg3 (.clk(clk), .in(1'b1), .cmp({LENGTH{1'b1}}), .out(cmp3));
    shift reg4 (.clk(clk), .in(1'b0), .cmp({LENGTH{1'b0}}), .out(cmp4));
    
    assign rst_n = cmp1 & cmp2 & cmp3 & cmp4;

endmodule


`ifdef VERIFY
module ADPOR_tb;
    reg clk;
    wire rst_n;

    always #5 clk = !clk;

    ADPOR MUV (.clk(clk), .rst_n(rst_n));

    initial begin
        $dumpfile("adpor.vcd");
        $dumpvars;
        clk = 0;
        // load shift registers with random data to simulate the power on behavior 
        force MUV.reg1.shift_reg = $urandom & 12'hFFF;
        force MUV.reg2.shift_reg = $urandom & 12'hFFF;
        force MUV.reg3.shift_reg = $urandom & 12'hFFF;
        force MUV.reg4.shift_reg = $urandom & 12'hFFF;
        #1;
        release MUV.reg1.shift_reg;
        release MUV.reg2.shift_reg;
        release MUV.reg3.shift_reg;
        release MUV.reg4.shift_reg;

        # 500 $finish;
    end
endmodule
`endif
