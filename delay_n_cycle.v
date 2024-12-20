module delay_n_cycle #(
    parameter n = 10
)(
    input wire clk,
    input wire in,
    output wire out
);

    reg [n-1:0] shift_reg;
    always @(posedge clk) begin
        shift_reg <= {in, shift_reg[n-1:1]};
    end

    assign out = shift_reg[0];
endmodule
