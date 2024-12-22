`include "../message_macro.v"

module Game_Master(
    input wire clk,
    input wire rst,
    input wire interboard_rst,

    input wire start_game,
    input wire [7:0] cur_number_BCD,
    input wire enter_pulse,

    input wire inter_ready,
    input wire interboard_en,
    input wire [2:0] interboard_msg_type,
    input wire [4:0] interboard_number,

    output reg transmit,
    output reg ctrl_en,
    output reg [2:0] ctrl_msg_type,
    output reg [4:0] ctrl_number,

    output wire [5*25-1:0] map,
    output wire [25-1:0] circle
    // output wire [12-1:0] line
);

    localparam IDLE = 0;
    localparam SEND_START = 1;
    localparam P1_SEL = 2;
    localparam WAIT_P2_SEL = 3;
    localparam P1_GUESS = 4;
    localparam P1_CHECK_WIN = 5;
    localparam SEND_GUESS = 6;
    localparam WAIT_P2_GUESS = 7;
    localparam SEND_I_WIN = 8;
    localparam SEND_SEL = 9;
    localparam WAIT_UPDATE_GUESS = 10;
    localparam FIN = 11;

    reg [3:0] cur_state, next_state;
    // reg [24:0] used_number, used_number_next;
    wire [4:0] cur_number = 10*cur_number_BCD[7:4] + cur_number_BCD[3:0];

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
            cur_state <= IDLE;
            // used_number <= 0;
        end
        else begin
            cur_state <= next_state;
            // used_number <= used_number_next;
        end
    end

    always@* begin
        next_state = cur_state;
        if(cur_state == IDLE && start_game) begin
            next_state = SEND_START;
        end
        else if(cur_state == SEND_START && inter_ready) begin
            next_state = P1_SEL;
        end
        else if(cur_state == P1_SEL && sel_done) begin
            next_state = WAIT_P2_SEL;
        end
        else if(cur_state == WAIT_P2_SEL && interboard_en && interboard_msg_type == `STATE_TURN) begin
            next_state = P1_GUESS;
        end
        else if(cur_state == P1_GUESS && guess_done) begin
            if(guess_done) begin
                next_state = P1_CHECK_WIN;
            end
            else if(i_win) begin
                next_state =  SEND_I_WIN;
            end
        end
        else if(cur_state == P1_CHECK_WIN && i_win) begin
            if(i_win) begin
                next_state = SEND_I_WIN;
            end
            else if(!i_win) begin
                next_state = SEND_SEL;
            end
        end
        else if(cur_state == SEND_SEL && inter_ready) begin
            next_state = WAIT_P2_GUESS;
        end
        else if(cur_state == SEND_I_WIN && inter_ready) begin
            next_state = FIN;
        end
        else if(cur_state == WAIT_P2_GUESS && interboard_en && interboard_msg_type == `STATE_WIN) begin
            if(interboard_msg_type == `STATE_WIN) begin
                next_state = FIN;
            end
            else if(interboard_msg_type == `SEL_NUM) begin
                next_state = WAIT_UPDATE_GUESS;
            end
        end
        else if(cur_state == WAIT_UPDATE_GUESS && guess_done) begin
            next_state = P1_GUESS;
        end
        else if(cur_state == FIN && start_game) begin
            next_state = IDLE;
        end
    end


    always@* begin
        if(cur_state == IDLE && start_game) begin
            ctrl_en = 1;
        end
        else if(cur_state == P1_GUESS && i_win) begin
            ctrl_en = 1;
        end
        else if(cur_state == P1_CHECK_WIN) begin
            ctrl_en = 1;
        end
        else if(cur_state == FIN && start_game) begin
            ctrl_en = 1;
        end
        else begin
            ctrl_en = 0;
        end
    end

    always@* begin
        if(cur_state == SEND_START && inter_ready) begin
            start_sel = 1;
        end
        else begin
            start_sel = 0;
        end
    end

    always@* begin
        if(cur_state == FIN && start_game) begin
            clear_guess = 1;
        end
        else begin
            clear_guess = 0;
        end
    end

    always@* begin
        if(cur_state == WAIT_P2_SEL && interboard_en && interboard_msg_type == `STATE_TURN) begin
            start_guess = 1;
        end
        else if(cur_state == SEND_SEL && inter_ready) begin
            start_guess = 1;
        end
        else if(cur_state == WAIT_UPDATE_GUESS && guess_done) begin
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
        case (cur_state) 
            IDLE: ctrl_msg_type = `STATE_TURN;
            P1_SEL: ctrl_msg_type = `STATE_TURN;
            P1_CHECK_WIN: ctrl_msg_type = i_win ? `STATE_WIN : `SEL_NUM;
            P1_GUESS: ctrl_msg_type = `STATE_WIN;
            FIN: ctrl_msg_type = `STATE_TURN;
            default: ctrl_msg_type = 3'hf;
        endcase
    end

    always@* begin
        case(cur_state) 
            IDLE: transmit = 1;
            SEND_START: transmit = 1;
            P1_SEL: transmit = 1;
            P1_GUESS: transmit = 1;
            P1_CHECK_WIN: transmit = 1;
            SEND_SEL: transmit = 1;
            SEND_I_WIN: transmit = 1;
            // WAIT_UPDATE_GUESS: transmit = 1;
            FIN: transmit = 1;
            default: transmit = 0;
        endcase
    end

    handle_select handle_select_inst(
        .clk(clk),
        .rst(rst),
        .interboard_rst(interboard_rst),

        .start_sel(start_sel),
        .cur_number_BCD(cur_number_BCD),
        .enter_pulse(enter_pulse),
        
        .sel_done(sel_done),
        .map(map),
        .num_to_pos(num_to_pos)
    );

    handle_guess_master handle_guess_inst(
        .clk(clk),
        .rst(rst),
        .interboard_rst(interboard_rst),

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