`include "Program_Counter.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Mux2to1.v"
`include "Mux3to1.v"
`include "Reg_File.v"
`include "Decoder.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "Zero_Filled.v"
`include "ALU.v"
`include "Shifter.v"
`include "Data_Memory.v"
`include "Pipe_Reg.v"
module Pipeline_CPU (
    clk_i,
    rst_n
);
 //I/O port
  input clk_i; 
  input rst_n;
  // Internal Signels
wire [32-1:0] instr, pc_in, pc_out, ReadData1, ReadData2, WriteData;
wire [32-1:0] signextend, zerofilled, ALUinput2, ALUResult, ShifterResult;
wire [5-1:0] WriteReg_addr, Shifter_shamt;
wire [4-1:0] ALU_operation;
wire [2-1:0] ALUOP;
wire [2-1:0] FURslt;
wire RegDst, MemtoReg;
wire RegWrite, ALUSrc, zero, overflow;
wire Jump, Branch, BranchType, MemWrite, MemRead;
wire [32-1:0] PC_add1, PC_add2, PC_no_jump, PC_t, Mux3_result, DM_ReadData;

// modules
// IF
Mux2to1 #(.size(32)) Mux_branch(
    .data0_i(PC_add1),
    .data1_i(MEM_PC_add2),
    .select_i(MEM_Branch & MEM_zero),
    .data_o(pc_in)
    );

Program_Counter PC(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .pc_in_i(pc_in),
    .pc_out_o(pc_out)
    );

Adder Adder1( // next instruction
    .src1_i(pc_out), 
    .src2_i(32'd4),
    .sum_o(PC_add1)
    );

Instr_Memory IM(
    .pc_addr_i(pc_out),
    .instr_o(instr)
    );
  //Mux2to1 #(
  //    .size(32)
  //) Mux_jump (
  //    .data0_i (pc_no_jump),
  //    .data1_i ({pc_add[31:28], instr[25:0], 2'b00}),
  //    .select_i(Jump),
  //    .data_o  (pc_temp)
  //);

  //Mux2to1 #(
  //    .size(32)
  //) Mux_jr (
  //    .data0_i (pc_temp),
  //    .data1_i (RSdata),
  //    .select_i(JRsrc),
  //    .data_o  (pc_in)
  //);
// IF/ID
wire [32-1:0] ID_PC_add1, ID_instr;

Pipe_Reg #(.size(64)) IF_ID(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i({PC_add1, instr}),
    .data_o({ID_PC_add1, ID_instr})
    );
//
// ID
Decoder Decoder(
    .instr_op_i(ID_instr[31:26]),
    .RegWrite_o(RegWrite),
    .ALUOp_o(ALUOP),
    .ALUSrc_o(ALUSrc),
    .RegDst_o(RegDst),
    .Jump_o(Jump),
    .Branch_o(Branch),
    .BranchType_o(BranchType),
    .MemWrite_o(MemWrite),
    .MemRead_o(MemRead),
    .MemtoReg_o(MemtoReg)
    );
Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(ID_instr[25:21]),
      .RTaddr_i(ID_instr[20:16]),
      .RDaddr_i(WB_WriteReg_addr),
      .RDdata_i(WriteData),
      .RegWrite_i(WB_RegWrite),
      .RSdata_o(ReadData1),
      .RTdata_o(ReadData2)
  );


Sign_Extend SE(
    .data_i(ID_instr[15:0]),
    .data_o(signextend)
    );

// ID/EX
wire [32-1:0] EX_PC_add1, EX_signextend, EX_ReadData1, EX_ReadData2;
wire EX_ALUSrc, EX_Branch, EX_MemRead, EX_MemWrite, EX_RegWrite;
wire [2-1:0] EX_ALUOP;
wire [21-1:0] EX_instr_20_0; 
wire  EX_RegDst, EX_MemtoReg;

Pipe_Reg #(.size(158)) ID_EX(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i({ID_PC_add1, signextend, ReadData1, ReadData2, ALUSrc, Branch, MemRead, MemWrite, RegWrite, 
             MemtoReg, ALUOP, ID_instr[20:0], RegDst}),
    .data_o({EX_PC_add1, EX_signextend, EX_ReadData1, EX_ReadData2, EX_ALUSrc, EX_Branch, 
             EX_MemRead, EX_MemWrite, EX_RegWrite, EX_MemtoReg, EX_ALUOP, EX_instr_20_0, EX_RegDst})
    );
//
// EX	
Adder Adder2( // branch
    .src1_i(EX_PC_add1),
    .src2_i({EX_signextend[29:0], 2'b00}), // shift left 2
    .sum_o(PC_add2)
    );

Mux2to1 #(.size(32)) ALU_src2Src(
    .data0_i(EX_ReadData2),
    .data1_i(EX_signextend),
    .select_i(EX_ALUSrc),
    .data_o(ALUinput2)
    );

ALU_Ctrl AC(
    .funct_i(EX_signextend[5:0]),
    .ALUOp_i(EX_ALUOP),
    .ALU_operation_o(ALU_operation),
    .FURslt_o(FURslt)
    );

Mux2to1 #(.size(5)) Mux_Write_Reg(
    .data0_i(EX_instr_20_0[20:16]),
    .data1_i(EX_instr_20_0[15:11]),
    .select_i(EX_RegDst),
    .data_o(WriteReg_addr)
    );	

ALU ALU(
    .aluSrc1(EX_ReadData1),
    .aluSrc2(ALUinput2),
    .ALU_operation_i(ALU_operation),
    .result(ALUResult),
    .zero(zero),
    .overflow(overflow)
    );

// EX/MEM
wire [5-1:0] MEM_WriteReg_addr;
wire [32-1:0] MEM_PC_add2, MEM_ALUResult, MEM_ReadData2;
wire MEM_Branch, MEM_zero, MEM_MemWrite, MEM_RegWrite, MEM_MemRead,MEM_MemtoReg;


Pipe_Reg #(.size(107)) EX_MEM(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i({WriteReg_addr, PC_add2, ALUResult, EX_ReadData2, EX_Branch, zero, EX_MemWrite, EX_RegWrite, EX_MemRead, EX_MemtoReg}),
    .data_o({MEM_WriteReg_addr, MEM_PC_add2, MEM_ALUResult, MEM_ReadData2, MEM_Branch, 
             MEM_zero, MEM_MemWrite, MEM_RegWrite, MEM_MemRead, MEM_MemtoReg})
    );
//
// MEM
Data_Memory DM(
    .clk_i(clk_i),
    .addr_i(MEM_ALUResult),
    .data_i(MEM_ReadData2),
    .MemRead_i(MEM_MemRead),
    .MemWrite_i(MEM_MemWrite),
    .data_o(DM_ReadData)
    );

// MEM/WB
wire [5-1:0] WB_WriteReg_addr;
wire [32-1:0] WB_DM_ReadData, WB_ALUResult;
wire WB_RegWrite,WB_MemtoReg;


Pipe_Reg #(.size(71)) MEM_WB(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i({MEM_WriteReg_addr, DM_ReadData, MEM_ALUResult, MEM_RegWrite, MEM_MemtoReg}),
    .data_o({WB_WriteReg_addr, WB_DM_ReadData, WB_ALUResult, WB_RegWrite, WB_MemtoReg})
);
//
// WB
Mux2to1 #(.size(32)) Mux_Write( 
    .data0_i(WB_ALUResult),
    .data1_i(WB_DM_ReadData),
    .select_i(WB_MemtoReg),
    .data_o(WriteData)
    );

endmodule



