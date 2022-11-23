module mdbrot_top_level_single_nozoom(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    // instantiate and connect the VGA adapter and your module
    logic start, done, vga_plot, VGA_BLANK, VGA_SYNC;
    logic [2:0] colour;
    assign LEDR[9] = done;
    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    assign start = KEY[3];
    logic [12:0] max_iter = 13'd500;
    escape_time_mdbrot mandelbrot(CLOCK_50, KEY[3], start, max_iter, vga_x, vga_y, vga_colour, vga_plot);
    vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(KEY[3]), .clock(CLOCK_50), .colour(vga_colour),
                                            .x(vga_x), .y(vga_y), .plot(vga_plot),
                                            .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
                                            .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK), .VGA_SYNC(VGA_SYNC), .VGA_CLK(VGA_CLK));

    // logic [31:0] zoom = 
    always_comb begin
    end

endmodule: mdbrot_top_level_single_nozoom
