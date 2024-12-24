import soundfile as sf
import numpy as np

def wav_to_int(input_path, output_path):
    # Load the WAV file into a NumPy array
    data, samplerate = sf.read(input_path)
    
    # Convert the data to 16-bit integers
    data_int = (data * 32767).astype(np.int16)

    # Convert the integers to binary format using two's complement
    data_bin = [np.binary_repr(x, width=16) for x in data_int]

    # Write the binary data to a .txt file
    with open(output_path, 'w') as f:
        for item in data_bin:
            f.write("%s\n" % item)

# Example usage
input_path = "audio_preprocessed.wav"
output_path = "audio_waveform.txt"
wav_to_int(input_path, output_path)