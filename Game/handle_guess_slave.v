`include "../message_macro.v"
`include "slave_game_macro.v"

module handle_guess_slave(
    input wire clk,
    input wire rst,
    input wire interboard_rst,

    input wire interboard_en,
    input wire [2:0] interboard_msg_type,
    input wire [4:0] interboard_number,
    input wire [3:0] cur_game_state,
    input wire clear_guess,
    input wire start_guess,
    input wire [7:0] cur_number_BCD,
    input wire enter_pulse,
    input wire [5*25-1:0] num_to_pos,

    output wire guess_done,
    output reg [25-1:0] circle
);

    localparam IDLE = 0;
    localparam WAIT_PLAYER_IN = 1;
    localparam FIN = 2;

    reg [25-1:0] circle_next;
    reg [1:0] cur_state, next_state;
    wire [6:0] cur_number = 10*cur_number_BCD[7:4] + cur_number_BCD[3:0];

    always@(posedge clk) begin
        if(rst || interboard_rst) begin
            cur_state <= IDLE;
            circle <= 0;
        end
        else begin
            cur_state <= next_state;
            circle <= circle_next;
        end
    end

    assign guess_done = (cur_state == FIN);

    always@* begin
        next_state = cur_state;
        if(cur_state == IDLE && start_guess) begin
            next_state = WAIT_PLAYER_IN;
        end
        else if(cur_state == WAIT_PLAYER_IN) begin
            // if(cur_game_state == `GAME_WAIT_P1_GUESS && interboard_en && interboard_msg_type == `SEL_NUM) begin
            //     next_state = FIN;
            // end
            // else if(cur_game_state == `GAME_WAIT_P1_GUESS && interboard_en && interboard_msg_type == `STATE_WIN) begin
            //     next_state = IDLE;
            // end
            // else if(cur_game_state == `GAME_P2_GUESS && enter_pulse && 1 <= cur_number && cur_number <= 25 && circle[num_to_pos[cur_number*5-1 -: 5]] == 0) begin
            //     next_state = FIN;
            // end
            if(interboard_en && interboard_msg_type == `SEL_NUM) begin
                next_state = FIN;
            end
            else if(interboard_en && interboard_msg_type == `STATE_WIN) begin
                next_state = IDLE;
            end
            else if(cur_game_state == `GAME_P2_GUESS && enter_pulse && 1 <= cur_number && cur_number <= 25 && circle[num_to_pos[cur_number*5-1 -: 5]] == 0) begin
                next_state = FIN;
            end
            
        end
        else if(cur_state == FIN) begin
            next_state = IDLE;
        end
    end

    always @(*) begin
        circle_next = circle;
        if(clear_guess) begin
            circle_next = 0;
        end
        else if(cur_state == WAIT_PLAYER_IN && cur_game_state == `GAME_P2_GUESS && 
                enter_pulse && 1 <= cur_number && cur_number <= 25 && circle[num_to_pos[cur_number*5-1 -: 5]] == 0) begin
            circle_next[num_to_pos[cur_number*5-1 -: 5]] = 1;
        end
        else if(cur_state == WAIT_PLAYER_IN && cur_game_state == `GAME_WAIT_P1_GUESS && interboard_en && interboard_msg_type == `SEL_NUM) begin
            circle_next[num_to_pos[interboard_number*5-1 -: 5]] = 1;
        end

    end


endmodule