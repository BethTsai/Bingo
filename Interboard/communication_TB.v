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
    wire [4:0] interboard_block_x;
    wire [2:0] interboard_block_y;
    wire [3:0] interboard_msg_type;
    wire [5:0] interboard_card;
    wire [2:0] interboard_sel_len;

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
        .ctrl_move_dir(SW[14]),
        .ctrl_block_x(SW[13:10]),
        .ctrl_block_y(SW[9:7]),
        .ctrl_msg_type(SW[6:3]),
        .ctrl_card(0),
        .ctrl_sel_len(SW[2:0]),
        .Request_in(Request_in),
        .Ack_in(Ack_in),
        .inter_data_in(inter_data_in),


        .Request_out(Request_out),
        .Ack_out(Ack_out),
        .inter_data_out(inter_data_out),
        .interboard_rst(interboard_rst),
        .interboard_en(interboard_en),
        .interboard_move_dir(interboard_move_dir),
        .interboard_block_x(interboard_block_x),
        .interboard_block_y(interboard_block_y),
        .interboard_msg_type(interboard_msg_type),
        .interboard_card(interboard_card),
        .interboard_sel_len(interboard_sel_len)
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
        if(interboard_en) begin
            led_next[14] = interboard_move_dir;
            led_next[13:10] = interboard_block_x;
            led_next[9:7] = interboard_block_y;
            led_next[6:3] = interboard_msg_type;
            led_next[2:0] = interboard_sel_len;
        end
    end

endmodule
