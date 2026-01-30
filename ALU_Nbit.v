//     BIT-SLICE  ALU
//     FOR N BIT

`timescale 1ps/1ps

// BIT BY BIT CALCULATION

module alu_1bit(input A, B,cin,
    input [1:0]op,output result,cout);

    reg result;
    wire sum;
    assign{cout,sum}=A+B+cin;

    always @(*) begin
        case (op)
        2'b00: result=A&B;
        2'b01: result=A|B;
        2'b10: result=sum;
        2'b11: result=A^B;
        default: result=1'b0;
        endcase    
    end
endmodule

// CREATING CHAIN   , CONNECTING THE CARRY GENERATED

module alu_4bit(
    input [3:0] A, B,
    input [1:0] op,
    output [3:0] result
);
parameter N = 4;               // number of bits.

wire [N+1:0] carry;
assign carry[0] = 0;           // INITIAL CARRY

genvar i;                      // TEMPORARY PARAMETER 

generate
for(i=0; i<N; i=i+1) begin
    alu_1bit u(
        A[i],
        B[i],
        carry[i],
        op,
        result[i],
        carry[i+1]
    );
end
endgenerate

endmodule

// testbench
module tb_alu_2;
    reg [3:0] A,B;
    reg [1:0]op;
    wire [3:0] result;

    alu_4bit dut(.A(A), .B(B), .op(op), .result(result));

    initial begin
        A=4'b0011;B=4'b1100;#10;
        op=2'b00;#10;
        $display("and result=%b",result);
        op=2'b01;#10;
        $display("or result=%b",result);
        op=2'b10;#10;
        $display("sum result=%b",result);
        op=2'b11;#10;
        $display("xor result=%b",result);
    end
    
endmodule

