module clock_divider #(
    parameter n = 4
)(
    input wire clk,
    output wire clk_div
);

    reg [n-1:0] counter;

    always @(posedge clk) begin
        counter <= counter + 1;
    end

    assign clk_div = counter[n-1];

endmodule