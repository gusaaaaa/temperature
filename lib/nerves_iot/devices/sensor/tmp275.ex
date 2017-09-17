defmodule NervesIOT.Devices.Sensor.TMP275 do
  require NervesIOT.Utils.Types
  require Logger
  use Bitwise
  alias ElixirALE.I2C
  alias NervesIOT.Utils.Types

  # refer to http://www.ti.com/lit/ds/symlink/tmp275.pdf for more information
  # about the TMP275 specification.

  def start_link(addr) do
    Logger.debug "Starting TMP275 - addressing #{addr}"
    I2C.start_link("i2c-1", addr)
  end

  # def get_config(pid) do
  #   I2C.write(pid, <<0x01>>)
  #   << cfg_reg >> = I2C.read(pid, 1)
  #
  # end

  def set_config(pid, options \\ []) do
    defaults = [
      one_shot:         false,
      resolution:       9,
      fault_queue:      1,
      polarity:         false,
      thermostat_mode:  false,
      shutdown_mode:    false
    ]

    options = Keyword.merge(defaults, options) |> Enum.into(%{})

    os = case options.one_shot do
      true  -> 1 <<< 7
      false -> 0
      _ ->
        Logger.debug "Invalid value for one_shot option. Defaulting to false."
        0
    end

    r1r0 = case options.resolution do
      9  -> 0
      10 -> 1 <<< 5
      11 -> 2 <<< 5
      12 -> 3 <<< 5
      _  ->
        Logger.debug "Invalid value for resolution option. Defaulting to 9."
        0
    end

    f1f0 = case options.fault_queue do
      1 -> 0
      2 -> 1 <<< 3
      4 -> 2 <<< 3
      6 -> 3 <<< 3
      _ ->
        Logger.debug "Invalid value for fault_queue option. Defaulting to 0."
        0
    end

    pol = case options.polarity do
      true  -> 1 <<< 2
      false -> 0
      _ ->
        Logger.debug "Invalid value for polarity option. Defaulting to false."
        0
    end

    tm = case options.thermostat_mode do
      true  -> 1 <<< 1
      false -> 0
      _ ->
        Logger.debug "Invalid value for thermostat_mode option. Defaulting to false."
        0
    end

    sd = case options.shutdown_mode do
      true  -> 1
      false -> 0
      _ ->
        Logger.debug "Invalid value for shutdown_mode option. Defaulting to false."
        0
    end

    config = os ||| r1r0 ||| f1f0 ||| pol ||| tm ||| sd

    I2C.write(pid, <<0x01, config>>)
  end

  def get_celcius(pid) do
    # pointer reg = 0x00 (temp)
    I2C.write(pid, <<0x00>>)
    << byte1, byte2 >> = I2C.read(pid, 2)
    Types.sign_integer(((byte1 <<< 4) ||| (byte2 >>> 4)) &&& 0xFFF, 12) * 0.0625
  end
end
