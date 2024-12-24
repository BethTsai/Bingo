module Display_top (
	input wire clk,
    input wire rst,
    input wire interboard_rst,
	input wire [7:0] display_nums,
    input wire [5*25-1:0] map,		// Table that need to be shown
	input wire [25-1:0] circle, 	// Circles that need to be shown
	// input wire [12-1:0] line,

    output wire hsync,
    output wire vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire [6:0] DISPLAY,
    output wire [3:0] DIGIT
);
	localparam circle_mem = 1024'b0000000000000000000000000000000000000000000000000000000000000000000000000000111111111000000000000000000001111111111111100000000000000000111100000000011110000000000000011100000000000001110000000000001110000000000000001110000000000111000000000000000001110000000011100000000000000000001110000001110000000000000000000001100000011000000000000000000000001100000110000000000000000000000011000011000000000000000000000000111000110000000000000000000000000110001100000000000000000000000001100011000000000000000000000000011000110000000000000000000000000110001100000000000000000000000001100011000000000000000000000000011000110000000000000000000000000110001100000000000000000000000011100001100000000000000000000000110000011000000000000000000000001100000011000000000000000000000110000000111000000000000000000011100000000111000000000000000001110000000000111000000000000000111000000000000111000000000000011100000000000000111110000000111110000000000000000011111111111110000000000000000000001111111110000000000000000000000000000000000000000000;

	localparam FRAME = 12'h732;
	localparam CIRCLE_COLOR = 12'hc22;


	wire clk_25MHz;
    clock_divider #(.n(1)) m2 (.clk(clk), .clk_div(clk_25MHz));

	wire all_rst;
	assign all_rst = rst | interboard_rst;

	reg [11:0] pixel;
	wire [11:0] pixel_bricks;
	wire [11:0] pixel_window, pixel_block;
	wire [0:1024-1] pixel_circle;
	reg [16:0] pixel_addr;
	wire draw_window, draw_circle, draw_line, draw_nums, draw_outer_frame;
	
	// reg [0:1024-1] mem2 [0:1];
	// initial begin
	// 	$readmemb("circle.dat", mem2);
	// end
	// assign pixel_circle = mem2[0];
	assign pixel_circle = circle_mem;
	
	wire [3:0] one_num;
	wire [15:0] nums;
	wire [9:0] h_cnt, v_cnt;
	reg [2:0] block_x, block_y;
	reg [5:0] pixel_x, pixel_y;

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
		.pixel_window(pixel_block)
	);

	SevenSegment Sevenseg_inst0(
		.clk(clk), 
		.rst(all_rst), 
		.nums(nums),
		.display(DISPLAY),
		.digit(DIGIT)
	);
	
	// Store bricks_wall
	blk_mem_gen_0 blk_mem_gen_0_inst( .clka(clk_25MHz), .dina(0), .wea(0), .addra(pixel_addr), .douta(pixel_bricks));
	// Store window
	blk_mem_gen_1 blk_mem_gen_1_inst( .clka(clk_25MHz), .dina(0), .wea(0), .addra(pixel_addr), .douta(pixel_window));
	// Store Circle
	// blk_mem_gen_3 blk_mem_gen_3_inst( .clka(clk_25MHz), .dina(0), .wea(0), .addra(0), .douta(pixel_circle));
	
	assign draw_window = (h_cnt >= 160 && h_cnt < 480) && (v_cnt >= 80 && v_cnt < 400);
	assign draw_outer_frame = (((h_cnt >= 158 && h_cnt < 160) || (h_cnt >= 480 && h_cnt < 482)) && (v_cnt >= 78 && v_cnt < 402)) ||
								(((v_cnt >= 78 && v_cnt < 80) || (v_cnt >= 400 && v_cnt < 402)) && (h_cnt >= 158 && h_cnt < 482));
	assign draw_circle = circle[block_x + block_y * 5];
	
	always @(*) begin
		if(draw_window) begin
			pixel_addr = ((h_cnt - 160) >> 1) + ((v_cnt - 80) >> 1) * 160;
		end 
		else begin
			pixel_addr = (v_cnt%120)*160 + h_cnt%160;
		end
	end
	always @(*) begin
		// if(draw_line) begin
		// end
		if(draw_window) begin
			if(draw_circle) begin
				if (pixel_circle[(pixel_x >> 1) + (pixel_y >> 1 )* 32] == 0) begin
					pixel = pixel_block == 0 ? pixel_window : pixel_block;	
				end else begin
					pixel = CIRCLE_COLOR;
				end
			end
			else begin	// pixel_block == 0 means transparent
				pixel = pixel_block == 0 ? pixel_window : pixel_block;
			end
		end
		else if(draw_outer_frame)begin
			pixel = FRAME;
		end
		else begin
			pixel = pixel_bricks;
		end
	end
	
	// block X
	always @(*) begin
		block_x = 0;
		if(h_cnt >= 160 && h_cnt < 480)begin
			block_x = (h_cnt - 160) >> 6;
		end
	end
	// block Y
	always @(*) begin
		block_y = 0;
		if(v_cnt >= 80 && v_cnt < 400)begin
			block_y = (v_cnt - 80) >> 6;
		end
	end
	// pixel X
	always @(*) begin
		pixel_x = 0;
		if(h_cnt >= 160 && h_cnt < 480)begin
			pixel_x = (h_cnt - 160) & 63;
		end
	end
	// pixel Y
	always @(*) begin
		pixel_y = 0;
		if(v_cnt >= 80 && v_cnt < 400)begin
			pixel_y = (v_cnt - 80) & 63;
		end
	end
endmodule