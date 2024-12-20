module button_preprocess(
    input wire clk,
    input wire signal_in,
    output wire signal_out
);

    wire db;
    debounce db1(.clk(clk), .pb(signal_in), .pb_db(db));
    one_pulse op(.clk(clk), .pb_db(db), .pb_op(signal_out));

endmodule