defmodule Temperature do
  use Application
  require NervesIOT.Devices.Sensor.TMP275
  alias NervesIOT.Devices.Sensor.TMP275

  @slave 0x48

  def start(_type, _args) do
    {:ok, pid} = TMP275.start_link(@slave)
    TMP275.set_config(pid, resolution: 12)
    spawn fn -> listen_forever(pid) end
    {:ok, self()}
  end

  defp listen_forever(pid) do
    value = TMP275.get_celcius(pid)
    Process.sleep(220)
    IO.puts value
    listen_forever(pid)
  end

end
