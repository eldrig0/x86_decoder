alias X86Decoder, as: Decoder

System.argv() |> case do
  [file] -> ~c"asm_input/#{file}"
     |> Decoder.read_instruction()
     |> Decoder.decode_instruction()
     |> Enum.join("\n")
     |> IO.puts()

  _ -> IO.puts("Error: Unsupported argument")
end
