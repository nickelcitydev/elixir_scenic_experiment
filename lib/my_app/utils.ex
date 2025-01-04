defmodule MyApp.Utils do
  def screen_width do
    {width, _height} = Application.get_env(:my_app, :viewport)[:size]
    width
  end

  def screen_height do
    {_width, height} = Application.get_env(:my_app, :viewport)[:size]
    height
  end
end
