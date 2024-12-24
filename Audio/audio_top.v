module Audio_top (
    input wire clk,
    input wire rst,
    input wire hit,
    input wire en_music,

    output wire audio_mclk, // master clock
    output wire audio_lrck, // left-right clock
    output wire audio_sck,  // serial clock
    output wire audio_sdin // serial audio data input
);
    
    // wire [21:0] bgm_note_div_left, bgm_note_div_right;
    // wire [15:0] bgm_amplitude;

    wire signed [15:0] music_waveform;


    Music_from_waveform Music_from_waveform_inst(
        .clk(clk),
        .rst(rst),
        .en(en_music), 

        .waveform_amplitude(music_waveform)
    );

    speaker_control speaker_control_inst(
        .clk(clk),
        .rst(rst),
        .audio_in_left(music_waveform),
        .audio_in_right(music_waveform),
        .audio_mclk(audio_mclk),
        .audio_lrck(audio_lrck),
        .audio_sck(audio_sck),
        .audio_sdin(audio_sdin)
    );

endmodule