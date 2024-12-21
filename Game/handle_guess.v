module handle_guess(
    input wire clk,
    input wire rst,
    input wire interboard_rst,

    input wire [3:0] cur_game_state,
    input wire clear_guess,
    input wire start_guess,
    input wire [7:0] cur_number_BCD,
    input wire enter_pulse,

    output wire guess_done,
    output reg [25-1:0] circle
);

    localparam GAME_P1_GUESS = 4;
    localparam GAME_WAIT_UPDATE_GUESS = 10;

    localparam IDLE = 0;
    localparam WAIT_PLAYER_IN = 1;
    localparam FIN = 2;

    reg [25-1:0] circle_next;
    reg [1:0] cur_state, next_state;
    wire [6:0] cur_number = 10*cur_number_BCD[7:4] + cur_number[3:0];

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
            if(cur_game_state == GAME_WAIT_UPDATE_GUESS) begin

            end
            else if(cur_game_state == GAME_P1_GUESS && enter_pulse && 1 <= cur_number && cur_number <= 25 && circle[cur_number-1] == 0) begin

            end
            
            next_state = FIN;
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
        else if(cur_state == WAIT_PLAYER_IN && enter_pulse && 1 <= cur_number && cur_number <= 25 && circle[cur_number] == 0) begin
            circle_next[cur_number-1] = 1;
        end
    end


endmodule