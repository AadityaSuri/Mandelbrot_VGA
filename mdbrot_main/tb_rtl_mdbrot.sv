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

    localparam SF = 2.0**-20.0;

    mdbrot_top_level_single_nozoom DUT(clk, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_R, VGA_G, VGA_B,
             VGA_HS, VGA_VS, VGA_CLK, VGA_X, VGA_Y, VGA_COLOUR, VGA_PLOT);

    task val_display;
        input [31:0] val;
    begin
        if (val[31]) 
            $display("-%f\n", $itor(val[30:0]*SF));
        else
            $display("%f\n", $itor(val[30:0]*SF));
    end
    endtask

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
        // KEY[3] = 1'b0;

        @(posedge clk) begin
            $display("x: ");
            val_display(DUT.mandelbrot.x);

            $display("y: ");
            val_display(DUT.mandelbrot.y);
            
        end
        
        // @(posedge LEDR[9]);
        // $stop();
    end
endmodule: tb_rtl_mdbrot

