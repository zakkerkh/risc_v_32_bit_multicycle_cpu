module reg_file(
    input wire [4:0]reg_num_1,
    input wire [4:0]reg_num_2,
    input wire [4:0]write_to_reg_num,
    input wire [31:0]write_data,
    output reg [31:0]A,
    output reg [31:0]B,
    input wire reg_write,
    input wire clk
    );
    reg [31:0]reg_file_arr[0:31]; //width height
    initial reg_file_arr[0] = 32'b0; //x0 is always 0
    always @ (posedge clk) begin
        if(reg_write & (write_to_reg_num != 0)) reg_file_arr[write_to_reg_num] <= write_data;
        A <= reg_file_arr[reg_num_1];
        B <= reg_file_arr[reg_num_2];
    end
endmodule
