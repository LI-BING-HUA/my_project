module Marquee (
    input clk,
    reset,
    output [3:0] led
);
  localparam A = 0, B = 1, C = 2, D = 3;
  reg [25:0] cnt;
  reg [1:0] state, next_state;
  wire pass;

  assign pass = cnt == 26'd25000000;

  always @(posedge clk or posedge reset) begin
    if (reset) state <= A;
    else state <= next_state;
  end

  always @(*) begin
    case (state)
      A: begin
        if (pass) next_state = B;
        else next_state = A;
      end
      B: begin
        if (pass) next_state = C;
        else next_state = B;
      end
      C: begin
        if (pass) next_state = D;
        else next_state = C;
      end
      D: begin
        if (pass) next_state = A;
        else next_state = D;
      end
      default next_state = A;
    endcase
  end

  always @(posedge clk or posedge reset) begin
    if (reset) cnt <= 1'b0;
    else if (pass) cnt <= 1'b0;
    else cnt <= cnt + 1'b1;
  end

  assign led[0] = state == A;
  assign led[1] = state == B;
  assign led[2] = state == C;
  assign led[3] = state == D;
endmodule
