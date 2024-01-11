`include "Full_adder.v"
module ALU_1bit (
    a,
    b,
    invertA,
    invertB,
    operation,
    carryIn,
    less,
    result,
    carryOut
);

  //I/O ports
  input a;
  input b;
  input invertA;
  input invertB;
  input [2-1:0] operation;
  input carryIn;
  input less;
 
  output result;
  output carryOut;
  
  //Internal Signals
  wire result;
  wire carryOut;

  //Main function
  /*your code here*/
  wire a_val, b_val;
  wire or_val, and_val;
  wire temp1, temp2, sum;

  /*Operations*/
  xor a_invert(a_val, invertA, a);
  xor b_invert(b_val, invertB, b);
  and ANDgate(and_val, a_val, b_val);
  or ORgate(or_val, a_val, b_val);

  /*Adder*/
  xor AxorB(temp1, a_val, b_val);
  xor xorcin(sum, temp1, carryIn);
  and cout_step1(temp2, temp1, carryIn);
  or carryout(carryOut, temp2, and_val); //代表a b cin 110 101 011 時 cout為1

  assign result = (operation == 2'b00) ? or_val : //00 OR
                (operation == 2'b01) ? and_val :  //01 AND
                (operation == 2'b10) ? sum :       //10 SUM
                less;                              //11 SLT
endmodule
