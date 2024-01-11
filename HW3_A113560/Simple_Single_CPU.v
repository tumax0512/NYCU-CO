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
module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signles
wire [31:0] pc_in;
wire [31:0] pc_inst;
wire [31:0] instr_o;
wire [4:0] Write_reg;
wire RegDst;
wire RegWrite;
wire [2:0] ALUOp;
wire ALUSrc;
wire [31:0] rs_data;
wire [31:0] rt_data;
wire [3:0] ALUCtrl;
wire [1:0] FURslt;
wire [31:0] sign_instr;
wire [31:0] zero_instr;
wire [31:0] Src_ALU_Shifter;
wire zero;
wire [31:0] result_ALU;
wire [31:0] result_Shifter;
wire overflow;
wire [31:0] WB_Data;
wire [32-1:0] Mux3_result;
wire [32-1:0] pc_add4;
wire [32-1:0] pc;
//wire [32-1:0] pc_o;
// Instruction Memory
wire [32-1:0] instruction;

wire [32-1:0] Data_Memory_o;
// Register File
wire [5-1:0] writeRegister;
wire [32-1:0] rsData, rtData, writeData;

// Decoder
wire [3-1:0] ALUOP;

// Sign Extension
//wire [32-1:0] SE_instruction;

// Zero Filled
wire Zero;
//wire [32-1:0] zeroFilled;

// Shifter
//wire [32-1:0] shifter_result;

// ALU Control
//wire [4-1:0] ALU_operation;

wire MemRead;
wire MemWrite;
wire Branch;
wire Jump;
wire PCSrc;
// ALU
//wire [32-1:0] ALU_result;
wire  MemtoReg;
wire [32-1:0] MUX_ALUSrcA_o;

wire [32-1:0] Adder_PCReg_o;
//DP
wire [32-1:0] Imm_4 = 4;
  assign PCSrc = (Branch & Zero) | Jump;
  //modules
//modules
Program_Counter PC(
        .clk_i(clk_i),      
	.rst_n(rst_n),     
	.pc_in_i(pc_in),   
	.pc_out_o(pc_inst) 
        );
	
Adder Adder1(
        .src1_i(pc_inst),     
	.src2_i(32'd4),
	.sum_o(pc_in)    
	);
  
  Adder Adder2 (//Adder_PCReg
      .src1_i(MUX_ALUSrcA_o),
      .src2_i(sign_instr),
      .sum_o(Adder_PCReg_o)
  );



Instr_Memory IM(
        .pc_addr_i(pc_inst),  
	.instr_o(instr_o)    
	);

Mux2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr_o[20:16]),
        .data1_i(instr_o[15:11]),
        .select_i(RegDst),
        .data_o(Write_reg)
        );	

Reg_File RF(
        .clk_i(clk_i),      
	.rst_n(rst_n),     
        .RSaddr_i(instr_o[25:21]),  
        .RTaddr_i(instr_o[20:16]),  
        .RDaddr_i(Write_reg),  
        .RDdata_i(WB_Data), 
        .RegWrite_i(RegWrite),
        .RSdata_o(rs_data),  
        .RTdata_o(rt_data)   
        );
//Decoder Decoder(
//        .instr_op_i(instr_o[31:26]), 
//	.RegWrite_o(RegWrite), 
//	.ALUOp_o(ALUOp),   
//	.ALUSrc_o(ALUSrc),   
//	.RegDst_o(RegDst)   
//        );
  Decoder Decoder (
      .instr_op_i(instr_o[31:26]),
      .RegWrite_o(RegWrite),
      .ALUOp_o(ALUOP),
      .ALUSrc_o(ALUSrc),
      .RegDst_o(RegDst),
      .Jump_o(Jump),
      .Branch_o(Branch),
      .BranchType_o(BranchType),
      .MemRead_o(MemRead),
      .MemWrite_o(MemWrite),
      .MemtoReg_o(MemtoReg)
  );
ALU_Ctrl AC(
        .funct_i(instr_o[5:0]),   
        .ALUOp_i(ALUOp),   
        .ALU_operation_o(ALUCtrl),
	.FURslt_o(FURslt)
        );
 // ALU_Ctrl AC (
 //     .funct_i(instruction[5:0]),
 //     .ALUOp_i(ALUOP),
 //     .ALU_operation_o(ALU_operation),
 //     .FURslt_o(FURslt)
 //,.leftRight_o()
 // );

Sign_Extend SE(
        .data_i(instr_o[15:0]),
        .data_o(sign_instr)
        );

Zero_Filled ZF(
        .data_i(instr_o[15:0]),
        .data_o(zero_instr)
        );

Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(rt_data),
        .data1_i(sign_instr),
        .select_i(ALUSrc),
        .data_o(Src_ALU_Shifter)
        );	

ALU ALU(
	.aluSrc1(rs_data),
	.aluSrc2(Src_ALU_Shifter),
	.ALU_operation_i(ALUCtrl),
	.result(result_ALU),
	.zero(zero),
	.overflow(overflow)
	);

Shifter shifter( 
	.result(result_Shifter), 
	.leftRight(~instr_o[1]),
	.shamt(instr_o[10:6]),
	.sftSrc(Src_ALU_Shifter) 
	);
		
Mux3to1 #(.size(32)) RDdata_Source(
        .data0_i(result_ALU),
        .data1_i(result_Shifter),
	    .data2_i(zero_instr),
        .select_i(FURslt),
        .data_o(Mux3_result)
        );			

Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(Mux3_result),//writeData
      .data_i(rtData),
      .MemRead_i(MemRead),
      .MemWrite_i(MemWrite),
      .data_o(Data_Memory_o)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(Mux3_result),
      .data1_i(Data_Memory_o),
      .select_i(MemtoReg),
      .data_o(WB_Data)
  );
  
 Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i(pc_in),
      .data1_i(Adder_PCReg_o),
      .select_i(PCSrc),
      .data_o(pc)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jump (
      .data0_i (pc),
      .data1_i ({pc[31:28],instruction[27:2],2'b00}),
      .select_i(Jump),
      .data_o  (pc)
  );

endmodule



