# require 'bundler/setup'
# Bundler.require :default, :minigame
# encoding: utf-8

require 'data_mapper'
require 'dm-mysql-adapter'
require 'dm-serializer'
require 'dm-types'
require 'json'
require 'logger'

require_relative 'minigame_creator'
require_relative 'server_model'

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

options = nil
begin
  logger.debug 'Started parsing options.json'
  options = JSON.parse(open('./json/options.json').read, symbolize_names: true)
rescue => e
  logger.fatal 'Could not parse the options file located at ./json/options.json'
  logger.fatal 'See the stacktrace for more information'
  logger.fatal e
end

type = ENV['GAME_TYPE']
map = ENV['MAP_NAME']
server = ENV['SERVER_NAME']
minigame_creator = MinigameCreator.new(server, map, type, options)

if %w[bedwars ragemode paintball hungergames].include?(type)

  minigame_creator.copy_plugins(type)
  minigame_creator.copy_map
  minigame_creator.set_server_properties
  minigame_creator.save_json
  minigame_creator.start_server
  minigame_creator.reset_server

end
