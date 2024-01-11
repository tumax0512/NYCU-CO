module Sign_Extend (
    data_i,
    data_o
);

  //I/O ports
  input [16-1:0] data_i;

  output [32-1:0] data_o;

  //Internal Signals
  wire [32-1:0] data_o;

  //Sign extended
  /*your code here*/
assign data_o[15:0] = data_i[15:0];

genvar i;
generate
    for (i = 16; i < 32; i = i + 1)
    begin
        assign data_o[i] = data_i[15];
    end
endgenerate
endmodule
