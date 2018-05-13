defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Take the input apply a md5 crypto and transform in a list and return a
  Identicon Image struct

  ## Examples
      
      iex> %Identicon.Image{hex: hex} = Identicon.hash_input 'teste'
      iex> hex
      [105, 141, 193, 157, 72, 156, 78, 77, 183, 62, 40, 167, 19, 234, 176, 123]
      
  """ 
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
          |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end

  @doc """
  Take the first 3 numbers of the hex option inside Identicon.Image
  put inside a color option inside Identicon.Image to be used to colorize
  the identicon image.

  ## Examples
      
      iex> image  = Identicon.hash_input 'teste'
      iex> %Identicon.Image{color: color} = Identicon.pick_color image
      iex> color
      {105, 141, 193}
      
  """ 
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail] } = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
  Take the hex array and transform in a array of array of 3 elements,
  this array is mirrored. Now this array is flattened and is put insisde
  a new attribute of our struct named grid.

  ## Examples
      
      iex> image  = Identicon.hash_input 'teste'
      iex> %Identicon.Image{grid: grid} = Identicon.build_grid image
      iex> grid
      [
        {105, 0},
        {141, 1},
        {193, 2},
        {141, 3},
        {105, 4},
        {157, 5},  
        {72, 6},
        {156, 7},
        {72, 8},
        {157, 9},
        {78, 10},
        {77, 11},
        {183, 12},
        {77, 13},
        {78, 14},
        {62, 15},
        {40, 16},
        {167, 17},
        {40, 18},
        {62, 19},
        {19, 20},
        {234, 21},
        {176, 22},
        {234, 23},
        {19, 24}
      ]
  """ 
  def build_grid(%Identicon.Image{hex: hex } = image) do
    grid = 
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image| grid: grid}
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index }) ->
      rem(code, 2) == 0
    end
    %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) -> 
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = { horizontal, vertical}
      bottom_right = { horizontal + 50, vertical + 50 }
      {top_left, bottom_right}
    end
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create 250, 250
    fill = :egd.color color
    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render image
  end

  def save_image(image, filename) do
    File.write "#{filename}.png", image
  end
end
