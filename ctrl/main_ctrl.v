module main_ctrl(
    input wire [6:0] op,
    input wire clk,
    input wire reset,
    output reg pcWriteCond,
    output reg pcWrite,
    output reg IorD, //IorD
    output reg memRead,
    output reg memWrite,
    output reg memToReg,
    output reg irWrite,
    output reg pcSource,
    output reg [1:0] aluOp,
    output reg [1:0] aluSrcB,
    output reg aluSrcA,
    output reg regWrite
);

localparam [3:0]
    FETCH = 0,
    DECODE = 1,
    MEM = 2,
        MEM_A1 = 3, MEM_A2 = 4,
        MEM_B = 5,
    R_1 = 6, R_2 = 7,
    BRANCH = 8,
    FETCH_W = 9,
    MEM_A_W = 10;
localparam [6:0]
    LW  = 7'b0000011,
    SW  = 7'b0100011,
    BEQ = 7'b1100011,
    RT  = 7'b0110011;
reg [3:0] current, next;
always @ (*) begin
    case(current)
    FETCH: next = FETCH_W;
    FETCH_W: next = DECODE;
    DECODE: begin
        if((op == LW) || (op == SW)) next = MEM;
        else if(op == RT) next = R_1;
        else if(op == BEQ) next = BRANCH;
        else next = FETCH; // erroneous state
    end
    MEM: begin
        if(op == LW) next = MEM_A1;
        else if(op == SW) next = MEM_B;
        else next = FETCH; // erroneous state
    end
    MEM_A1: next = MEM_A_W;
    MEM_A_W: next = MEM_A2;
    MEM_A2: next = FETCH;
    MEM_B: next = FETCH;
    R_1: next = R_2;
    R_2: next = FETCH;
    BRANCH: next = FETCH;
    default: next = FETCH;
    endcase
end
always @ (posedge clk) begin
    if(reset) current <= FETCH;
    else current <= next;
end
//FSM output signals
always @ (*) begin
    //sets default values
    memRead    = 0;
    memWrite   = 0;
    aluSrcA    = 0;
    aluSrcB    = 0;
    IorD       = 0;
    irWrite    = 0;
    aluOp      = 0;
    pcWrite    = 0;
    pcWriteCond = 0;
    pcSource   = 0;
    regWrite   = 0;
    memToReg   = 0;
    case(current)
    FETCH: begin
        memRead = 1;
        aluSrcB = 2'b01;
        pcWrite = 1;
    end
    FETCH_W: begin
        irWrite = 1; 
    end
    DECODE: begin
        aluSrcB = 2'b10;
    end
    MEM: begin
        aluSrcA = 1;
        aluSrcB = 2'b10;
    end
    MEM_A1: begin
        memRead = 1;
        IorD = 1;
    end
    MEM_A2: begin
        regWrite = 1;
        memToReg = 1;
        end
    MEM_B: begin
        memWrite = 1;
        IorD = 1;
    end
    R_1: begin
        aluSrcA = 1;
        aluOp = 2'b10;
    end
    R_2: begin
        regWrite = 1;
    end
    BRANCH: begin
        aluSrcA = 1;
        aluOp = 2'b01;
        pcWriteCond = 1;
        pcSource = 1;
    end
    endcase
end
endmodule
