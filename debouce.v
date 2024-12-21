module debounce #(
    parameter n = 16
)(
    input wire clk,
    input wire pb,
    output wire pb_db
);

    wire clk_n;
    clock_divider #(.n(n)) m1 (.clk(clk), .clk_div(clk_n));

    reg [3:0] shift_reg;
    always @(posedge clk_n) begin
        shift_reg <= {shift_reg[2:0], pb};
    end

    assign pb_db = &(shift_reg);
endmodule