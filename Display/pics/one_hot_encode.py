import os

if __name__ == "__main__":
    base_dir = "./COE"
    final_output = []
    
    for idx in range(1, 26):
        file_path = os.path.join(base_dir, f"{idx}.coe")
    
        try:
            with open(file_path, 'r') as file:
                lines = file.readlines()
                if len(final_output) == 0:
                    final_output.extend(lines[:2])
                lines = lines[2:]
            
                one_row = ""
            
                for line in lines:
                    line = line.strip(";,\n")
                    if line == '000':
                        one_row += '0'
                    elif line == 'FFF':
                        one_row += '1'
                    else:
                        one_row += '1'
                one_row += ",\n"
                final_output.append(one_row)
                
        except Exception as e:
            print(f"Error processing file {file_path}: {e}")
                    
    output_file_path = os.path.join(base_dir, "../final_number.coe")
    try:
        with open(output_file_path, 'w') as output_file:
            for line in final_output:
                output_file.write(line)
    except Exception as e:
        print(f"Error writing to output file {output_file_path}: {e}")