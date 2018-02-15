#!/usr/bin/env ruby

DEBUG_LOG = ARGV.include?('--debug')

def log_info(str)
  puts str
end

def log_debug(str)
  log_info(str) if DEBUG_LOG
end

def configure_tags(filename, artist, album)
  command = "mid3v2 -a \"#{artist}\" -A \"#{album}\" \"#{filename}\""
  log_debug command
  result = system(command)
  raise "Processing File Error" unless result == true
end

input_folder = ARGV[0]
artist = ARGV[1]
album = ARGV[2]

log_debug 'Starting program...'

log_debug "input_folder=#{ARGV[0]}"
log_debug "artist=#{ARGV[1]}"
log_debug "album=#{ARGV[2]}"

raise 'Input not found' unless Dir.exist?(input_folder)
raise 'Invalid artist' if artist.empty?
raise 'Invalid album' if album.empty?

should_fail = false

Dir["#{input_folder}/*"]
  .select {|f| !File.directory? f}
  .each do |f|
    begin
      configure_tags(f, artist, album)
    rescue Exception => e
      log_debug e
      log_info f
      should_fail = true
    end
  end

raise 'Program Completed with errors' if should_fail