module instruction_reg(
    input wire [31:0]in,
    input wire irWrite,
    output reg [6:0]opcode,
    output reg [4:0]rs1,
    output reg [4:0]rs2,
    output reg [4:0]rd,
    output reg [31:0]ir,
    input wire clk
);
always @ (posedge clk) begin
    if(irWrite) ir <= in;
end
always @ (*) begin
    opcode = ir[6:0];
    rs1 = ir[19:15];
    rs2 = ir[24:20];
    rd = ir[11:7];
end
endmodule
