`timescale 1 ps / 1 ps

module tb_rtl_mdbrot();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
    logic clk;
    logic [3:0] KEY;
    logic [9:0] SW, LEDR;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [7:0] VGA_R, VGA_G, VGA_B, VGA_X;
    logic [6:0] VGA_Y;
    logic VGA_HS, VGA_VS, VGA_CLK;
    logic [2:0] VGA_COLOUR;
    logic VGA_PLOT;

    mdbrot_top_level_single_nozoom DUT(clk, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_R, VGA_G, VGA_B,
             VGA_HS, VGA_VS, VGA_CLK, VGA_X, VGA_Y, VGA_COLOUR, VGA_PLOT);

    initial forever begin
        clk = 1'b1; #5;
        clk = 1'b0; #5;
    end

    initial begin
        //reset
        // KEY[3] = 1'b1; #10;
        // KEY[3] = 1'b0; #10;
        // KEY[3] = 1'b1; 

        // @(posedge LEDR[9]);
        // #5000;
        //reset
        KEY[3] = 1'b1; #10;
        KEY[3] = 1'b0; #10;
        KEY[3] = 1'b1; #10;
        KEY[3] = 1'b0;
        
        // @(posedge LEDR[9]);
        // $stop();
    end
endmodule: tb_rtl_mdbrot

