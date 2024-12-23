`include "../message_macro.v"
`include "slave_game_macro.v"

module Game_Slave(
    input wire clk,
    input wire rst, 
    input wire interboard_rst, 

    input wire [7:0] cur_number_BCD,
    input wire enter_pulse,

    input wire inter_ready,
    input wire interboard_en,
    input wire [2:0] interboard_msg_type,
    input wire [4:0] interboard_number,

    output wire my_turn,
    output reg transmit,
    output reg ctrl_en,
    output reg [2:0] ctrl_msg_type,
    output reg [4:0] ctrl_number,

    output wire [5*25-1:0] map,
    output wire [25-1:0] circle
);

    reg [3:0] cur_state, next_state;
    wire [4:0] cur_number = 10*cur_number_BCD[7:4] + cur_number_BCD[3:0];

    wire clear_sel;
    reg start_sel;
    reg start_guess;
    reg clear_guess;

    // output of handle_select
    wire sel_done;
    wire [5*25-1:0] num_to_pos;

    // output of handle_guess
    wire guess_done;

    // output of check_win
    wire i_win;

    always @(posedge clk) begin
        if(rst || interboard_rst) begin
            cur_state <= `GAME_IDLE;
        end
        else begin
            cur_state <= next_state;
        end
    end

    assign clear_sel = (cur_state == `GAME_IDLE);
    assign my_turn = (cur_state == `GAME_P2_SEL || 
                      cur_state == `GAME_P2_GUESS ||
                      cur_state == `GAME_FIN);

    always @(*) begin
        next_state = cur_state;
        if(cur_state == `GAME_IDLE && interboard_en && interboard_msg_type == `STATE_TURN) begin
            next_state = `GAME_WAIT_P1_SEL;
        end
        else if(cur_state == `GAME_WAIT_P1_SEL && interboard_en && interboard_msg_type == `STATE_TURN) begin
            next_state = `GAME_P2_SEL;
        end
        else if(cur_state == `GAME_P2_SEL && sel_done) begin
            next_state = `GAME_SEND_START;
        end
        else if(cur_state == `GAME_SEND_START && inter_ready) begin
            next_state = `GAME_WAIT_P1_GUESS;
        end
        else if(cur_state == `GAME_WAIT_P1_GUESS) begin
            if(interboard_en && interboard_msg_type == `SEL_NUM) begin
                next_state = `GAME_WAIT_UPDATE_GUESS;
            end
            else if(interboard_en && interboard_msg_type == `STATE_WIN) begin
                next_state = `GAME_FIN;
            end
        end
        else if(cur_state == `GAME_WAIT_UPDATE_GUESS && guess_done) begin
            next_state = `GAME_P2_GUESS;
        end
        else if(cur_state == `GAME_P2_GUESS) begin
            if(guess_done) begin
                next_state = `GAME_P2_CHECK_WIN;
            end
            else if(i_win) begin
                next_state = `GAME_SEND_WIN;
            end
        end
        else if(cur_state == `GAME_P2_CHECK_WIN) begin
            if(i_win) begin
                next_state = `GAME_SEND_WIN;
            end
            else begin
                next_state = `GAME_SEND_SEL;
            end
        end
        else if(cur_state == `GAME_SEND_SEL && inter_ready) begin
            next_state = `GAME_WAIT_P1_GUESS;
        end
        else if(cur_state == `GAME_SEND_WIN && inter_ready) begin
            next_state = `GAME_FIN;
        end
        else if(cur_state == `GAME_FIN && interboard_en && interboard_msg_type == `STATE_TURN) begin
            next_state = `GAME_IDLE;
        end
    end

    always@* begin
        if(cur_state == `GAME_P2_SEL && sel_done) begin
            ctrl_en = 1;
        end
        else if(cur_state == `GAME_P2_GUESS && i_win) begin
            ctrl_en = 1;
        end
        else if(cur_state == `GAME_P2_CHECK_WIN) begin
            ctrl_en = 1;
        end
        else begin
            ctrl_en = 0;
        end
    end

    always@* begin
        if(cur_state == `GAME_WAIT_P1_SEL && interboard_en && interboard_msg_type == `STATE_TURN) begin
            start_sel = 1;
        end 
        else begin
            start_sel = 0;
        end
    end

    always@* begin
        if(cur_state == `GAME_FIN && interboard_en && interboard_msg_type == `STATE_TURN) begin
            clear_guess = 1;
        end
        else begin
            clear_guess = 0;
        end
    end

    always@* begin
        if(cur_state == `GAME_SEND_START && inter_ready) begin
            start_guess = 1;
        end
        else if(cur_state == `GAME_P2_GUESS) begin
            start_guess = 1;
        end
        else if(cur_state == `GAME_SEND_SEL && inter_ready) begin
            start_guess = 1;
        end
        else begin
            start_guess = 0;
        end
    end

    always@* begin
        ctrl_number = cur_number;
    end

    always@* begin
        case(cur_state) 
            `GAME_P2_SEL: ctrl_msg_type = `STATE_TURN;
            `GAME_P2_GUESS: ctrl_msg_type = `STATE_WIN;
            `GAME_P2_CHECK_WIN: ctrl_msg_type = i_win ? `STATE_WIN : `SEL_NUM;
            default: ctrl_msg_type = 3'hf;
        endcase
    end

    always@* begin
        case(cur_state) 
            `GAME_P2_SEL: transmit = 1;
            `GAME_SEND_START: transmit = 1;
            `GAME_P2_GUESS: transmit = 1;
            `GAME_P2_CHECK_WIN: transmit = 1;
            `GAME_SEND_WIN: transmit = 1;
            `GAME_SEND_SEL: transmit = 1;
            default: transmit = 0;
        endcase
    end

    handle_select handle_select_inst(
        .clk(clk),
        .rst(rst),
        .interboard_rst(interboard_rst),

        .clear_sel(clear_sel),
        .start_sel(start_sel),
        .cur_number_BCD(cur_number_BCD),
        .enter_pulse(enter_pulse),

        .sel_done(sel_done),
        .map(map),
        .num_to_pos(num_to_pos)
    );

    handle_guess_slave handle_guess_inst(
        .clk(clk),
        .rst(rst),
        .interboard_rst(interboard_rst),

		.interboard_en(interboard_en),
		.interboard_msg_type(interboard_msg_type),
		.interboard_number(interboard_number),
        .cur_game_state(cur_state),
        .clear_guess(clear_guess),
        .start_guess(start_guess),
        .cur_number_BCD(cur_number_BCD),
        .enter_pulse(enter_pulse),
        .num_to_pos(num_to_pos),

        .guess_done(guess_done),
        .circle(circle)
    );

    check_win check_win_inst(
        .circle(circle),
        .i_win(i_win)
    );

endmodule