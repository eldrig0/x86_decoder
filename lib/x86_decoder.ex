defmodule X86Decoder do
  def operation(0b100010), do: "mov"
  def operation(0b1011), do: "mov"

  def byte_reg(0b000), do: "al"
  def byte_reg(0b001), do: "cl"
  def byte_reg(0b010), do: "dl"
  def byte_reg(0b011), do: "bl"
  def byte_reg(0b100), do: "ah"
  def byte_reg(0b101), do: "ch"
  def byte_reg(0b110), do: "dh"
  def byte_reg(0b111), do: "bh"

  def word_reg(0b000), do: "ax"
  def word_reg(0b001), do: "cx"
  def word_reg(0b010), do: "dx"
  def word_reg(0b011), do: "bx"
  def word_reg(0b100), do: "sp"
  def word_reg(0b101), do: "bp"
  def word_reg(0b110), do: "si"
  def word_reg(0b111), do: "di"

  def reg(0, reg), do: byte_reg(reg)
  def reg(1, reg), do: word_reg(reg)

  # Base Address
  def base_rm_ea(0b000), do: "dx + si"
  def base_rm_ea(0b001), do: "bx + di"
  def base_rm_ea(0b010), do: "bp + si"
  def base_rm_ea(0b011), do: "bp + di"
  def base_rm_ea(0b100), do: "sp"
  def base_rm_ea(0b101), do: "di"
  def base_rm_ea(0b110), do: "bp"
  def base_rm_ea(0b111), do: "bx"

  def destination_source(0, reg, rm), do: {reg, rm}
  def destination_source(1, reg, rm), do: {rm, reg}

  def get_explicit_size(0), do: "byte"
  def get_explicit_size(1), do: "word"

  def read_instruction(path) do
    {:ok, content} = File.read(path)
    content
  end

  def decode_instruction(binary), do: decode(binary, ["bits 16"])

  def decode(<<>>, acc), do: acc |> Enum.reverse()

  # immediate to register
  def decode(<<0b1011::4, w::1, reg::3, rest::binary>>, acc) do
    {immediate, rest} = pick_immediate(w, rest)
    decode(rest, ["mov #{reg(w, reg)}, #{immediate}" | acc])
  end

  # register to memory or memory to register or register to register
  def decode(<<0b100010::6, d::1, w::1, rest::binary>>, acc) do
    {decoded_instruction, rest} = decode_reg_to_memory(d, w, rest)
    decode(rest, [decoded_instruction | acc])
  end

  def decode(<<0b1100011::7, w::1, rest::binary>>, acc) do
    {decoded_instruction, rest} = decode_immediate_to_register(w, rest)
    decode(rest, [decoded_instruction | acc])
  end

  # decode immediate to register memory
  def decode_immediate_to_register(w_bit, <<mod::2, 0b000::3, rm::3, rest::binary>>) do
    {decoded_rm_eac, rest} = decode_full_eac(mod, rm, rest)
    {immediate, rest} = pick_immediate(w_bit, rest)
    {"mov #{decoded_rm_eac}, #{get_explicit_size(w_bit)} #{immediate}", rest}
  end

  # register to register
  def decode_reg_to_memory(d_bit, w_bit, <<0b11::2, reg::3, rm::3, rest::binary>>) do
    {source, destination} = destination_source(d_bit, reg, rm)
    {"mov #{reg(w_bit, destination)}, #{reg(w_bit, source)}", rest}
  end

  # register to memory
  def decode_reg_to_memory(d_bit, w_bit, <<mod::2, reg::3, rm::3, rest::binary>>) do
    {decoded_rm_eac, rest} = decode_full_eac(mod, rm, rest)
    decoded_reg = reg(w_bit, reg)
    {source, destination} = destination_source(d_bit, decoded_reg, decoded_rm_eac)
    {"mov #{destination}, #{source}", rest}
  end

  def pick_immediate(0 = _w_bit, <<val::signed-8, rest::binary>>), do: {val, rest}
  def pick_immediate(1 = _w_bit, <<val::little-16, rest::binary>>), do: {val, rest}

  def decode_full_eac(0b00 = _mod, 0b110 = _rm, <<address::little-16, rest::binary>>),
    do: {"[#{address}]", rest}

  def decode_full_eac(0b00 = _mod, rm, <<rest::binary>>), do: {"[#{base_rm_ea(rm)}]", rest}

  def decode_full_eac(0b01 = _mod, rm, <<disp::signed-8, rest::binary>>) do
    eac =
      rm
      |> base_rm_ea()
      |> format_eac_syntax(disp)

    {eac, rest}
  end

  def decode_full_eac(0b10 = _mod, rm, <<disp::little-16, rest::binary>>) do
    eac =
      rm
      |> base_rm_ea()
      |> format_eac_syntax(disp)

    {eac, rest}
  end

  def format_eac_syntax(eac, 0), do: "[#{eac}]"
  def format_eac_syntax(eac, disp), do: "[#{eac} #{disp |> disp_string()}]"

  defp disp_string(disp) when disp > 0, do: "+ #{abs(disp)}"
  defp disp_string(disp) when disp < 0, do: "- #{abs(disp)}"
end
