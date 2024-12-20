module send_all(
    input wire clk,
    input wire rst,                     // reset called by this board
    input wire interboard_rst,          // reset called by other board
    input wire Ack_in,
    input wire ctrl_en,                 // one-pulse signal from GameControl indicating there is data to send
    input wire [3:0] ctrl_msg_type,
    input wire [4:0] ctrl_block_x,
    input wire [2:0] ctrl_block_y,
    input wire [5:0] ctrl_card,
    input wire [2:0] ctrl_sel_len,
    input wire ctrl_move_dir,
    
    output wire inter_ready,
    output wire Request_out,
    output wire [5:0] inter_data_out
);

    // Transmission state
    localparam INIT = 0;
    localparam STEP_1 = 1; // msg_type
    localparam STEP_2 = 2; // block_x 
    localparam STEP_3 = 3; // block_y
    localparam STEP_4 = 4; // card
    localparam STEP_5 = 5; // sel_len
    localparam STEP_6 = 6; // move_dir


    reg [2:0] cur_state, next_state;
    reg en_send, en_send_next;                  // indicate whether to send data to other board, one-pulse
    // reg interboard_rst, interboard_rst_next;    // used to indicate single_send should send interboard_rst to other board, 
                                                // always true after rst is asserted
    wire bottom_ready;                                 // from single_send, indicate whether the transmission is done and ready for next round
    reg [5:0] cur_data, next_data;              // data to send to other board corresponding to each state

    reg [3:0] stored_msg_type, stored_msg_type_next;
    reg [4:0] stored_block_x, stored_block_x_next;
    reg [2:0] stored_block_y, stored_block_y_next;
    reg [5:0] stored_card, stored_card_next;
    reg [2:0] stored_sel_len, stored_sel_len_next;
    reg stored_move_dir, stored_move_dir_next;



    send_single ss(
        .clk(clk),
        .rst(rst),
        .interboard_rst(interboard_rst),
        .en_send(en_send),
        .Ack_in(Ack_in),
        .data_in(cur_data),

        .ready(bottom_ready),
        .Request_out(Request_out),
        .inter_data_out(inter_data_out)
    );

    assign inter_ready = (cur_state == INIT);

    always@(posedge clk) begin
        if(rst || interboard_rst) begin
            cur_state <= INIT;
            cur_data <= 0;
            en_send <= 0;
            
            // interboard_rst <= 0;
            stored_msg_type <= 0;
            stored_block_x <= 0;
            stored_block_y <= 0;
            stored_card <= 0;
            stored_sel_len <= 0;
            stored_move_dir <= 0;
        end
        else begin
            cur_state <= next_state;
            cur_data <= next_data;
            en_send <= en_send_next;

            // interboard_rst <= interboard_rst_next;
            stored_msg_type <= stored_msg_type_next;
            stored_block_x <= stored_block_x_next;
            stored_block_y <= stored_block_y_next;
            stored_card <= stored_card_next;
            stored_sel_len <= stored_sel_len_next;
            stored_move_dir <= stored_move_dir_next;
        end
    end

    always@* begin
        en_send_next = en_send;
        if(en_send) begin
            en_send_next = 0;
        end
        else if(cur_state == INIT && ctrl_en ||
                cur_state == STEP_1 && bottom_ready ||
                cur_state == STEP_2 && bottom_ready ||
                cur_state == STEP_3 && bottom_ready ||
                cur_state == STEP_4 && bottom_ready ||
                cur_state == STEP_5 && bottom_ready) begin
            en_send_next = 1;
        end
    end

    always@* begin
        next_state = cur_state;
        if(cur_state == INIT && ctrl_en && !en_send) begin // since ready will be pulled down one cycle after en_send is pulled up
            next_state = STEP_1;                           // and state will be changed at the same time as en_send
        end                                                // this try to prevent state transit early because ready is not pulled down in time
        else if(cur_state == STEP_1 && bottom_ready && !en_send) begin
            next_state = STEP_2;
        end
        else if(cur_state == STEP_2 && bottom_ready && !en_send) begin
            next_state = STEP_3;
        end
        else if(cur_state == STEP_3 && bottom_ready && !en_send) begin
            next_state = STEP_4;
        end
        else if(cur_state == STEP_4 && bottom_ready && !en_send) begin
            next_state = STEP_5;
        end
        else if(cur_state == STEP_5 && bottom_ready && !en_send) begin
            next_state = STEP_6;
        end
        else if(cur_state == STEP_6 && bottom_ready && !en_send) begin
            next_state = INIT;
        end
    end

    always@* begin                      // prepare the data need to be send in next cycle
        next_data = cur_data;
        if(cur_state == INIT) begin
            next_data = ctrl_msg_type;
        end
        else if(cur_state == STEP_1) begin
            next_data = ctrl_block_x;
        end
        else if(cur_state == STEP_2) begin
            next_data = ctrl_block_y;
        end
        else if(cur_state == STEP_3) begin
            next_data = ctrl_card;
        end
        else if(cur_state == STEP_4) begin
            next_data = ctrl_sel_len;
        end
        else if(cur_state == STEP_5) begin
            next_data = ctrl_move_dir;
        end
    end

    // always@* begin
    // wire delayed_rst;                           // delayed rst signal, used to reset the machine after 
                                                // the interboard_rst is transmitted to other board
    
    // Used to store data to be sent, passed from GameControl
    // reg [3:0] stored_msg_type, stored_msg_type_next;
    // reg [4:0] stored_block_x, stored_block_x_next;
    // reg [2:0] stored_block_y, stored_block_y_next;
    // reg [5:0] stored_card, stored_card_next;
    // reg [2:0] stored_sel_len, stored_sel_len_next;
    // reg stored_move_dir, stored_move_dir_next;


    // delay_n_cycle #(.n(10)) delay_rst(
    //     .clk(clk),
    //     .in(rst),
    //     .out(delayed_rst)
    // );
    //     next_data = cur_data;
    //     if(cur_state == STEP_1) begin
    //         next_data = ctrl_msg_type;
    //     end
    //     else if(cur_state == STEP_2) begin
    //         next_data = ctrl_block_x;
    //     end
    //     else if(cur_state == STEP_3) begin
    //         next_data = ctrl_block_y;
    //     end
    //     else if(cur_state == STEP_4) begin
    //         next_data = ctrl_card;
    //     end
    //     else if(cur_state == STEP_5) begin
    //         next_data = ctrl_sel_len;
    //     end
    //     else if(cur_state == STEP_6) begin
    //         next_data = ctrl_move_dir;
    //     end
    // end

    // always @(*) begin
    //     interboard_rst_next = interboard_rst;
    //     if(rst) begin
    //         interboard_rst_next = 1;
    //     end
    // end

    always@* begin
        stored_msg_type_next = stored_msg_type;
        stored_block_x_next = stored_block_x;
        stored_block_y_next = stored_block_y;
        stored_card_next = stored_card;
        stored_sel_len_next = stored_sel_len;
        stored_move_dir_next = stored_move_dir;
        if(cur_state == INIT && ctrl_en) begin
            stored_msg_type_next = ctrl_msg_type;
            stored_block_x_next = ctrl_block_x;
            stored_block_y_next = ctrl_block_y;
            stored_card_next = ctrl_card;
            stored_sel_len_next = ctrl_sel_len;
            stored_move_dir_next = ctrl_move_dir;
        end
    end

    // ila_1 ila_inst(clk, en_send, Ack, cur_data, bottom_ready, Request, interboard_data, cur_state, ctrl_en);

endmodule



module send_single(
    input wire clk,
    input wire rst, 
    input wire interboard_rst,          // from upper layer, indicate whether to send global rst to other board 
    input wire en_send,                 // from upper layer, indicate there is data to transmit, one-pulse
    input wire Ack_in,                     // from other board
    input wire [5:0] data_in,           // from upper layer, the data to transmit to other board

    output wire ready,                  // to upper layer, indicate this round of transmission is done and ready for next round
    output reg Request_out,                 // to other board
    output wire [5:0] inter_data_out   // to other board
);
    localparam WAIT_EN = 0;
    localparam WAIT_ACK_UP = 1;
    localparam WAIT_ACK_DOWN = 2;

    reg [1:0] cur_state, next_state;
    reg [5:0] data_out, data_out_next;

    always@(posedge clk) begin
        if(rst || interboard_rst) begin
            cur_state <= WAIT_EN;
            data_out <= 0;
        end
        else begin
            cur_state <= next_state;
            data_out <= data_out_next;
        end
    end

    assign ready = cur_state == WAIT_EN;

    always @(*) begin
        next_state = cur_state;
        if(cur_state == WAIT_EN && en_send) begin
            next_state = WAIT_ACK_UP; 
        end
        else if(cur_state == WAIT_ACK_UP && Ack_in) begin
            next_state = WAIT_ACK_DOWN;
        end
        else if(cur_state == WAIT_ACK_DOWN && !Ack_in) begin
            next_state = WAIT_EN;
        end
    end

    always@* begin
        if(cur_state == WAIT_EN || cur_state == WAIT_ACK_DOWN) begin
            Request_out = 0;
        end
        else begin
            Request_out = 1;
        end
    end

    always@(*) begin
        data_out_next = data_out;
        if(interboard_rst) begin
            data_out_next = 6'b11_1111;
        end
        else if(en_send) begin
            data_out_next = data_in;
        end
    end

    assign inter_data_out = data_out;

endmodule

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
