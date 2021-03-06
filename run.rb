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
  log_debug "Processing File #{filename}"
  log_debug command
  result = system(command)
  raise "Processing File Error" unless result == true
end

def validate_tags(filename, artist, album)
  command = "mid3v2 \"#{filename}\""
  log_debug "Verifying File #{filename}"
  log_debug command
  output = `#{command}`
  raise "Artist not found on file" unless output.include?("TPE1=#{artist}")
  raise "Album not found on file" unless output.include?("TALB=#{album}")
end

input_folder = ARGV[0]
artist = ARGV[1]
album = ARGV[2]

log_debug 'Starting program...'

log_debug "input_folder=#{input_folder}"
log_debug "artist=#{artist}"
log_debug "album=#{album}"

raise 'Input not found' unless Dir.exist?(input_folder)
raise 'Invalid artist' if artist.empty?
raise 'Invalid album' if album.empty?

should_fail = false

Dir["#{input_folder}/**/*"]
  .select {|f| !File.directory? f}
  .each do |f|
    begin
      configure_tags(f, artist, album)
      validate_tags(f, artist, album)
    rescue Exception => e
      log_debug e
      log_info f
      should_fail = true
    end
  end

raise 'Program Completed with errors' if should_fail