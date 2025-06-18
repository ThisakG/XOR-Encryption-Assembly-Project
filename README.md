# XOR-Encryption-Assembly-Project

# Simple XOR File Encryptor/Decryptor (x86-64 Assembly)

This is a basic file encryption and decryption program written in x86-64 assembly language. The program uses a **multi-byte XOR key** provided by the user to encrypt or decrypt files. Since XOR encryption is symmetric, running the program twice on the same file with the same key will restore the original data.

## Features

- Prompts user for:
  - Input filename
  - Output filename
  - XOR key (multi-byte string)
- Reads the input file in 512-byte blocks (chunks)
- Performs XOR operation on each byte using the key (cycling through the key bytes)
- Writes the XOR-processed data to the output file
- Can be used both to encrypt and decrypt files with the same key

## How to Use

1. Install NASM if you have not (to double check input 'nasm --version' on your terminal)
2. Make sure your file to be encrypted is in the same directory as the .asm file
3. Assemble and link the program using an x86-64 assembler (e.g., NASM)
4. Run the executable. 
5. Enter the input filename (file to encrypt or decrypt).
6. Enter the output filename (where the processed file will be saved).
7. Enter the XOR key (any string, used as the encryption/decryption key).

Example:
- sudo apt-get install nasm
- nasm -f elf64 xor_file.asm -o xor_file.o
- ld xor_file.o -o xor_file
- ./xor_file
- Enter input filename: secret.txt
- Enter output filename: secret.enc
- Enter the XOR key: key

Now you should have a new file 'secret.enc' is your directory; use the 'cat' command to see how the encrypted output looks like ! (you might want to change the file permissions via chmod to see the file content)


## Known Issues

- There is a known problem with the decryption part when certain key lengths or input data patterns are used. This may cause incorrect decryption output in some cases.

- The program is intended for educational purposes and should not be used for securing sensitive data in production.

- Please report any issues or improvements via GitHub Issues.


## DISCLAMER:

This is a simple XOR-based encryption example implemented in assembly language for learning and demonstration purposes only. XOR encryption is not secure against modern cryptanalysis and should not be used to protect confidential information.


Feel free to fork, improve, and experiment with the code!
