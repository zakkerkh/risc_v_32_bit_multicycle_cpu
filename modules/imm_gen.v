module imm_gen(
    input wire [31:0] ir,
    output reg [31:0] imm
);
wire [6:0] opcode;
assign opcode = ir[6:0];
localparam R_TYPE = 7'b0110011, S_TYPE = 7'b0100011, I_TYPE = 7'b0000011, B_TYPE = 7'B1100011; //I_TYPE here only for load
always @ (*) begin
    case(opcode)
    I_TYPE: imm = {{20{ir[31]}}, ir[31:20]};
    S_TYPE: imm = {{20{ir[31]}}, ir[31:25], ir[11:7]};
    B_TYPE: imm = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
    default: imm = 32'b0; //garbage value
    endcase
end
endmodule
