module alu(
    input wire [31:0] in_1,
    input wire [31:0] in_2,
    input wire [3:0] sel,
    output reg [31:0] out,
    output reg zero
    );
    parameter ADD = 4'd0, OR = 4'd1, SUB = 4'd2, AND = 4'd3, MUL = 4'd4; 
    always @ (*) begin
        case(sel)
        ADD: out = in_1 + in_2;
        OR: out = in_1 | in_2;
        SUB: out = in_1 - in_2;
        AND: out = in_1 & in_2;
        MUL: out = in_1 * in_2;
        default: out = in_1; // garbage value
        endcase
        zero = (out == 32'b0);
    end
endmodule
