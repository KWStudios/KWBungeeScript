# This class is responsible for the Minigame Server setup
class MinigameCreator
  def initialize(server, map)
    @server_name = server
    @map_name = map

    @gsutil_cp = 'gsutil -m cp -r'
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

  def copy_map
    `#{@gsutil_cp} #{@bucket}/minecraft/backup/worlds/minigames/archived/
    #{@map_name}.zip #{@destination_path}/#{@server_name}/`

    `unzip #{@destination_path}/#{@server_name}/#{@map_name}.zip -d
    #{@destination_path}/#{@server_name}/`

    `rm #{@destination_path}/#{@server_name}/#{@map_name}.zip`
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

  def start_server
    `#{@destination_path}/#{@server_name}/start.sh`
  end

  def reset_server
    `rm -r #{@destination_path}/#{@server_name}/#{@map_name}`
    `rm -r #{@destination_path}/#{@server_name}/plugins/*`
  end
end
