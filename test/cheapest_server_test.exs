defmodule CheapestServerTest do
  use ExUnit.Case
  doctest CheapestServer

  test "greets the world" do
    assert CheapestServer.hello() == :world
  end
end
