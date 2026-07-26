module Rainbow_Breathing_LED (
    input  clk,
    input  rst,
    output led_r, led_g, led_b
);
  reg [7:0] pwm_cnt, level, target_r, target_g, target_b;
  wire [7:0] duty_r, duty_g, duty_b;
  wire [15:0] prod_r, prod_g, prod_b;
  reg [19:0] slow_cnt;
  reg dir;
  reg [2:0] color;

  localparam Red = 3'd0, Orange = 3'd1, Yellow = 3'd2, Green = 3'd3, Blue = 3'd4, Purple = 3'd5, White = 3'd6;

  always @(posedge clk) begin
    if (rst) begin
      level <= 8'd0;
      slow_cnt <= 20'd0;
      dir <= 0;
      color <= Red;
    end else if (dir) begin
      if (slow_cnt == 20'd196_849) begin
        slow_cnt <= 20'd0;
        level <= level + 8'd1;
        if (level == 8'd254) begin
          dir <= ~dir;
        end
      end else begin
        slow_cnt <= slow_cnt + 20'd1;
      end
    end else begin
      if (slow_cnt == 20'd196_849) begin
        slow_cnt <= 20'd0;
        level <= level - 8'd1;
        if (level == 8'd1) begin
          dir   <= ~dir;
          color <= (color == White) ? Red : color + 1'd1;
        end
      end else begin
        slow_cnt <= slow_cnt + 20'd1;
      end
    end
  end

  always @(posedge clk) begin
    if (rst) pwm_cnt <= 8'd0;
    else pwm_cnt <= (pwm_cnt == 8'd255) ? 8'd0 : pwm_cnt + 8'd1;
  end

  assign led_r = pwm_cnt < duty_r;
  assign led_g = pwm_cnt < duty_g;
  assign led_b = pwm_cnt < duty_b;

  always @(*) begin
    case (color)
      Red: begin
        target_r = 8'd250;
        target_g = 8'd0;
        target_b = 8'd0;
      end
      Orange: begin
        target_r = 8'd250;
        target_g = 8'd128;
        target_b = 8'd0;
      end
      Yellow: begin
        target_r = 8'd255;
        target_g = 8'd255;
        target_b = 8'd0;
      end
      Green: begin
        target_r = 8'd0;
        target_g = 8'd255;
        target_b = 8'd0;
      end
      Blue: begin
        target_r = 8'd0;
        target_g = 8'd0;
        target_b = 8'd255;
      end
      Purple: begin
        target_r = 8'd255;
        target_g = 8'd0;
        target_b = 8'd255;
      end
      White: begin
        target_r = 8'd255;
        target_g = 8'd255;
        target_b = 8'd255;
      end
      default: begin
        target_r = 8'd255;
        target_g = 8'd255;
        target_b = 8'd255;
      end
    endcase
  end
  assign prod_r = target_r * level;
  assign prod_g = target_g * level;
  assign prod_b = target_b * level;
  assign duty_r = prod_r >> 8;
  assign duty_g = prod_g >> 8;
  assign duty_b = prod_b >> 8;
endmodule
