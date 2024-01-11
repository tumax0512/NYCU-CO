module Decoder (
    instr_op_i,
    RegWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RegDst_o,
    Jump_o,
    Branch_o,
    BranchType_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o
);

  //I/O ports
  input [6-1:0] instr_op_i;
  input  [5:0] 	funct;
  output RegWrite_o;
  output [3-1:0] ALUOp_o;
  output ALUSrc_o;

  output RegDst_o;
  output Jump_o;
  output Branch_o;
  output BranchType_o;
  output MemRead_o;
  output MemWrite_o;
  output MemtoReg_o;

  //Internal Signals
  wire RegWrite_o;
  wire [3-1:0] ALUOp_o;
  wire ALUSrc_o;
  wire RegDst_o;
  wire Jump_o;
  wire Branch_o;
  wire BranchType_o;
  wire MemRead_o;
  wire MemWrite_o;
  wire MemtoReg_o;

  //Main function
  /*your code here*/
  
assign Branch_o = (instr_op_i==6'b011001);//beq

assign MemRead_o = (instr_op_i==6'b011000); //lw
assign MemWrite_o =(instr_op_i==6'b101000); //sw

assign RegWrite_o = ~((instr_op_i==6'b101000) | (instr_op_i==6'b001100) | (instr_op_i==6'b011001));// R-type, lw=1


assign MemtoReg_o = (instr_op_i==6'b011000) ;//lw 

 
assign BranchType_o = instr_op_i[4];

//  R-type: 000 ; beq: 010 ; lw/sw:001  addi: 011  ; 
assign ALUOp_o[2] = (instr_op_i==6'b010011)|((instr_op_i==6'b010100));//sub slt
assign ALUOp_o[1] = (instr_op_i==6'b011001) | (funct==6'b100011)| (instr_op_i==6'b010011);//beq add addi
assign ALUOp_o[0] = ~((instr_op_i==6'b000000) | (instr_op_i==6'b011001) );

assign ALUSrc_o = (instr_op_i==6'b011000) | (instr_op_i==6'b101000) | (instr_op_i==6'b010011) | (instr_op_i==6'b010100); //lw sw addi slt


assign RegDst_o = (instr_op_i==6'b000000); //R-type choose 1  ; I-type choose 0

assign Jump_o =(instr_op_i==6'b001100); // j : choose 1

endmodule
