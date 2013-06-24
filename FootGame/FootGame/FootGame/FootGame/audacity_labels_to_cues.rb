#! /usr/bin/env ruby
#
#

require 'optparse'

options = {
  :separator => "\n"
}

OptionParser.new do |opts|
  opts.banner = "Usage: audacity_labels_to_cues.rb [options]"

  opts.on("-l", "--locale LOCALE", "The locale of the cue and audio") do |locale|
    options[:locale] = locale
  end

  opts.on("-k", "--story-key KEY", "The matching story key in the .strings file") do |story_key|
    options[:story_key] = story_key
  end

  opts.on("-f", "--audio-file FILE", "The filename of the audio file") do |audio_file|
    options[:audio_file] = audio_file
  end

  opts.on("-i", "--input-file FILE", "The exported Audacity label file to convert") do |file|
    options[:input] = file
  end

  opts.on("--mac-delimiter", "Use the mac separator (i.e. \\r)") do
    options[:separator] = "\r"
  end

  opts.on("-o", "--output-file FILE", "The AudioCues file to export to") do |file|
    options[:output] = file
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

end.parse!

input_sequence = []
input_data = {}
index = 0

puts "Processing options #{options.inspect}"

puts "Opening #{options[:input]}"

File.foreach(options[:input], options[:separator]) do |line|
  next if line.chomp.length == 0
  puts "splitting '#{line}'" if options[:verbose]
  items = line.split("\t")
  items[2] = items[2].chomp
  puts "split to: #{items.inspect}" if options[:verbose]

  start_t = items[0].to_f
  end_t = items[1].to_f
  start_index = index
  end_index = index + items[2].scan(/./mu).length - 1
  index += items[2].scan(/./mu).length

  if (items[2].rstrip == "---")
    puts "end hit" if options[:verbose]
    end_t = start_t
    start_index = 0
    end_index = 0
  end

  entry = {
    :start => start_t,
    :end => end_t,
    :start_index => start_index,
    :end_index => end_index,
    :note => items[2],
  }
  unique_num = 0

  while(input_data.has_key?("#{items[2].rstrip}#{unique_num if unique_num > 0}"))
    unique_num += 1
  end

  new_key = "#{items[2].rstrip}#{unique_num if unique_num > 0}"
  puts "insert: #{new_key} => #{entry}" if options[:verbose]

  input_data[new_key] = entry
  input_sequence << new_key
end

puts "Writing #{options[:output]}"

File.open(options[:output], "w") do |file|
  puts "Writing HEADER" if options[:verbose]
  file.write(<<-HEADER
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>storyKey</key>
	<string>#{options[:story_key]}</string>
	<key>audioFile</key>
	<string>#{options[:audio_file]}</string>
	<key>locale</key>
	<string>#{options[:locale]}</string>
HEADER
)

  input_sequence.each do |key|
      data = input_data[key]
      puts "Writing #{key}" if options[:verbose]
    file.write(<<-ENTRY
	<key>#{key}</key>
	<dict>
		<key>start</key>
		<real>#{data[:start]}</real>
		<key>duration</key>
		<real>#{data[:end] - data[:start]}</real>
		<key>start_index</key>
		<integer>#{data[:start_index]}</integer>
		<key>end_index</key>
		<integer>#{data[:end_index]}</integer>
	</dict>
ENTRY
)
  end

  puts "Writing FOOTER" if options[:verbose]
  file.write(<<-FOOTER
</dict>
</plist>
FOOTER
)
end