module ALU_Ctrl (
    funct_i,
    ALUOp_i,
    ALU_operation_o,
    FURslt_o,
	leftRight_o
);

  //I/O ports
  input [6-1:0] funct_i;
  input [3-1:0] ALUOp_i;

  output [4-1:0] ALU_operation_o;
  output [2-1:0] FURslt_o;
  output leftRight_o;

  //Internal Signals
  wire [4-1:0] ALU_operation_o;
  wire [2-1:0] FURslt_o;
  wire leftRight_o;
  reg        [4-1:0] ALUCtrl;
  //Main function
  /*your code here*/
//assign ALU_operation_o =(funct_i[5:0] == 6'b100011) ? 4'b0010 : //add 
//						(funct_i[5:0] == 6'b010011) ? 4'b0110 : //sub
//						(funct_i[5:0] == 6'b011111) ? 4'b0000 : //and
//						(ALUOp_i == 3'b001) ? 4'b0000 : //lw sw
//       				(funct_i[5:0] == 6'b101111) ? 4'b0001 : //or
//						(funct_i[5:0] == 6'b010000) ? 4'b1100 : //nor
//						(funct_i[5:0] == 6'b010100) ? 4'b0111 : //slt
//						(funct_i[5:0] == 6'b010010) ? 4'b0001 : //sll
//						(funct_i[5:0] == 6'b100010) ? 4'b0000 : //srl				
//						4'b0010; //addi
assign {ALU_operation_o, FURslt_o} = (ALUOp_i == 3'b000) ? {4'b0000, 2'b00} : // lw sw
                         (ALUOp_i == 3'b011) ? {4'b0010, 2'b00} : // addi
                         (ALUOp_i == 3'b001) ?  {4'b0110, 2'b00} : // beq
                         (ALUOp_i == 3'b110) ?  {4'b0110, 2'b00} : // bne
                         (ALUOp_i == 3'b010) ? ( // R-type
                            (funct_i == 6'b100011) ? {4'b0010, 2'b00} : // add
                            (funct_i == 6'b010011) ? {4'b0110, 2'b00} : // sub
                            (funct_i == 6'b011111) ? {4'b0001, 2'b00} : // and
                            (funct_i == 6'b101111) ? {4'b0000, 2'b00} : // or
                            (funct_i == 6'b010000) ? {4'b1101, 2'b00} : // nor
                            (funct_i == 6'b010100) ? {4'b0111, 2'b00} : // slt
                            (funct_i == 6'b010010) ? {4'b1000, 2'b01} : // sll
                            (funct_i == 6'b100010) ? {4'b0000, 2'b01} : 0// srl
                         ) : 0;
		
//assign FURslt_o[1:0] = (ALUOp_i == 3'b010 && (funct_i == 6'b010010 || funct_i == 6'b100010)) ? 2'b01 : 2'b00;
assign leftRight_o = (funct_i == 6'b010010)|(funct_i == 6'b100010) ? 2'b01 : 2'b00 ;
endmodule
