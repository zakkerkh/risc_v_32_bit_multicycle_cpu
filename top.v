module top(
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] pc_debug,
    output wire [31:0] alu_out_debug,
    output wire [31:0] reg_file_A_debug,
    output wire [31:0] mem_data_out_debug,
    output wire        regWrite_debug
);
assign pc_debug          = pc_out;
assign alu_out_debug     = alu_out;
assign reg_file_A_debug  = reg_file_A;
assign mem_data_out_debug = mem_data_out;
assign regWrite_debug    = regWrite;
wire       pcWrite;
wire       pcWriteCond;
wire       IorD;
wire       mem_read;
wire       memWrite;
wire       memToReg;
wire       irWrite;
wire       pcSource;
wire       aluSrcA;
wire [1:0] aluSrcB;
wire [1:0] aluOp;
wire       regWrite;
wire   [31:0]pc_in,  pc_out,
         addr,  mem_data_in,  mem_data_out,   alu_out,
         ir,
         reg_file_write_data,  reg_file_A,  reg_file_B,
         imm;
wire    pc_enable, alu_zero;
wire    [6:0]opcode;
wire    [3:0] alu_sel;
wire    [4:0]rs1, rs2, rd;
reg [31:0] mem_data_reg_out;
reg [31:0] alu_in_1,  alu_in_2, alu_reg_out;
assign pc_enable = pcWrite | (pcWriteCond & alu_zero);
pc pc_1(
    .in(pc_in),
    .enable(pc_enable),
    .out(pc_out),
    .clk(clk),
    .reset(reset)
);
assign addr = IorD ? alu_reg_out : pc_out;
assign mem_data_in = reg_file_B;
mem mem_1(
    .addr(addr),
    .data_in(mem_data_in),
    .data_out(mem_data_out),
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(memWrite)
);
instruction_reg instruction_reg_1(
    .in(mem_data_out),
    .irWrite(irWrite),
    .opcode(opcode),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .ir(ir),
    .clk(clk)
); 
always @ (posedge clk) begin
    mem_data_reg_out <= mem_data_out;
end
main_ctrl ctrl_1(
    .op(opcode),
    .clk(clk),
    .reset(reset),
    .pcWrite(pcWrite),
    .pcWriteCond(pcWriteCond),
    .IorD(IorD),
    .memRead(mem_read),
    .memWrite(memWrite),
    .memToReg(memToReg),
    .irWrite(irWrite),
    .pcSource(pcSource),
    .aluSrcA(aluSrcA),
    .aluSrcB(aluSrcB),
    .aluOp(aluOp),
    .regWrite(regWrite)
);
assign reg_file_write_data = memToReg ? mem_data_reg_out : alu_reg_out;
reg_file reg_file_1(
    .reg_num_1(rs1),
    .reg_num_2(rs2),
    .write_to_reg_num(rd),
    .write_data(reg_file_write_data),
    .A(reg_file_A),
    .B(reg_file_B),
    .reg_write(regWrite),
    .clk(clk)
);
imm_gen imm_gen_1(
    .ir(ir),
    .imm(imm)
);
always @ (*) begin 
    case(aluSrcA)
        0: alu_in_1 = pc_out;
        1: alu_in_1 = reg_file_A;
    endcase
    case(aluSrcB)
    0: alu_in_2 = reg_file_B;
    1: alu_in_2 = 4;
    2: alu_in_2 = imm;
    default: alu_in_2 = 0; //garbage value
    endcase
end
alu alu_1(
    .in_1(alu_in_1),
    .in_2(alu_in_2),
    .sel(alu_sel),
    .out(alu_out),
    .zero(alu_zero)
);
alu_ctrl alu_ctrl_1(
    .aluOp(aluOp),
    .funct3(ir[14:12]),
    .funct7(ir[31:25]),
    .aluCtrlOut(alu_sel)
);
always @ (posedge clk) begin
    alu_reg_out <= alu_out;
end
assign pc_in = pcSource ? alu_reg_out : alu_out;
endmodule
