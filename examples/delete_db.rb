#!/usr/bin/env ruby
########################################################################
# Delete records from daybreak database
# With Claude AI Sonnet 4
# muquit@muquit.com May-23-2025 
########################################################################
require 'daybreak'

class DeleteDb
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
    
    puts "keys before deletion: #{db.keys.length}"
    
    # delete specific user
    if db.key?('user:3')
      db.delete('user:3')
      puts "deleted user:3"
    end
    
    # delete debug setting
    if db.key?('settings:debug')
      db.delete('settings:debug')
      puts "deleted settings:debug"
    end
    
    puts "keys after deletion: #{db.keys.length}"
    
    db.flush
    db.close
  end
  
  # delete specific key
  def delete_key(key)
    unless File.exist?(@db_file)
      puts "database file not found: #{@db_file}"
      return
    end
    
    db = Daybreak::DB.new(@db_file)
    
    if db.key?(key)
      db.delete(key)
      puts "deleted: #{key}"
    else
      puts "key not found: #{key}"
    end
    
    db.flush
    db.close
  end
  
  # delete keys by pattern
  def delete_pattern(pattern)
    unless File.exist?(@db_file)
      puts "database file not found: #{@db_file}"
      return
    end
    
    db = Daybreak::DB.new(@db_file)
    
    keys_to_delete = []
    db.each do |key, value|
      if key.start_with?(pattern)
        keys_to_delete << key
      end
    end
    
    puts "found #{keys_to_delete.length} keys matching: #{pattern}"
    
    keys_to_delete.each do |key|
      db.delete(key)
      puts "deleted: #{key}"
    end
    
    db.flush
    db.close
  end
end

if __FILE__ == $0
  deleter = DeleteDb.new()
  
  if ARGV.length == 1
    if ARGV[0].include?(':')
      deleter.delete_key(ARGV[0])
    else
      deleter.delete_pattern(ARGV[0])
    end
  else
    deleter.doit()
  end
end
