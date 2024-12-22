module Keyboard_Handler(
	input wire clk,
	input wire rst,
	input wire interboard_rst,
	inout wire PS2_DATA,
	inout wire PS2_CLK,

	output reg [7:0] display_num,
	output reg enter_pulse
);	
	wire key_valid;
	wire [8:0] last_change;
	wire [511:0] key_down;
	wire all_rst;
	assign all_rst = rst | interboard_rst;
	KeyboardDecoder KeyboardDecoder_inst0 (
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(key_valid),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);

	parameter ENTER_KEY = 9'h05a;
	parameter [8:0] KEY_CODES [0:19] = {
		9'b0_0100_0101,	// 0 => 45
		9'b0_0001_0110,	// 1 => 16
		9'b0_0001_1110,	// 2 => 1E
		9'b0_0010_0110,	// 3 => 26
		9'b0_0010_0101,	// 4 => 25
		9'b0_0010_1110,	// 5 => 2E
		9'b0_0011_0110,	// 6 => 36
		9'b0_0011_1101,	// 7 => 3D
		9'b0_0011_1110,	// 8 => 3E
		9'b0_0100_0110,	// 9 => 46
		
		9'b0_0111_0000, // right_0 => 70
		9'b0_0110_1001, // right_1 => 69
		9'b0_0111_0010, // right_2 => 72
		9'b0_0111_1010, // right_3 => 7A
		9'b0_0110_1011, // right_4 => 6B
		9'b0_0111_0011, // right_5 => 73
		9'b0_0111_0100, // right_6 => 74
		9'b0_0110_1100, // right_7 => 6C
		9'b0_0111_0101, // right_8 => 75
		9'b0_0111_1101  // right_9 => 7D
	};

	reg [3:0] key_num;
	reg [7:0] nums_next;
	reg one_pressed, one_pressed_next;
	reg [8:0] prev_pressed;

	always @(*) begin
		one_pressed_next = one_pressed;
		if(!one_pressed && key_valid && key_down[last_change] && key_num!= 4'b1111) begin
			one_pressed_next = 1;
		end else if(one_pressed && key_valid && !key_down[last_change] && last_change == prev_pressed) begin
			one_pressed_next = 0;
		end
	end
	always @(*) begin
		nums_next = display_num;
		if(!one_pressed && key_valid && key_down[last_change] && key_num <= 4'd9) begin
			nums_next = {display_num[3:0], key_num};
		end 
	end
	always @(*) begin
		enter_pulse = 0;
		if(!one_pressed && key_valid && key_down[last_change] && key_num == 4'd10) begin
			enter_pulse = 1;
		end
	end
	always @ (posedge clk) begin
		if (all_rst) begin
			one_pressed <= 9'b0;
			prev_pressed <= 9'b0;
			display_num <= 8'b0;
		end else begin
			if(!one_pressed && key_valid && key_down[last_change] && key_num!= 4'b1111) begin
				prev_pressed <= last_change;
			end else begin
				prev_pressed <= prev_pressed;
			end
			one_pressed <= one_pressed_next;
			display_num <= nums_next;
		end
	end

	always @ (*) begin
		case (last_change)
			KEY_CODES[00] : key_num = 4'b0000;
			KEY_CODES[01] : key_num = 4'b0001;
			KEY_CODES[02] : key_num = 4'b0010;
			KEY_CODES[03] : key_num = 4'b0011;
			KEY_CODES[04] : key_num = 4'b0100;
			KEY_CODES[05] : key_num = 4'b0101;
			KEY_CODES[06] : key_num = 4'b0110;
			KEY_CODES[07] : key_num = 4'b0111;
			KEY_CODES[08] : key_num = 4'b1000;
			KEY_CODES[09] : key_num = 4'b1001;
			KEY_CODES[10] : key_num = 4'b0000;
			KEY_CODES[11] : key_num = 4'b0001;
			KEY_CODES[12] : key_num = 4'b0010;
			KEY_CODES[13] : key_num = 4'b0011;
			KEY_CODES[14] : key_num = 4'b0100;
			KEY_CODES[15] : key_num = 4'b0101;
			KEY_CODES[16] : key_num = 4'b0110;
			KEY_CODES[17] : key_num = 4'b0111;
			KEY_CODES[18] : key_num = 4'b1000;
			KEY_CODES[19] : key_num = 4'b1001;
			ENTER_KEY: key_num = 4'b1010;
			default		  : key_num = 4'b1111;
		endcase
	end
endmodule