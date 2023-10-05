defmodule Exercises do
  def sum(list, acc \\ 0)
  def sum([], acc), do: acc
  def sum([head | tail], acc) do
    sum(tail, acc + head)
  end

  def flatten_square_reverse(list, acc \\ [])
  def flatten_square_reverse(num, acc) when is_number(num), do: [num * num | acc]
  def flatten_square_reverse([], acc), do: acc
  def flatten_square_reverse([head], acc) do
    flatten_square_reverse(head, acc)
  end
  def flatten_square_reverse([head | tail], acc) do
    flatten_square_reverse(tail, [head * head | acc])
  end


  defmodule ErlangToElixir do
    def cryptoMd5Hash(str) do
      :crypto.hash(:md5, str)
    end
  end


  defmodule Ipv4Parser do
    def parse(packet) do
      <<
        version :: 4,
        ihl :: 4,
        _dscp :: 6,
        _ecn :: 2,
        _total_length :: binary-size(2),
        _identification :: binary-size(2),
        _flags :: 3,
        _fragment_offset :: 13,
        ttl :: 8,
        protocol :: 8,
        _header_checksum :: binary-size(2),
        src_ip_address :: binary-size(4),
        dest_ip_address :: binary-size(4),
        rest :: binary
      >> = packet

      options_size = ihl * 32 - 160
      <<_options :: size(options_size), data :: binary>> = rest

      %{
        version: version,
        protocol: protocol,
        ttl: ttl,
        ihl: ihl,
        src_ip_address: dotted_decimal_ip(src_ip_address),
        dest_ip_address: dotted_decimal_ip(dest_ip_address),
        data: data
      }
    end

    def dotted_decimal_ip(binary) do
      binary |> String.split(".") |> Enum.map(&String.to_integer/1) |> Enum.join(".")
    end
  end


end
