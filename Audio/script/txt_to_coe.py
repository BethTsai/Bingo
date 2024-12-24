def txt_to_coe(input_txt_path, output_coe_path):
    # Read binary values from the .txt file
    with open(input_txt_path, 'r') as txt_file:
        binary_values = txt_file.readlines()

    # Convert binary values to integers without trimming leading zeros
    frequencies = [int(bin_val.strip(), 2) for bin_val in binary_values]

    # Write the .coe file
    with open(output_coe_path, 'w') as coe_file:
        coe_file.write("memory_initialization_radix=2;\n")
        coe_file.write("memory_initialization_vector=\n")
        coe_file.write(",\n".join(map(lambda x: format(x, '016b'), frequencies)))
        coe_file.write(";")

# Example usage
input_txt_path = "audio_waveform.txt"
output_coe_path = "audio_waveform.coe"
txt_to_coe(input_txt_path, output_coe_path)
