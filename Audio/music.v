module Music_from_waveform (
    input wire clk,
    input wire rst,
    input wire en,

    output reg [15:0] waveform_amplitude
);

    localparam HOLD_TIME = 31_250; // number of 10ns in 1/4800 sec
    localparam MUSIC_LEN = 64000;  // number of int16 in 2 sec

    wire signed [15:0] amp;
    reg signed [15:0] prev_amp;

    wire clk_25MHz;
    clock_divider #(.n(2)) (.clk(clk), .clk_div(clk_25MHz));

    reg [31:0] time_cnt, time_cnt_next;
    reg [16:0] addr, addr_next;

    blk_mem_gen_5 blk_mem_gen_5_inst (.clka(clk_25MHz), .addra(addr), .dina(0), .douta(amp), .wea(0));


    always @(posedge clk) begin
        if(rst) begin
            time_cnt <= 0;
            addr <= 0;
            prev_amp <= 0;
        end
        else begin
            time_cnt <= time_cnt_next;
            addr <= addr_next;
            if(time_cnt == HOLD_TIME-1)
                prev_amp <= amp;
            else 
                prev_amp <= prev_amp;
        end
    end

    integer i;
    always@* begin
        for(i = 1; i <= 10; i = i + 1) begin
            if(time_cnt < 3125*i) begin 
                waveform_amplitude = prev_amp * (10-i) / 10 + amp * i / 10; 
            end
        end
    end

    always@* begin
        addr_next = addr;
        if(en) begin
            if(time_cnt == HOLD_TIME-1) begin
                if(addr == MUSIC_LEN-1) begin
                    addr_next = 0;
                end
                else begin
                    addr_next = addr + 1;
                end
            end
        end
        else begin
            addr_next = 0;
        end
    end

    always@* begin
        time_cnt_next = time_cnt;
        if(en) begin
            if(time_cnt == HOLD_TIME-1) begin
                time_cnt_next = 0;
            end
            else begin
                time_cnt_next = time_cnt + 1;
            end
        end
        else begin
            time_cnt_next = 0;
        end
    end

    
endmodule