module handle_select(
    input wire clk,
    input wire rst,
    input wire interboard_rst,

    input wire start_sel,
    input wire [7:0] cur_number_BCD,
    input wire enter_pulse,

    output wire sel_done,
    output reg [25*5-1:0] map
);

    localparam IDLE = 0;
    localparam SEL = 1;
    localparam FIN = 2;

    reg [1:0] cur_state, next_state;
    reg [25-1:0] used_number, used_number_next;
    reg [4:0] cur_pos, next_pos;
    reg [25*5-1:0] map_next;
    
    wire [6:0] cur_number = 10*cur_number_BCD[7:4] + cur_number_BCD[3:0];
    wire all_used = &(used_number);

    always@(posedge clk) begin
        if(rst || interboard_rst) begin
            cur_state <= IDLE;
            used_number <= 0;
            cur_pos <= 0;
            map <= 0;
        end
        else begin
            cur_state <= next_state;
            used_number <= used_number_next;
            cur_pos <= next_pos;
            map <= map_next;
        end
    end

    assign sel_done = (cur_state == FIN);

    always@* begin
        next_state = cur_state;
        if(cur_state == IDLE && start_sel) begin
            next_state = SEL;
        end
        else if(cur_state == SEL && all_used) begin
            next_state = FIN;
        end
        else if(cur_state == FIN) begin
            next_state = IDLE;
        end
    end
    
    always@* begin
        used_number_next = used_number;
        next_pos = cur_pos;
        map_next = map;
        if(cur_state == IDLE && start_sel) begin
            used_number_next = 0;
            next_pos = 0;
            map_next = 0;
        end
        else if(cur_state == SEL && enter_pulse && 1 <= cur_number && cur_number <= 25 && used_number[cur_number-1] == 0) begin
            used_number_next[cur_number-1] = 1;
            next_pos = cur_pos+1;
            map_next[cur_pos*5-1 -: 5] = cur_number;
        end
    end


endmodule
