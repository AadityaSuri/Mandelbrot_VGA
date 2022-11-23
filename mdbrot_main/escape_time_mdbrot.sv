`define start 2'd0
`define pixel_on 2'd1
`define calc_loop 2'd2
`define done 2'd3

module escape_time_mdbrot(input logic clk, input logic rst, input start, 
                          input logic [12:0] max_iter, input logic [31:0] xmin, input logic [31:0] xmax, input logic [31:0] ymin, input logic [31:0] ymax, input logic [31:0] Xscale, input logic [31:0] Yscale,
                          output logic [7:0] vga_x, output logic [6:0] vga_y, output logic [2:0] vga_colour, output logic vga_plot);

localparam MAXBITS = 32;
localparam FPBITS = 14;


logic signed [MAXBITS - 1:0] four = 32'b0000_0000_0000_0001_0000_0000_0000_0000;
logic signed [MAXBITS - 1:0] x;
logic signed [MAXBITS - 1:0] y;
logic [1:0] pstate;

//     logic signed [32:0] xtemp;
//     logic signed [32:0] xm;
//     logic signed [32:0] ym;
//     logic signed [32:0] xs;
//     logic signed [32:0] ys;
logic [14:0] iter;
logic signed [MAXBITS - 1:0] xm;
logic signed [MAXBITS - 1:0] ym;


// calculates the scaled values of X and Y coordinates, xscaled, yscaled
logic signed [MAXBITS - 1:0] x_scaled1, yscaled1, x_scaled, y_scaled;
qmult #(FPBITS, MAXBITS) x_mult_xscale_mod(x, Xscale, x_scaled1);
qmult #(FPBITS, MAXBITS) y_mult_yscale_mod(y, Yscale, y_scaled1);
qadd #(FPBITS, MAXBITS) xscaled_mod(x_scaled1, {1'b1, xmin[30:0]}, x_scaled);
qadd #(FPBITS, MAXBITS) yscaled_mod(y_scaled1, {1'b1, ymin[30:0]}, y_scaled);

// calculates xm^2 + ym^2
logic signed [MAXBITS - 1:0] xm2, ym2, xm2_plus_ym2, zero_check;
qmult #(FPBITS, MAXBITS) xm2_mod(xm, xm, xm2);
qmult #(FPBITS, MAXBITS) ym2_mod(ym, ym, ym2);
qadd #(FPBITS, MAXBITS) xm2_plus_m2_mod(xm2, ym2, xm2_plus_ym2);
qadd #(FPBITS, MAXBITS) sub_comp_mod(xm2_plus_ym2, {1'b1, four[30:0]}, zero_check);

// calculates xtemp = xm^2 - ym^2 + x_scaled
logic signed [MAXBITS - 1:0] xtemp1, xtemp;
qadd #(FPBITS, MAXBITS) xm2_sub_ym2_mod(xm2, {1'b1, ym2[30:0]}, xtemp1); //set signed bit for ym2
qadd #(FPBITS, MAXBITS) xtemp_mod(xtemp1, x_scaled, xtemp);

//calculates 2*xm*ym + yscaled
logic signed [MAXBITS - 1:0] xm_mult_ym, _2_xm_ym_plus_yscaled;
qmult #(FPBITS, MAXBITS) xm_mult_ym_mod(xm, ym, xm_mult_ym);
logic signed [31:0] _2_xm_ym = xm_mult_ym << 1;
qadd #(FPBITS, MAXBITS) _2_xm_ym_plus_yscaled_mod(_2_xm_ym, y_scaled, _2_xm_ym_plus_yscaled);


always @(posedge clk) begin
     if (!rst) 
          pstate <= `start;
     else 
          case (pstate)
               `start: begin
                    x = 8'd0;
                    y = 7'd0;
                    pstate <= start ? `pixel_on : `start;
               end

               `pixel_on: begin
                         if (x < 8'd160) begin// loop conditional
                              if (y < 7'd120) 
                                   y = y  + 7'd1;
                              else begin
                                   y = 7'd0;
                                   x = x + 8'd1;
                              end
                              // xs = x*Xscale - xmin;
                              // ys = y*Yscale - ymin;
                              xm = {32{1'b0}};
                              ym = {32{1'b0}};
                              iter = 14'd0;
                              pstate <= `calc_loop;
                         end else 
                              pstate <= `done;
               end

               `calc_loop: begin
                    if ((zero_check[31] == 1'b1) && iter < max_iter) begin
                    // xtemp = xm*xm - ym*ym + xs;
                    ym = _2_xm_ym_plus_yscaled;
                    xm = xtemp;
                    iter = iter + 14'd1;
                    pstate <= `calc_loop;
                    end else begin
                    pstate <= `pixel_on;
                    end
               end

               `done: begin
                    pstate <= `start;
               end

               default: pstate <= 2'bxx;

          endcase
end

always_comb begin
          case(pstate)
               `pixel_on: begin
                    if (x == 8'd160) begin
                         vga_x = 8'd0;
                         vga_y = 7'd0;
                         vga_colour = 3'd0;
                         vga_plot = 1'd0;
                    end else begin
                         vga_x = x;
                         vga_y = y;
                         vga_colour = iter == max_iter ? 3'd0 : iter % 14'd8; //colour function
                         vga_plot = 1'd1;
                    end

               end

               default: begin
                    vga_x = 8'd0;
                    vga_y = 7'd0;
                    vga_colour = 3'd0;
                    vga_plot = 1'd0;
               end
          endcase
     end

endmodule

