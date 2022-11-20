`define start 2'd0
`define pixel_on 2'd1
`define calc_loop 2'd2
`define done 2'd3

module escape_time_mdbrot(input logic clk, input logic rst, input start, input logic [12:0] max_iter,
                          output logic [7:0] vga_x, output logic [6:0] vga_y, output logic [2:0] vga_colour, output logic vga_plot);
    logic [7:0] x;
    logic [6:0] y;
    logic [1:0] pstate;

    logic [7:0] xtemp;
    logic [8:0] xm;
    logic [7:0] ym;
    logic [12:0] iter;

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
                              xm = 9'd0;
                              ym = 8'd0;
                              iter = 13'd0;
                              pstate <= `calc_loop;
                         end else 
                              pstate <= `done;
                end

                `calc_loop: begin
                    if ((xm*xm + ym*ym <= 3'd4) && iter < max_iter) begin
                        xtemp = xm*xm - ym*ym + x;
                        ym = 2*xm*ym + y;
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

