module multiplier (
    input  [3:0] A,
    input  [3:0] B,
    output [3:0] PI
);
    assign PI[0] = A[0] & B;
    assign PI[1] = A[1] & B;
    assign PI[2] = A[2] & B;
    assign PI[3] = A[3] & B;
endmodule
