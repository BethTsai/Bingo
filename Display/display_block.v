module display_window(
	input wire clk_25MHz,
	input wire all_rst,
	input wire [5*25-1:0] map,
	input wire [2:0] block_x,
	input wire [2:0] block_y,
	input wire [5:0] pixel_x,
	input wire [5:0] pixel_y,

	output reg [11:0] pixel_window
);
	localparam FRAME = 12'h732;
	localparam BACKGROUND = 12'h0;
	localparam NUMS_COLOR = 12'hfff;
	wire [0:1024-1] pixel_nums;
	wire [4:0] block_value;
	wire [4:0] pixel_addr;

	reg [0:1024-1] mem [0:24];
	initial begin
		$readmemb("nums.dat", mem);
	end
	assign pixel_nums = mem[pixel_addr];
	// blk_mem_gen_2 blk_mem_gen_2_inst( .clka(clk_25MHz), .dina(0), .wea(0), .addra(pixel_addr), .douta(pixel_nums));

	assign block_value = map[5*(block_x + block_y * 5) +: 5];
	assign pixel_addr = (block_value > 0 && block_value <= 25) ? block_value-1 : 0;

	always @(*) begin
		if(pixel_x < 2 || pixel_x >= 62)begin
			pixel_window = FRAME;
		end
		else if(pixel_y < 2 || pixel_y >= 62)begin
			pixel_window = FRAME;
		end
		else if(map[5*(block_x + block_y * 5) +: 5] == 0) begin
			pixel_window = BACKGROUND;
		end else begin
			pixel_window = pixel_nums[(pixel_x >> 1) + (pixel_y >> 1)*32] == 0 ? BACKGROUND : NUMS_COLOR;
		end
	end

endmodule
