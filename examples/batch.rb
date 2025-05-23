#!/usr/bin/env ruby
########################################################################
# Batch operations for daybreak database
# With Claude AI Sonnet 4
# muquit@muquit.com May-23-2025 
########################################################################
require 'daybreak'

class Batch
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
    
    # batch insert new users
    batch_insert_users(db)
    
    # batch update prices
    batch_update_prices(db)
    
    # batch read and filter
    batch_read_active_users(db)
    
    db.flush
    db.close
  end
  
  # insert multiple users at once
  def batch_insert_users(db)
    users = {
      'user:10' => { name: 'Alice Brown', email: 'alice@example.com', age: 28, active: true },
      'user:11' => { name: 'Charlie Davis', email: 'charlie@example.com', age: 32, active: true },
      'user:12' => { name: 'Diana White', email: 'diana@example.com', age: 29, active: false }
    }
    
    users.each do |key, value|
      db[key] = value
    end
    
    puts "batch inserted #{users.length} users"
  end
  
  # update all product prices
  def batch_update_prices(db)
    updated_count = 0
    
    db.each do |key, value|
      if key.start_with?('product:') && value.is_a?(Hash) && value[:price]
        value[:price] = (value[:price] * 1.1).round(2)  # 10% increase
        db[key] = value
        updated_count += 1
      end
    end
    
    puts "batch updated #{updated_count} product prices"
  end
  
  # read all active users
  def batch_read_active_users(db)
    active_users = {}
    
    db.each do |key, value|
      if key.start_with?('user:') && value.is_a?(Hash) && value[:active]
        active_users[key] = value
      end
    end
    
    puts "found #{active_users.length} active users:"
    active_users.each do |key, user|
      puts "  #{key}: #{user[:name]} (#{user[:email]})"
    end
  end
  
  # import from hash
  def import_data(data_hash)
    unless File.exist?(@db_file)
      puts "database file not found: #{@db_file}"
      return
    end
    
    db = Daybreak::DB.new(@db_file)
    
    data_hash.each do |key, value|
      db[key] = value
    end
    
    puts "imported #{data_hash.length} records"
    
    db.flush
    db.close
  end
  
  # export to hash
  def export_pattern(pattern)
    unless File.exist?(@db_file)
      puts "database file not found: #{@db_file}"
      return {}
    end
    
    db = Daybreak::DB.new(@db_file)
    
    exported = {}
    db.each do |key, value|
      if key.start_with?(pattern)
        exported[key] = value
      end
    end
    
    puts "exported #{exported.length} records matching: #{pattern}"
    
    db.close
    exported
  end
end

if __FILE__ == $0
  batch = Batch.new()
  
  if ARGV.length == 1 && ARGV[0] == 'export'
    result = batch.export_pattern('user:')
    puts result.inspect
  else
    batch.doit()
  end
end
