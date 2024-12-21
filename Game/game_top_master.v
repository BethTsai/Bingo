module Game_Master(
    input wire clk,
    input wire rst,
    input wire interboard_rst,

    input wire start_game,
    input wire inter_ready,
    input wire [3:0] one_num,
    input wire enter_pulse,

    output wire [5*25-1:0] map,
    output wire [25-1:0] circle,
    output wire [12-1:0] line
);

    localparam IDLE = 0;
    localparam SEND_START = 1;
    localparam P1_SEL = 2;
    localparam WAIT_P2_SEL = 3;
    localparam P1_GUESS = 4;
    localparam P1_CHECK_WIN = 5;
    localparam SEND_GUESS = 6;
    localparam WAIT_P2_GUESS = 7;
    localparam FIN = 8;


endmodule