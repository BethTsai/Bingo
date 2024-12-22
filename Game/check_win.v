module check_win(
    input wire [25-1:0] circle,

    output wire i_win
);

    reg [11:0] lines;
    reg [3:0] lines_cnt;
    integer i;

    always @(*) begin
        for (i = 0; i <= 4; i = i + 1) begin
            lines[i] = circle[i] & circle[i+5] & circle[i+10] & circle[i+15] & circle[i+20];
            lines[i+5] = circle[i*5] & circle[i*5+1] & circle[i*5+2] & circle[i*5+3] & circle[i*5+4];
        end

        lines[10] = circle[0] & circle[6] & circle[12] & circle[18] & circle[24];
        lines[11] = circle[4] & circle[8] & circle[12] & circle[16] & circle[20];
    end

    always@* begin
        lines_cnt = lines[0] + lines[1] + lines[2] + lines[3] + lines[4] + lines[5] + 
                    lines[6] + lines[7] + lines[8] + lines[9] + lines[10] + lines[11];
    end    

    assign i_win = (lines_cnt >= 3);

endmodule