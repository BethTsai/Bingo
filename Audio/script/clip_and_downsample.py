from pydub import AudioSegment

def clip_and_downsample(input_file, output_file, downsample_rate):
    # Load the audio file
    audio = AudioSegment.from_wav(input_file)
    
    # Trim the first 15 seconds
    trimmed_audio = audio[16000:36000]  # pydub works in milliseconds
    
    # Downsample the audio
    downsampled_audio = trimmed_audio.set_frame_rate(downsample_rate)
    
    # Ensure the audio is in stereo
    stereo_audio = downsampled_audio.set_channels(1)
    
    # Export the processed audio
    stereo_audio.export(output_file, format="wav")

# Example usage
input_file = "audio.wav"
output_file = "audio_preprocessed.wav"
downsample_rate = 4800  # Specify the desired downsample rate

clip_and_downsample(input_file, output_file, downsample_rate)