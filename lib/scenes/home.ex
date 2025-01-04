defmodule MyApp.Scene.Home do
  use Scenic.Scene
  require Logger
  require Integer

  alias Scenic.Graph

  import Scenic.Primitives
  # import Scenic.Components

  @frame_ms 120

  @input_classes [:codepoint, :key, :cursor_button, :cursor_scroll, :cursor_pos]

  @player_sprites [
    # left foot forward
    {{0, 19}, {32, 48}, {80, 80}, {32, 48}},
    # idle
    {{32, 19}, {32, 48}, {80, 80}, {32, 48}},
    # right foot forward
    {{64, 19}, {32, 48}, {80, 80}, {32, 48}}
  ]

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do
    # handle input
    :ok = request_input(scene, @input_classes)

    # animation timer
    {:ok, timer} = :timer.send_interval(@frame_ms, :frame)

    player_sprite = Enum.at(@player_sprites, 0)

    graph =
      Graph.build()
      # rectangle used for capturing cursor input
      |> rect({MyApp.Utils.screen_width(), MyApp.Utils.screen_height()})
      # initial player sprite
      |> sprites(
        {"sprites/sprites.png",
         [
           player_sprite
         ]},
        id: :sprites
      )

    scene =
      scene
      |> assign(
        graph: graph,
        frame_timer: timer,
        frame: 0,
        player_sprite: player_sprite
      )
      |> push_graph(graph)

    {:ok, scene}
  end

  def handle_info(:frame, scene) do
    # pattern match out the coordinates
    {{_src_x, _src_y}, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}} =
      scene.assigns.player_sprite

    frame = scene.assigns.frame

    new_frame =
      cond do
        frame < 2 -> frame + 1
        true -> 0
      end

    IO.inspect("frame: #{frame} new_frame: #{new_frame}")

    player_sprite = Enum.at(@player_sprites, new_frame) |> elem(0)

    IO.inspect(player_sprite)

    # update the graph
    graph =
      scene.assigns.graph
      # |> Graph.modify(:rect, &rect(&1, {25, 25}, fill: {:color, {frame, 0, 0}}))
      |> Graph.modify(
        :sprites,
        &sprites(
          &1,
          {"sprites/sprites.png",
           [
             {player_sprite, {src_w, src_h}, {dst_x, dst_y + 1}, {dst_w, dst_h}}
           ]}
        )
      )

    # update the state
    scene =
      scene
      |> assign(
        player_sprite: {player_sprite, {src_w, src_h}, {dst_x, dst_y + 1}, {dst_w, dst_h}},
        frame: new_frame
      )

    # push out the graph to the scene
    push_graph(scene, graph)

    {:noreply, scene}
  end

  # handling any other form of input
  # based on provided input classes
  def handle_input(event, _context, scene) do
    # IO.inspect(event, label: "Input")
    {:noreply, scene}
  end
end
