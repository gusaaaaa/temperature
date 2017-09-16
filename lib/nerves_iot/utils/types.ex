defmodule NervesIOT.Utils.Types do
  use Bitwise

  def sign_integer(value, bitcount) do
    # integer represented in two's complement
    if value &&& (1 <<< (bitcount - 1)), do: -(~~~value + 1), else: value
  end
end
