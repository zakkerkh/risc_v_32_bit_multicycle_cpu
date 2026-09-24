module alu_ctrl(
    input wire [1:0] aluOp,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [3:0] aluCtrlOut
    );
    //according to how I defined the ALU OP CODES
    localparam [3:0]
    ADD_ALU_CODE = 4'd0, OR_ALU_CODE = 4'd1, SUB_ALU_CODE = 4'd2, AND_ALU_CODE = 4'd3, MUL_ALU_CODE = 4'd4;
    //according to defined RISC-V INSTRUCTION OP CODE
    localparam [1:0]
    LW_SW_CODE = 2'b00, BEQ_CODE = 2'b01, RT_CODE = 2'b10;
    always @ (*) begin 
        if(aluOp == LW_SW_CODE) aluCtrlOut = ADD_ALU_CODE;
        else if(aluOp == BEQ_CODE) aluCtrlOut = SUB_ALU_CODE;
        else if (aluOp == RT_CODE) begin
            case(funct3)
                3'b000:
                    if(funct7[0]) aluCtrlOut = MUL_ALU_CODE;
                    else if(funct7[5] == 0) aluCtrlOut = ADD_ALU_CODE; //funct7[5] is the bit that we care about
                    else aluCtrlOut = SUB_ALU_CODE;
                3'b111: aluCtrlOut = AND_ALU_CODE;
                3'b110: aluCtrlOut = OR_ALU_CODE;
                default: aluCtrlOut = ADD_ALU_CODE; //garbage value
            endcase
        end
        else aluCtrlOut = ADD_ALU_CODE; //garbage value
    end
endmodule
