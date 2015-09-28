defmodule MethexTest do
  use ExUnit.Case

  @name "qwe"
  test "the truth" do
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
  end
  
end
