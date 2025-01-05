defmodule MyApp.Scene.Home do
  use Scenic.Scene
  require Logger
  require Integer

  alias Scenic.Graph

  import Scenic.Primitives
  # import Scenic.Components

  @frame_ms 90

  @step 8

  @input_classes [:codepoint, :key]

  @character_sprite_path "sprites/rogue.png"

  @idle_sprites [
    {{0, 0}, {32, 32}, {80, 80}, {64, 64}},
    {{32, 0}, {32, 32}, {80, 80}, {64, 64}},
    {{64, 0}, {32, 32}, {80, 80}, {64, 64}},
    {{96, 0}, {32, 32}, {80, 80}, {64, 64}},
    {{128, 0}, {32, 32}, {80, 80}, {64, 64}},
    {{160, 0}, {32, 32}, {80, 80}, {64, 64}},
    {{192, 0}, {32, 32}, {80, 80}, {64, 64}},
    {{224, 0}, {32, 32}, {80, 80}, {64, 64}},
    {{256, 0}, {32, 32}, {80, 80}, {64, 64}},
    {{288, 0}, {32, 32}, {80, 80}, {64, 64}}
  ]

  @gesture_sprites [
    {{0, 32}, {32, 32}, {80, 80}, {64, 64}},
    {{32, 32}, {32, 32}, {80, 80}, {64, 64}},
    {{64, 32}, {32, 32}, {80, 80}, {64, 64}},
    {{96, 32}, {32, 32}, {80, 80}, {64, 64}},
    {{128, 32}, {32, 32}, {80, 80}, {64, 64}},
    {{160, 32}, {32, 32}, {80, 80}, {64, 64}},
    {{192, 32}, {32, 32}, {80, 80}, {64, 64}},
    {{224, 32}, {32, 32}, {80, 80}, {64, 64}},
    {{256, 32}, {32, 32}, {80, 80}, {64, 64}},
    {{288, 32}, {32, 32}, {80, 80}, {64, 64}}
  ]

  @walking_sprites [
    {{0, 64}, {32, 32}, {80, 80}, {64, 64}},
    {{32, 64}, {32, 32}, {80, 80}, {64, 64}},
    {{64, 64}, {32, 32}, {80, 80}, {64, 64}},
    {{96, 64}, {32, 32}, {80, 80}, {64, 64}},
    {{128, 64}, {32, 32}, {80, 80}, {64, 64}},
    {{160, 64}, {32, 32}, {80, 80}, {64, 64}},
    {{192, 64}, {32, 32}, {80, 80}, {64, 64}},
    {{224, 64}, {32, 32}, {80, 80}, {64, 64}},
    {{256, 64}, {32, 32}, {80, 80}, {64, 64}},
    {{288, 64}, {32, 32}, {80, 80}, {64, 64}}
  ]

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do
    # handle input
    :ok = request_input(scene, @input_classes)

    # animation timer
    {:ok, timer} = :timer.send_interval(@frame_ms, :frame)

    {{src_x, src_y}, {src_w, src_h}, {_dst_x, _dst_y}, {dst_w, dst_h}} = Enum.at(@idle_sprites, 0)

    player_sprite =
      {{src_x, src_y}, {src_w, src_h}, {0, (MyApp.Utils.screen_height() / 2 - 16) |> trunc()},
       {dst_w, dst_h}}

    graph =
      Graph.build()
      # rectangle used for capturing cursor input
      |> rect({MyApp.Utils.screen_width(), MyApp.Utils.screen_height()})
      # rectangle for the "sky"
      |> rect({MyApp.Utils.screen_width(), (MyApp.Utils.screen_height() / 2 + 46) |> trunc()},
        fill: {:image, "sprites/sky_tile.png"}
      )
      # rectangle for the "floor"
      |> rect({MyApp.Utils.screen_width(), (MyApp.Utils.screen_height() / 2) |> trunc()},
        translate: {0, (MyApp.Utils.screen_height() / 2 + 46) |> trunc()},
        fill: {:color, :dark_green}
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
        timer: timer,
        frame: 1,
        previous_frame: 0,
        player_sprite: player_sprite,
        is_walking: false,
        direction: :right
      )
      |> push_graph(graph)

    {:ok, scene}
  end

  # game loop
  def handle_info(:frame, scene) do
    # pattern match out the coordinates
    {{_src_x, _src_y}, {src_w, src_h}, {dst_x, dst_y}, {dst_w, dst_h}} =
      scene.assigns.player_sprite

    frame = scene.assigns.frame
    previous_frame = scene.assigns.previous_frame
    direction = scene.assigns.direction

    new_frame =
      cond do
        frame - previous_frame > 1 and frame < 9 -> frame + 1
        frame == 9 -> 0
        true -> frame + 1
      end

    sprites =
      if scene.assigns.is_walking do
        @walking_sprites
      else
        @idle_sprites
      end

    new_dst_x =
      if scene.assigns.is_walking do
        if direction == :right do
          if dst_x + @step > MyApp.Utils.screen_width() - 48 do
            MyApp.Utils.screen_width() - 48
          else
            dst_x + @step
          end
        else
          if dst_x - @step < 0 do
            0
          else
            dst_x - @step
          end
        end
      else
        dst_x
      end

    IO.inspect(new_dst_x)

    player_sprite = Enum.at(sprites, new_frame) |> elem(0)

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
             {player_sprite, {src_w, src_h}, {new_dst_x, dst_y}, {dst_w, dst_h}}
           ]}
        )
      )

    # push out the graph to the scene
    push_graph(scene, graph)

    # update the state
    scene =
      scene
      |> assign(
        player_sprite: {player_sprite, {src_w, src_h}, {new_dst_x, dst_y}, {dst_w, dst_h}},
        frame: new_frame,
        previous_frame: frame
      )

    {:noreply, scene}
  end

  # releasing d key (stop walking)
  def handle_input({:key, {:key_d, 0, _}} = _event, _context, scene) do
    # update the state to idle
    scene =
      scene
      |> assign(is_walking: false, direction: :right)

    {:noreply, scene}
  end

  # keydown d key (initiate walking)
  def handle_input({:key, {:key_d, _, _}} = _event, _context, scene) do
    # update the state
    scene =
      scene
      |> assign(is_walking: true, direction: :right)

    {:noreply, scene}
  end

  # releasing d key (stop walking)
  def handle_input({:key, {:key_a, 0, _}} = _event, _context, scene) do
    # update the state to idle
    scene =
      scene
      |> assign(is_walking: false, direction: :right)

    {:noreply, scene}
  end

  def handle_input({:key, {:key_a, _, _}} = _event, _context, scene) do
    scene = scene |> assign(is_walking: true, direction: :left)
    {:noreply, scene}
  end

  # handling any other form of input
  # based on provided input classes
  def handle_input(_event, _context, scene) do
    # IO.inspect(event, label: "Input")
    {:noreply, scene}
  end
end
