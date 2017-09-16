defmodule NervesIOT.Devices.Sensor.TMP275 do
  require NervesIOT.Utils.Types
  require Logger
  use Bitwise
  alias ElixirALE.I2C
  alias NervesIOT.Utils.Types

  def start_link(addr) do
    Logger.debug "Starting TMP275 - addressing #{addr}"
    I2C.start_link("i2c-1", addr)
  end

  def get_celcius(pid) do
    # pointer reg = 0x00 (temp)
    I2C.write(pid, <<0x00>>)
    << byte1, byte2 >> = I2C.read(pid, 2)
    Types.sign_integer(((byte1 <<< 4) ||| (byte2 >>> 4)) &&& 0xFFF, 12) * 0.0625
  end
end
