module FA(A, B, Cin, G, P, S);
input A, B, Cin;
output G, P, S;

xor(S, A, B, Cin);

assign G = A & B;
assign P = A | B;

endmodule