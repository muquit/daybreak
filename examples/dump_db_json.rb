#!/usr/bin/env ruby
########################################################################
# Dump a daybreak database in pretty print JSON format
# With Claude AI Sonnet 4
# muquit@muquit.com May-23-2025 
########################################################################
require 'daybreak'
require 'json'

class DumpDbJson
  def initialize
    $stdout.sync = true
    $stderr.sync = true
    @db_file = 'example.db'
  end

  def doit
    unless File.exist?(@db_file)
      puts "database file not found: #{@db_file}"
      return
    end
    
    db = Daybreak::DB.new(@db_file)
    
    # collect all data into hash
    data = {}
    db.each do |key, value|
      data[key] = value
    end
    
    # pretty print as JSON
    puts JSON.pretty_generate(data)
    
    db.close
  end
  
  # dump specific key pattern in JSON
  def dump_pattern(pattern)
    unless File.exist?(@db_file)
      puts "database file not found: #{@db_file}"
      return
    end
    
    db = Daybreak::DB.new(@db_file)
    
    # collect matching data
    data = {}
    db.each do |key, value|
      if key.start_with?(pattern)
        data[key] = value
      end
    end
    
    puts JSON.pretty_generate(data)
    
    db.close
  end
  
  # dump with metadata
  def dump_with_meta
    unless File.exist?(@db_file)
      puts "database file not found: #{@db_file}"
      return
    end
    
    db = Daybreak::DB.new(@db_file)
    
    # collect data and metadata
    data = {}
    db.each do |key, value|
      data[key] = value
    end
    
    output = {
      "metadata" => {
        "database_file" => @db_file,
        "file_size" => File.size(@db_file),
        "total_keys" => db.keys.length,
        "exported_at" => Time.now.iso8601
      },
      "data" => data
    }
    
    puts JSON.pretty_generate(output)
    
    db.close
  end
end

if __FILE__ == $0
  dumper = DumpDbJson.new()
  
  case ARGV[0]
  when 'meta'
    dumper.dump_with_meta()
  when nil
    dumper.doit()
  else
    dumper.dump_pattern(ARGV[0])
  end
end
