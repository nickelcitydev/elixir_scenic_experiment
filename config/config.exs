# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

# connect the app's asset module to Scenic
config :scenic, :assets,
  module: MyApp.Assets,
  alias: []

# Configure the main viewport for the Scenic application
config :my_app, :viewport,
  name: :main_viewport,
  size: {800, 600},
  theme: :dark,
  default_scene: MyApp.Scene.Home,
  drivers: [
    [
      module: Scenic.Driver.Local,
      name: :local,
      window: [resizeable: false, title: "my_app"],
      on_close: :stop_system
    ]
  ]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "prod.exs"
