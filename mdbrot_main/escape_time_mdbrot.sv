`define start 2'd0
`define pixel_on 2'd1
`define calc_loop 2'd2
`define done 2'd3

module escape_time_mdbrot(input logic clk, input logic rst, input start, 
                          input logic [12:0] max_iter, input logic [19:0] xmin, input logic [19:0] xmax, input logic [19:0] ymin, input logic [19:0] ymax, input logic [19:0] Xscale, input logic [19:0] Yscale,
                          output logic [7:0] vga_x, output logic [6:0] vga_y, output logic [2:0] vga_colour, output logic vga_plot);

logic signed [7:0] x;
logic signed [6:0] y;
logic [1:0] pstate;

//     logic signed [32:0] xtemp;
//     logic signed [32:0] xm;
//     logic signed [32:0] ym;
//     logic signed [32:0] xs;
//     logic signed [32:0] ys;
logic [12:0] iter;



qmult xtimesXscale(x, Xscale, x_scaled1);
qmult ytimesYscale(y, Yscale, y_scaled1);
qadd xscaled(x_scaled1, -xmin, x_scaled);
qadd yscaled(y_scaled1m -ymin, y_scaled);

qmult xm2(xm, xm, xm2);
qmult ym2(ym, ym, ym2);
qadd xm2plusym2(xm2, ym2, xm2_ym2_sum);

qadd xt1(xm2, -ym2, xtemp1); //set signed bit for ym2
qadd xt2(xtemp1, x_scaled, xtemp);

qmult xm_mult_ym(xm, ym, xm_ym);
2_xm_ym = xm_ym << 1;
qadd 2_xm_ym_plus_



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
                              // xm = 9'd0;
                              // ym = 8'd0;
                              iter = 13'd0;
                              pstate <= `calc_loop;
                         end else 
                              pstate <= `done;
               end

               `calc_loop: begin
                    if ((xm*xm + ym*ym <= 3'd4) && iter < max_iter) begin
                    xtemp = xm*xm - ym*ym + xs;
                    ym = 2*xm*ym + ys;
                    xm = xtemp;
                    iter = iter + 13'd1;
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
                         vga_colour = iter == max_iter ? 3'd0 : iter % 8; //colour function
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

