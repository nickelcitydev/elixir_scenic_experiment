defmodule MyApp.Scene.Home do
  use Scenic.Scene
  require Logger
  require Integer

  alias Scenic.Graph

  import Scenic.Primitives
  # import Scenic.Components

  @frame_ms 240

  @input_classes [:codepoint, :key]

  @character_sprite_path "sprites/rogue.png"

  @idle_sprites [
    {{0, 0}, {32, 32}, {80, 80}, {128, 128}},
    {{32, 0}, {32, 32}, {80, 80}, {128, 128}},
    {{64, 0}, {32, 32}, {80, 80}, {128, 128}},
    {{96, 0}, {32, 32}, {80, 80}, {128, 128}},
    {{128, 0}, {32, 32}, {80, 80}, {128, 128}},
    {{160, 0}, {32, 32}, {80, 80}, {128, 128}},
    {{192, 0}, {32, 32}, {80, 80}, {128, 128}},
    {{224, 0}, {32, 32}, {80, 80}, {128, 128}},
    {{256, 0}, {32, 32}, {80, 80}, {128, 128}},
    {{288, 0}, {32, 32}, {80, 80}, {128, 128}}
  ]

  @gesture_sprites [
    {{0, 32}, {32, 32}, {80, 80}, {128, 128}},
    {{32, 32}, {32, 32}, {80, 80}, {128, 128}},
    {{64, 32}, {32, 32}, {80, 80}, {128, 128}},
    {{96, 32}, {32, 32}, {80, 80}, {128, 128}},
    {{128, 32}, {32, 32}, {80, 80}, {128, 128}},
    {{160, 32}, {32, 32}, {80, 80}, {128, 128}},
    {{192, 32}, {32, 32}, {80, 80}, {128, 128}},
    {{224, 32}, {32, 32}, {80, 80}, {128, 128}},
    {{256, 32}, {32, 32}, {80, 80}, {128, 128}},
    {{288, 32}, {32, 32}, {80, 80}, {128, 128}}
  ]

  @walking_sprites [
    {{0, 64}, {32, 32}, {80, 80}, {128, 128}},
    {{32, 64}, {32, 32}, {80, 80}, {128, 128}},
    {{64, 64}, {32, 32}, {80, 80}, {128, 128}},
    {{96, 64}, {32, 32}, {80, 80}, {128, 128}},
    {{128, 64}, {32, 32}, {80, 80}, {128, 128}},
    {{160, 64}, {32, 32}, {80, 80}, {128, 128}},
    {{192, 64}, {32, 32}, {80, 80}, {128, 128}},
    {{224, 64}, {32, 32}, {80, 80}, {128, 128}},
    {{256, 64}, {32, 32}, {80, 80}, {128, 128}},
    {{288, 64}, {32, 32}, {80, 80}, {128, 128}}
  ]

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do
    # handle input
    :ok = request_input(scene, @input_classes)

    # animation timer
    {:ok, timer} = :timer.send_interval(@frame_ms, :frame)

    player_sprite = Enum.at(@walking_sprites, 0)

    graph =
      Graph.build()
      # rectangle used for capturing cursor input
      |> rect({MyApp.Utils.screen_width(), MyApp.Utils.screen_height()},
        fill: {:color, :light_gray}
      )
      # initial player sprite
      |> sprites(
        {@character_sprite_path,
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
        player_sprite: player_sprite,
        is_walking: false
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
        frame < 9 -> frame + 1
        true -> 0
      end

    player_sprite = Enum.at(@idle_sprites, new_frame) |> elem(0)

    # update the graph
    graph =
      scene.assigns.graph
      # |> Graph.modify(:rect, &rect(&1, {25, 25}, fill: {:color, {frame, 0, 0}}))
      |> Graph.modify(
        :sprites,
        &sprites(
          &1,
          {@character_sprite_path,
           [
             {player_sprite, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}}
           ]}
        )
      )

    # update the state
    scene =
      scene
      |> assign(
        player_sprite: {player_sprite, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}},
        frame: new_frame
      )

    # push out the graph to the scene
    if !scene.assigns.is_walking do
      push_graph(scene, graph)
    end

    {:noreply, scene}
  end

  def handle_input({:key, {:key_d, 0, _}} = event, _context, scene) do
    IO.inspect(event)
    # pattern match out the coordinates
    {{_src_x, _src_y}, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}} =
      scene.assigns.player_sprite

    frame = scene.assigns.frame

    new_frame =
      cond do
        frame < 9 -> frame + 1
        true -> 0
      end

    player_sprite = Enum.at(@idle_sprites, new_frame) |> elem(0)

    # update the graph
    graph =
      scene.assigns.graph
      # |> Graph.modify(:rect, &rect(&1, {25, 25}, fill: {:color, {frame, 0, 0}}))
      |> Graph.modify(
        :sprites,
        &sprites(
          &1,
          {@character_sprite_path,
           [
             {player_sprite, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}}
           ]}
        )
      )

    # update the state
    scene =
      scene
      |> assign(
        player_sprite: {player_sprite, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}},
        frame: new_frame,
        is_walking: false
      )

    # push out the graph to the scene
    push_graph(scene, graph)

    {:noreply, scene}
  end

  def handle_input({:key, {:key_d, 1, _}} = event, _context, scene) do
    IO.inspect(event)
    # pattern match out the coordinates
    {{_src_x, _src_y}, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}} =
      scene.assigns.player_sprite

    frame = scene.assigns.frame

    new_frame =
      cond do
        frame < 9 -> frame + 1
        true -> 0
      end

    player_sprite = Enum.at(@walking_sprites, new_frame) |> elem(0)

    # update the graph
    graph =
      scene.assigns.graph
      # |> Graph.modify(:rect, &rect(&1, {25, 25}, fill: {:color, {frame, 0, 0}}))
      |> Graph.modify(
        :sprites,
        &sprites(
          &1,
          {@character_sprite_path,
           [
             {player_sprite, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}}
           ]}
        )
      )

    # update the state
    scene =
      scene
      |> assign(
        player_sprite: {player_sprite, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}},
        frame: new_frame,
        is_walking: true
      )

    # push out the graph to the scene
    push_graph(scene, graph)

    {:noreply, scene}
  end

  def handle_input({:key, {:key_d, 2, _}} = event, _context, scene) do
    IO.inspect(event)
    # pattern match out the coordinates
    {{_src_x, _src_y}, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}} =
      scene.assigns.player_sprite

    frame = scene.assigns.frame

    new_frame =
      cond do
        frame < 9 -> frame + 1
        true -> 0
      end

    player_sprite = Enum.at(@walking_sprites, new_frame) |> elem(0)

    # update the graph
    graph =
      scene.assigns.graph
      # |> Graph.modify(:rect, &rect(&1, {25, 25}, fill: {:color, {frame, 0, 0}}))
      |> Graph.modify(
        :sprites,
        &sprites(
          &1,
          {@character_sprite_path,
           [
             {player_sprite, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}}
           ]}
        )
      )

    # update the state
    scene =
      scene
      |> assign(
        player_sprite: {player_sprite, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}},
        frame: new_frame,
        is_walking: true
      )

    # push out the graph to the scene
    push_graph(scene, graph)

    {:noreply, scene}
  end

  # handling any other form of input
  # based on provided input classes
  def handle_input(_event, _context, scene) do
    # IO.inspect(event, label: "Input")
    {:noreply, scene}
  end
end
