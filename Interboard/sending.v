module send_all(
    input wire clk,
    input wire rst,                     // reset called by this board
    input wire interboard_rst,          // reset called by other board
    input wire Ack_in,
    input wire ctrl_en,                 // one-pulse signal from GameControl indicating there is data to send
    input wire [2:0] ctrl_msg_type,
    input wire [4:0] ctrl_number,
    
    output wire inter_ready,
    output wire Request_out,
    output wire [5:0] inter_data_out
);

    // Transmission state
    localparam INIT = 0;
    localparam STEP_1 = 1; // msg_type
    localparam STEP_2 = 2; // number


    reg [2:0] cur_state, next_state;
    reg en_send, en_send_next;                  // indicate whether to send data to other board, one-pulse
    // reg interboard_rst, interboard_rst_next;    // used to indicate single_send should send interboard_rst to other board, 
                                                // always true after rst is asserted
    wire bottom_done;
    wire bottom_ready;                                 // from single_send, indicate whether the transmission is done and ready for next round
    reg [5:0] data_to_bottom;

    reg [3:0] stored_msg_type, stored_msg_type_next;
    reg [4:0] stored_number, stored_number_next;

    always@(posedge clk) begin
        if(rst || interboard_rst) begin
            cur_state <= INIT;
            en_send <= 0;
            
            stored_msg_type <= 0;
            stored_number <= 0;
        end
        else begin
            cur_state <= next_state;
            en_send <= en_send_next;

            stored_msg_type <= stored_msg_type_next;
            stored_number <= stored_number_next;
        end
    end

    assign inter_ready = (cur_state == INIT);

    // en_send will be true at the first cycle of each transmission
    always@* begin
       en_send_next = 0;
       if(cur_state == INIT && ctrl_en) begin
           en_send_next = 1;
       end
       else if(bottom_done && cur_state != STEP_2) begin
           en_send_next = 1;
       end
    end

    always@* begin
        next_state = cur_state;
        if(cur_state == INIT && ctrl_en) begin
            next_state = STEP_1;
        end
        else if (bottom_done) begin
            case (cur_state)
                STEP_1:  next_state = STEP_2;
                STEP_2:  next_state = INIT;
                default: next_state = cur_state;
            endcase
        end
    end

    always@* begin
        case (cur_state) 
            STEP_1: data_to_bottom = stored_msg_type;
            STEP_2: data_to_bottom = stored_number;
            default: data_to_bottom = 0;
        endcase
    end

    // stored data will present one cycle later then ctrl_en 
    always@* begin
        stored_msg_type_next = stored_msg_type;
        stored_number_next = stored_number;
        if(cur_state == INIT && ctrl_en) begin
            stored_msg_type_next = ctrl_msg_type;
            stored_number_next = ctrl_number;
        end
    end

    send_single single_send_inst(
        .clk(clk),
        .rst(rst),
        .interboard_rst(interboard_rst),
        .en_send(en_send),
        .Ack_in(Ack_in),
        .data_in(data_to_bottom),

        .done(bottom_done),
        .ready(bottom_ready),
        .Request_out(Request_out),
        .inter_data_out(inter_data_out)
    );

    // ila_0 ila_inst(clk, cur_state, ctrl_en, en_send, stored_msg_type, single_send_inst.cur_state, Request_out, Ack_in, inter_data_out, bottom_done);

endmodule



module send_single(
    input wire clk,
    input wire rst, 
    input wire interboard_rst,          // from upper layer, indicate whether to send global rst to other board 
    input wire en_send,                 // from upper layer, indicate there is data to transmit, one-pulse
    input wire Ack_in,                     // from other board
    input wire [5:0] data_in,           // from upper layer, the data to transmit to other board

    output wire done,
    output wire ready,                  // to upper layer, indicate this round of transmission is done and ready for next round
    output reg Request_out,                 // to other board
    output wire [5:0] inter_data_out   // to other board
);
    localparam WAIT_EN = 0;
    localparam WAIT_ACK_UP = 1;
    localparam WAIT_ACK_DOWN = 2;
    localparam FIN = 3;

    reg [1:0] cur_state, next_state;
    reg [5:0] stored_data, stored_data_next;

    always@(posedge clk) begin
        if(rst || interboard_rst) begin
            cur_state <= WAIT_EN;
            stored_data <= 0;
        end
        else begin
            cur_state <= next_state;
            stored_data <= stored_data_next;
        end
    end

    assign ready = cur_state == WAIT_EN;
    assign done = cur_state == FIN;

    always @(*) begin
        next_state = cur_state;
        if(cur_state == WAIT_EN && en_send) begin
            next_state = WAIT_ACK_UP; 
        end
        else if(cur_state == WAIT_ACK_UP && Ack_in) begin
            next_state = WAIT_ACK_DOWN;
        end
        else if(cur_state == WAIT_ACK_DOWN && !Ack_in) begin
            next_state = FIN;
        end
        else if(cur_state == FIN) begin
            next_state = WAIT_EN;
        end
    end

    always@* begin
        if(cur_state == WAIT_ACK_UP) begin
            Request_out = 1;
        end
        else begin
            Request_out = 0;
        end
    end

    always@(*) begin
        stored_data_next = stored_data;
        if(en_send) begin
            stored_data_next = data_in;
        end
    end

    assign inter_data_out = stored_data;

endmodule

