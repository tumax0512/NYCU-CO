`include "ALU_1bit.v"
module ALU (
    aluSrc1,
    aluSrc2,
    invertA,
    invertB,
    operation,
    result,
    zero,
    overflow
);

  //I/O ports
  input wire [32-1:0] aluSrc1;
  input wire [32-1:0] aluSrc2;
  input wire invertA;
  input wire invertB;
  input wire [2-1:0] operation;

  output wire [32-1:0] result;
  output wire zero;
  output wire overflow;

  //Internal Signals
  //wire[32-1:0] result;
  //wire zero;
  //wire overflow;
  
  //Main function
  /*your code here*/
    wire [31:0] w_result;
  	wire w_cout;
  	wire zero_;
  	wire [31:0] carry_val;
  	wire set;
	wire w0_cin;
  	wire w_overflow;
	wire last_sum, last_c;
	
	
  	assign zero_ = 1'b0;
  	assign w0_cin = ((invertB==1&&operation==2'b10) || operation==2'b11) ? 1:0;
	ALU_1bit a0(.a(aluSrc1[0]), .b(aluSrc2[0]), .invertA(invertA), .invertB(invertB), .operation(operation), .carryIn(w0_cin),.less(set),
	.result(w_result[0]), .carryOut(carry_val[0]));
	
	genvar idx;
	generate
	for (idx = 1; idx <= 31; idx = idx + 1)
	begin
		ALU_1bit a1(.a(aluSrc1[idx]), .b(aluSrc2[idx]), .invertA(invertA), .invertB(invertB), .operation(operation), .carryIn(carry_val[idx-1]),.less(zero_),
	.result(w_result[idx]), .carryOut(carry_val[idx]));   //alu 1~31 input for slt 設為0
	end
	endgenerate

  	xor (overflow, carry_val[31], carry_val[30]); //只有在a b cin cout組合為1101 與0010時 會發生overflow  ，在第32bit的alu做cin與cout的xor判斷
	
	Full_adder a2(.sum(last_sum), .carryOut(last_c), .carryIn(carry_val[30]), .input1(aluSrc1[31]), .input2(aluSrc2[31]));
	assign set = (overflow==1'b1) ? (last_sum) : (last_sum) ? 1'b0 : 1'b1;

	assign result = w_result;
	assign zero=(result==32'b0)?1:0;


endmodule
