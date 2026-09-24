module pc(
    input wire [31:0]in,
    input wire enable,
    output reg [31:0]out,
    input wire clk,
    input wire reset
);
    always @ (posedge clk) begin
        if(reset) out <= 32'd0;
        else if(enable) out <= in;
    end
endmodule
