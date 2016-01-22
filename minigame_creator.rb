# This class is responsible for the Minigame Server setup
# encoding: utf-8
class MinigameCreator
  def initialize(server, map, type)
    @server_name = server
    @map_name = map
    @game_type = type

    @gsutil_cp = 'gsutil cp -r'
    @bucket = 'gs://kwstudios-main-bucket'

    @destination_path = '/home/minecraft/bungeecord'
  end

  def copy_plugins(folder)
    `#{@gsutil_cp} #{@bucket}/minecraft/plugins/minigames/#{
    folder}/plugins-backup.zip #{@destination_path}/#{@server_name}/plugins/`

    `unzip #{@destination_path}/#{@server_name}/plugins/plugins-backup.zip -d #{
    @destination_path}/#{@server_name}/plugins/`

    `rm #{@destination_path}/#{@server_name}/plugins/plugins-backup.zip`
  end

  # rubocop:disable MethodLength
  def copy_map
    # Copy minigame map
    `#{@gsutil_cp} #{@bucket}/minecraft/backup/worlds/minigames/archived/#{
    @map_name}.zip #{@destination_path}/#{@server_name}/`

    `unzip #{@destination_path}/#{@server_name}/#{@map_name}.zip -d #{
    @destination_path}/#{@server_name}/`

    `rm #{@destination_path}/#{@server_name}/#{@map_name}.zip`

    # Copy lobby map
    lobby_map = "#{@game_type.capitalize}_Lobby"
    `#{@gsutil_cp} #{@bucket}/minecraft/backup/worlds/minigames/archived/#{
    lobby_map}.zip #{@destination_path}/#{@server_name}/`

    `unzip #{@destination_path}/#{@server_name}/#{lobby_map}.zip -d #{
    @destination_path}/#{@server_name}/`

    `rm #{@destination_path}/#{@server_name}/#{lobby_map}.zip`
  end

  # rubocop:disable MethodLength
  def set_server_properties
    line_array = []
    properties_path = "#{@destination_path}/#{@server_name}/server.properties"
    File.foreach(properties_path).with_index do |line, line_num|
      puts "#{line_num}: #{line}"
      formatted_line = line.strip
      if formatted_line.start_with?('level-name')
        splitted_line = formatted_line.split('=', 2)
        splitted_line[1] = @map_name
        formatted_line = "#{splitted_line[0]}=#{splitted_line[1]}"
      end
      line_array << formatted_line
    end

    open(properties_path, 'w') do |f|
      line_array.each do |line|
        f << "#{line}\n"
      end
    end
  end

  def save_json
    json_hash = { game_type: @game_type, map_name: @map_name,
                  server_name: @server_name }
    json_string = JSON.generate(json_hash)

    json_file = "#{@destination_path}/#{@server_name}/GameValues.json"
    open(json_file, 'w') do |f|
      f << json_string
    end
  end

  def start_server
    `#{@destination_path}/#{@server_name}/start.sh`
  end

  def reset_server
    `rm -r #{@destination_path}/#{@server_name}/#{@map_name}`

    lobby_map = "#{@game_type.capitalize}_Lobby"
    `rm -r #{@destination_path}/#{@server_name}/#{lobby_map}`

    `rm -r #{@destination_path}/#{@server_name}/plugins/*`
    `rm #{@destination_path}/#{@server_name}/GameValues.json`

    minecraft_server = MinecraftServer.get(@server_name)
    minecraft_server.is_used = false
    minecraft_server.save
  end
end
