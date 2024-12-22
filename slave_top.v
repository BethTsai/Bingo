module Slave_top (
    input wire clk,
    input wire rst,
    input wire btnR,
    
    inout wire PS2_DATA,
    inout wire PS2_CLK,

    input wire Request_in,
    input wire Ack_in,
    input wire [5:0] inter_data_in,

    output wire Request_out,
    output wire Ack_out,
    output wire [5:0] inter_data_out,

    output wire [3:0] DIGIT,
    output wire [6:0] DISPLAY,

    output wire hsync,
    output wire vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
);

    wire start_game;
    button_preprocess bp0(.clk(clk), .signal_in(btnR), .signal_out(start_game));

    // output of keyboard_handler
    wire enter_pulse;
    wire [3:0] one_num;
    wire [7:0] cur_number_BCD;

    // output of InterboardCommunication
    wire inter_ready;
    // wire Request_out;
    // wire Ack_out;
    // wire [5:0] inter_data_out;
    wire interboard_rst;
    wire interboard_en;
    wire [2:0] interboard_msg_type;
    wire [4:0] interboard_number;
    

    // output of game_master
    wire transmit;
    wire ctrl_en;
    wire [2:0] ctrl_msg_type;
    wire [4:0] ctrl_number;
    wire [5*25-1:0] map;
    wire [25-1:0] circle;
    
    Keyboard_Handler Keyboard_Handler_inst0 (
        .clk(clk),
        .rst(rst),
		.interboard_rst(interboard_rst),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .display_num(cur_number_BCD),
        .enter_pulse(enter_pulse)
    );

    Game_Slave Game_Slave_inst0 (
        .clk(clk),
        .rst(rst),
        .interboard_rst(interboard_rst),

        .cur_number_BCD(cur_number_BCD),
        .enter_pulse(enter_pulse),

        .inter_ready(inter_ready),
        .interboard_en(interboard_en),
        .interboard_msg_type(interboard_msg_type),
        .interboard_number(interboard_number),

        .transmit(transmit),
        .ctrl_en(ctrl_en),
        .ctrl_msg_type(ctrl_msg_type),
        .ctrl_number(ctrl_number),
        
        .map(map),
        .circle(circle)
    );

    Display_top Display_top_inst0 (
        .clk(clk),
        .rst(rst),
        .interboard_rst(interboard_rst),
        .display_nums(cur_number_BCD),
        .map(map),
        .circle(circle),

        .hsync(hsync),
        .vsync(vsync),
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue),
        .DISPLAY(DISPLAY),
        .DIGIT(DIGIT)
    );

    InterboardCommunication_top InterboardCommunication_top_inst0 (
        .clk(clk),
        .rst(rst),
        .transmit(transmit),
        .Request_in(Request_in),
        .Ack_in(Ack_in),
        .inter_data_in(inter_data_in),
        .ctrl_en(ctrl_en),
        .ctrl_msg_type(ctrl_msg_type),
        .ctrl_number(ctrl_number),

        .inter_ready(inter_ready),
        .Request_out(Request_out),
        .Ack_out(Ack_out),
        .inter_data_out(inter_data_out),
        .interboard_rst(interboard_rst),
        .interboard_en(interboard_en),
        .interboard_msg_type(interboard_msg_type),
        .interboard_number(interboard_number)
    );
    
    // ila_1 ila_inst(
    //     clk,
    //     // ctrl_en, // 1
    //     // ctrl_msg_type, // 3
    //     // ctrl_number, // 5
    //     interboard_en, // 1
    //     interboard_msg_type, // 3
    //     interboard_number, // 5
    //     Game_Slave_inst0.cur_state, // 4
    //     // Game_Slave_inst0.cur_number, // 5
    //     Game_Slave_inst0.start_sel, // 1
    //     Game_Slave_inst0.start_guess, // 1
    //     // Game_Slave_inst0.clear_guess, // 1
    //     Game_Slave_inst0.guess_done, // 1
    //     Game_Slave_inst0.sel_done, // 1
    //     // Game_Slave_inst0.i_win, // 1
    //     // Game_Slave_inst0.enter_pulse, // 1
    //     // Game_Slave_inst0.handle_select_inst.used_number, // 25
    //     // Game_Slave_inst0.handle_select_inst.cur_pos, // 5
    //     // transmit, // 1
    //     // Request_out, // 1
    //     // Ack_out, // 1
    //     // inter_data_out, // 6
    //     // Request_in, // 1
    //     // Ack_in, // 1
    //     // inter_data_in, // 6
	// 	Game_Slave_inst0.handle_guess_inst.cur_state // 2
    // );


endmodule