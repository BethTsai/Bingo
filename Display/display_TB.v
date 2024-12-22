module display_TB(
	input wire clk,
	input wire rst,
	input wire change_cirle,

	output wire hsync,
	output wire vsync,
	output wire [3:0] vgaRed,
	output wire [3:0] vgaGreen,
	output wire [3:0] vgaBlue,
	output wire [6:0] DISPLAY,
	output wire [3:0] DIGIT
);
	reg [5*25-1:0] map;
	reg [25-1:0] circle;

	wire circle_pat_change;
	button_preprocess button_press_inst( .clk(clk), .signal_in(change_cirle), .signal_out(circle_pat_change));

	Display_top Display_top_inst(
		.clk(clk),
		.rst(rst),
		.interboard_rst(1'b0),
		.display_nums(8'hff),
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

	always @* begin
		if(rst) begin
			map <= {5'd1, 5'd12, 5'd19, 5'd20, 5'd21, 
					5'd22, 5'd23, 5'd24, 5'd25, 5'd2,
					5'd3, 5'd4, 5'd5, 5'd6, 5'd7,
					5'd8, 5'd9, 5'd10, 5'd11, 5'd13,
					5'd14, 5'd15, 5'd16, 5'd17, 5'd18};
			circle <= 25'd0;
		end else begin
			map <= map;
			if(circle_pat_change) begin
				circle <= circle + 1;
			end else begin
				circle <= circle;
			end
		end
	end

endmodule