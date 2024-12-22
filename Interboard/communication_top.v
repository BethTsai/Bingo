module InterboardCommunication_top(
    input wire clk,
    input wire rst,
    input wire transmit,                       // from game control, indicate it is this board's turn to transmit 
    input wire Request_in,
    input wire Ack_in,
    input wire [5:0] inter_data_in,
    input wire ctrl_en,                        // one-pulse signal from GameControl indicating there is data to send
    input wire [2:0] ctrl_msg_type,
    input wire [4:0] ctrl_number,
    
    output wire inter_ready,
    output wire Request_out,
    output wire Ack_out,
    output wire [5:0] inter_data_out,
    output wire interboard_rst,                // rst called from other board
    output wire interboard_en,                 // should be one-pulse
    output wire [2:0] interboard_msg_type,
    output wire [4:0] interboard_number
);

    // How interboard reset works: 
    // 1. this board -> other board
    //      1.1 immediately reset this board's sending and receiving module (rst siganl)
    //      1.2 send reset signal to other board by setting all output to 1
    //      1.3 wait 10 cycles then reset communication_top (delayed_rst signal)
    // 2. other board -> this board
    //      2.1 immediately reset all the modules, including communication_top, sending and receiving

    // Handle sending reset to other board


    // raw data that need to send, haven't consider rst_other
    wire ack_out_raw, request_out_raw;
    wire [5:0] inter_data_out_raw;
    wire interboard_en_raw;

    wire delayed_rst;
    delay_n_cycle #(.n(10)) delay_rst(
        .clk(clk),
        .in(rst),
        .out(delayed_rst)
    );

    reg rst_other, rst_other_next;
    always@* begin
        rst_other_next = rst_other;
        if(rst) begin
            rst_other_next = 1;
        end
    end

    always@(posedge clk) begin
        if(delayed_rst || interboard_rst) begin
            rst_other <= 0;
        end
        else begin
            rst_other <= rst_other_next;
        end
    end

    // Handle reset called by other board
    assign interboard_rst = ({Ack_in, Request_in, inter_data_in} == 8'hff);
    assign inter_data_out = rst_other ? 6'hff : (transmit ? inter_data_out_raw : 6'b0);
    assign Ack_out =        rst_other ? 1'b1  : (transmit ? 1'b0 : ack_out_raw);
    assign Request_out =    rst_other ? 1'b1  : (transmit ? request_out_raw : 1'b0);
    assign interboard_en =  transmit  ? 1'b0  : interboard_en_raw;

    send_all sa (
        .clk(clk),
        .rst(rst),
        .interboard_rst(interboard_rst),
        
        // ack from other board
        .Ack_in(Ack_in),

        // data from Game
        .ctrl_en(ctrl_en),
        .ctrl_msg_type(ctrl_msg_type),
        .ctrl_number(ctrl_number),

        // data to other board
        .inter_ready(inter_ready),
        .Request_out(request_out_raw),
        .inter_data_out(inter_data_out_raw)
    );

    receive_all ra (
        .clk(clk),
        .rst(rst),
        .interboard_rst(interboard_rst),
        
        // data from other board
        .Request_in(Request_in),
        .inter_data_in(inter_data_in),
        
        // ack to other board
        .Ack_out(ack_out_raw),
        
        // data to Game
        .interboard_en(interboard_en_raw),
        .interboard_msg_type(interboard_msg_type),
        .interboard_number(interboard_number)
    );

    // wire request_in, request_out;
    // wire ack_in, ack_out;
    // wire [5:0] data_in, data_out;

    // Data out
    // interboard rst will be triggered if transmit is switcted
    // assign Ack = rst_other ? 1 : (transmit ? 1'bz : ack_out);
    // assign Request = rst_other ? 1 : (transmit ? request_out : 1'bz);
    // assign interboard_data = rst_other ? 1 : (transmit ? data_out : 6'bzz_zzzz);

    // Data in
    // assign ack_in = transmit ? Ack : 1'bz;
    // assign request_in = transmit ? 1'bz : Request;
    // assign data_in = transmit ? 6'bzz_zzzz : interboard_data;

    // assign ack_in = Ack;                    // ack_in = transmit ? 1'bz(1'b0) : Ack;
    // assign request_in = Request;            // request_in = transmit ? 1'bz : Request;
    // assign data_in = interboard_data;       // data_in = transmit ? 6'bz : interboard_data;


    // ila_0 ila_inst_0(clk, Request_in, Ack_out, ra.cur_state, ra.sr.cur_state);
    // ila_1 ila_inst_1(clk, Ack_in, sa.cur_state, inter_data_out);


endmodule



