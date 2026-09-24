module mem(
    input wire [31:0] addr,
    input wire [31:0] data_in,
    output reg [31:0] data_out,
    input wire clk,
    input wire mem_read,
    input wire mem_write
    );
    reg [31:0]memory[0:1023]; 

    always @ (posedge clk) begin 
        if (mem_write)
            memory[addr[11:2]] <= data_in;
        if (mem_read)
            data_out <= memory[addr[11:2]];
    end
endmodule
