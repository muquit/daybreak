#!/usr/bin/env ruby
########################################################################
# Update records in daybreak database
# With Claude AI Sonnet 4
# muquit@muquit.com May-23-2025 
########################################################################
require 'daybreak'

class UpdateDb
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
    
    # update user age
    if db.key?('user:1')
      user = db['user:1']
      user[:age] = 31
      user[:last_updated] = Time.now
      db['user:1'] = user
      puts "updated user:1 age and timestamp"
    end
    
    # toggle user active status
    if db.key?('user:3')
      user = db['user:3']
      user[:active] = !user[:active]
      db['user:3'] = user
      puts "toggled user:3 active status to: #{user[:active]}"
    end
    
    # update settings
    if db.key?('settings:theme')
      current_theme = db['settings:theme']
      new_theme = current_theme == 'dark' ? 'light' : 'dark'
      db['settings:theme'] = new_theme
      puts "changed theme from #{current_theme} to #{new_theme}"
    end
    
    # increment counter
    if db.key?('counter:orders')
      db['counter:orders'] = db['counter:orders'] + 1
      puts "incremented orders counter to: #{db['counter:orders']}"
    end
    
    # update product stock
    if db.key?('product:2')
      product = db['product:2']
      product[:stock] = product[:stock] - 5
      db['product:2'] = product
      puts "reduced product:2 stock to: #{product[:stock]}"
    end
    
    db.flush
    puts "updates completed"
    
    db.close
  end
  
  # update specific key
  def update_key(key, field, value)
    unless File.exist?(@db_file)
      puts "database file not found: #{@db_file}"
      return
    end
    
    db = Daybreak::DB.new(@db_file)
    
    if db.key?(key)
      record = db[key]
      if record.is_a?(Hash)
        record[field.to_sym] = value
        db[key] = record
        puts "updated #{key}.#{field} = #{value}"
      else
        puts "record #{key} is not a hash"
      end
    else
      puts "key not found: #{key}"
    end
    
    db.flush
    db.close
  end
end

if __FILE__ == $0
  updater = UpdateDb.new()
  
  if ARGV.length == 3
    updater.update_key(ARGV[0], ARGV[1], ARGV[2])
  else
    updater.doit()
  end
end
