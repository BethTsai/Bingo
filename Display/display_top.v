module Display_top (
	input wire clk,
    input wire rst,
    input wire interboard_rst,
	input wire [7:0] display_nums,
    input wire [5*5-1:0] map,	

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
	wire [3:0] one_num;
	wire [15:0] nums;
	wire [9:0] h_cnt, v_cnt;

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

	SevenSegment Sevenseg_inst0(
		.clk(clk), 
		.rst(all_rst), 
		.nums(nums),
		.display(DISPLAY),
		.digit(DIGIT)
	);
	
	
endmodule