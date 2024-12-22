module Display_top (
	input wire clk,
    input wire rst,
    input wire interboard_rst,
	input wire [7:0] display_nums,
    input wire [5*25-1:0] map,		// Table that need to be shown
	input wire [25-1:0] circle, 	// Circles that need to be shown
	input wire [12-1:0] line,

	inout PS2_CLK,
	inout PS2_DATA,
    output wire hsync,
    output wire vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire [6:0] DISPLAY,
    output wire [3:0] DIGIT
);
	wire clk_25MHz;
    clock_divider #(.n(2)) m2 (.clk(clk), .clk_div(clk_25MHz));

	wire all_rst;
	assign all_rst = rst | interboard_rst;

	reg [11:0] pixel;
	reg [11:0] pixel_bricks;
	wire [11:0] pixel_window;
	reg [64*64-1:0] pixel_nums, pixel_circle;
	reg [14:0] pixel_addr;
	wire draw_window, draw_frame, draw_circle, draw_line, draw_nums;
	
	wire [3:0] one_num;
	wire [15:0] nums;
	wire [9:0] h_cnt, v_cnt;
	reg [2:0] block_x, block_y;
	reg [6:0] pixel_x, pixel_y;

	assign nums = {8'hff, display_nums};

	assign {vgaRed, vgaGreen, vgaBlue} = (valid) ? pixel : 12'h0;
    vga_controller vga_inst(
        .pclk(clk_25MHz),
        .reset(all_rst),
        .hsync(hsync),
        .vsync(vsync),
        .valid(valid),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt)
    );

	display_window display_window_inst(
		.clk_25MHz(clk_25MHz),
		.all_rst(all_rst),
		.map(map),
		.block_x(block_x),
		.block_y(block_y),
		.pixel_x(pixel_x),
		.pixel_y(pixel_y),
		.block_pixel(pixel)
	);

	SevenSegment Sevenseg_inst0(
		.clk(clk), 
		.rst(all_rst), 
		.nums(nums),
		.display(DISPLAY),
		.digit(DIGIT)
	);
	
	// Store bricks_wall
	blk_mem_gen_0 blk_mem_gen_0_inst( .clka(clk_25MHz), .dina(dina), .wea(0), .addra(pixel_addr), .douta(pixel_bricks));
	// Store circles
	blk_mem_gen_3 blk_mem_gen_3_inst( .clka(clk_25MHz), .dina(dina), .wea(0), .addra(pixel_addr), .douta(pixel_circle));

	assign draw_window = (h_cnt >= 160 && h_cnt < 480) && (v_cnt >= 80 && v_cnt < 400);

endmodule