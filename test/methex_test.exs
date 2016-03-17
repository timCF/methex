defmodule MethexTest do
	use ExUnit.Case
	require Logger
	require Methex

	@sleep 100
	@name "qwe"
	test "methex_full" do
		Methex.put(100, @name)
		Methex.put(50, @name)
		Methex.put(150, @name)
		assert [100,50,150] == Methex.get(@name)
		assert 100.0 == Methex.get_average(@name)
		assert 0.05 == Methex.get_freq(@name)
		Methex.put(100, @name, 120)
		Methex.put(50, @name, 120)
		Methex.put(150, @name, 120)
		assert 0.025 == Methex.get_freq(@name)
		assert [@name] == Methex.keys
		assert %{"logger_debug" => 0.0, "logger_error" => 0.0, "logger_info" => 0.0, "logger_warn" => 0.0} == Methex.Logger.get_freq
		Enum.each(1..3, fn(n) ->
			message = "hello #{n}"
			Logger.debug(message)
			Logger.info(message)
			Logger.warn(message)
			Logger.error(message)
		end)
		:timer.sleep(1000)
		assert %{"logger_debug" => 0.05, "logger_error" => 0.05, "logger_info" => 0.05, "logger_warn" => 0.05} == Methex.Logger.get_freq
		assert %{"freq_logger_debug" => 0.05, "freq_logger_error" => 0.05, "freq_logger_info" => 0.05, "freq_logger_warn" => 0.05, "freq_qwe" => 0.025} == Methex.all_freq
		assert %{"average_logger_debug" => 1.0, "average_logger_error" => 1.0, "average_logger_info" => 1.0, "average_logger_warn" => 1.0, "average_qwe" => 100.0} == Methex.all_average
		assert %{"average_logger_debug" => 1.0, "average_logger_error" => 1.0, "average_logger_info" => 1.0, "average_logger_warn" => 1.0, "average_qwe" => 100.0, "freq_logger_debug" => 0.05, "freq_logger_error" => 0.05, "freq_logger_info" => 0.05, "freq_logger_warn" => 0.05, "freq_qwe" => 0.025} == Methex.all
		Enum.each(1..6, fn(_) -> :timer.sleep(@sleep) |> Methex.tc("sleep") end)
		IO.puts("\n#{@sleep} => #{Methex.get_average("sleep")}")
		assert (Methex.get_average("sleep") >= @sleep) and (Methex.get_average("sleep") < (@sleep + 10))
		assert 0.1 == Methex.get_freq("sleep")
	end

end
