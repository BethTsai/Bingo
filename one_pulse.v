module one_pulse(
    input wire clk,
    input wire pb_db,
    output wire pb_op
);

    reg pb_prev;
    always @(posedge clk) begin
        pb_prev <= pb_db;
    end
    assign pb_op = pb_db && !pb_prev;

endmodule