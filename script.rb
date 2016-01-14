# require 'bundler/setup'
# Bundler.require :default, :minigame

require 'data_mapper'
require 'dm-mysql-adapter'
require 'dm-serializer'
require 'dm-types'
require 'json'

require_relative './minigame_creator'

type = ENV['GAME_TYPE']
map = ENV['MAP_NAME']
server = ENV['SERVER_NAME']
minigame_creator = MinigameCreator.new(server, map)

if type == 'bedwars' || type == 'ragemode' || type == 'paintball' ||
   type == 'hungergames'

  minigame_creator.copy_plugins(type)
  minigame_creator.copy_map
  minigame_creator.set_server_properties
  minigame_creator.start_server
  minigame_creator.reset_server

end
