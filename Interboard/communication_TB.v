module InterboardCommunication_TB(
    input wire clk,
    input wire rst,
    input wire ctrl_en,
    input wire [15:0] SW,
    input wire Request_in,
    input wire Ack_in,
    input wire [5:0] inter_data_in,

    output wire Request_out,
    output wire Ack_out,
    output wire [5:0] inter_data_out,
    output reg [15:0] LED
);

    wire interboard_rst, interboard_en;
    reg [15:0] led_next;
    wire interboard_move_dir;
    wire [2:0] interboard_msg_type;
    wire [4:0] interboard_number;
    wire inter_ready;

    wire clk_18;
    clock_divider #(.n(18)) m18(.clk(clk), .clk_div(clk_18));

    wire ctrl_en_db, ctrl_en_op;
    debounce db(.clk(clk), .pb(ctrl_en), .pb_db(ctrl_en_db));
    one_pulse op(.clk(clk), .pb_db(ctrl_en_db), .pb_op(ctrl_en_op));


    InterboardCommunication_top t(
        .clk(clk),
        .rst(rst),
        .transmit(SW[15]),
        .ctrl_en(ctrl_en_op),
        .ctrl_msg_type(SW[7:5]),
        .ctrl_number(SW[4:0]),
        .Request_in(Request_in),
        .Ack_in(Ack_in),
        .inter_data_in(inter_data_in),

        .inter_ready(inter_ready),
        .Request_out(Request_out),
        .Ack_out(Ack_out),
        .inter_data_out(inter_data_out),
        .interboard_rst(interboard_rst),
        .interboard_en(interboard_en),
        .interboard_msg_type(interboard_msg_type),
        .interboard_number(interboard_number)
    );

    always @(posedge clk, posedge rst, posedge interboard_rst) begin
        if(rst || interboard_rst) begin
            LED <= 16'h35ac;
        end
        else begin
            LED <= led_next;
        end
    end

    always@* begin
        led_next = LED;
        led_next[15] = inter_ready;
        if(interboard_en) begin
            led_next[7:5] = interboard_msg_type;
            led_next[4:0] = interboard_number;
        end
    end

endmodule
