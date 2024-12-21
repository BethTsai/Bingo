module display_window(
	input wire clk_25MHz,
	input wire all_rst,
	input wire [5*25-1:0] map,
	input wire [2:0] block_x,
	input wire [2:0] block_y,
	input wire [6:0] pixel_x,
	input wire [6:0] pixel_y,

	output wire [11:0] pixel_window
);
	localparam FRAME = 12'h0;
	// Store window
	blk_mem_gen_1 blk_mem_gen_1_inst( .clka(clk_25MHz), .dina(dina), .wea(0), .addra(pixel_addr), .douta(pixel_window));
	// Store 25 numbers
	blk_mem_gen_2 blk_mem_gen_2_inst( .clka(clk_25MHz), .dina(dina), .wea(0), .addra(pixel_addr), .douta(pixel_nums));


endmodule
