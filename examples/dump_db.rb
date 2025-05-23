#!/usr/bin/env ruby
########################################################################
# Dump a daybreak database
# With Claude AI Sonnet 4
# muquit@muquit.com May-23-2025 
########################################################################
require 'daybreak'

class DumpDb
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
    
    puts "database: #{@db_file}"
    puts "total keys: #{db.keys.length}"
    puts "-" * 50
    
    # dump all data
    db.each do |key, value|
      puts "#{key}: #{value.inspect}"
    end
    
    db.close
  end
  
  # dump specific key pattern
  def dump_pattern(pattern)
    unless File.exist?(@db_file)
      puts "database file not found: #{@db_file}"
      return
    end
    
    db = Daybreak::DB.new(@db_file)
    
    puts "dumping keys matching: #{pattern}"
    puts "-" * 50
    
    db.each do |key, value|
      if key.start_with?(pattern)
        puts "#{key}: #{value.inspect}"
      end
    end
    
    db.close
  end
end

if __FILE__ == $0
  dumper = DumpDb.new()
  
  if ARGV.length > 0
    dumper.dump_pattern(ARGV[0])
  else
    dumper.doit()
  end
end
