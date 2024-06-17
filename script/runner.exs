alias X86Decoder, as: Decoder

~c"asm_input/explicit_size"
|> Decoder.read_instruction()
|> Decoder.decode_instruction()
|> Enum.join("\n")
|> IO.puts()
