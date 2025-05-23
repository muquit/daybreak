#!/usr/bin/env ruby
########################################################################
# Database maintenance for daybreak database
# With Claude AI Sonnet 4
# muquit@muquit.com May-23-2025 
########################################################################
require 'daybreak'

class Maintenance
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
    
    # show database info
    show_info
    
    # compact database
    compact_db
    
    # verify integrity
    verify_integrity
  end
  
  # show database statistics
  def show_info
    db = Daybreak::DB.new(@db_file)
    
    puts "database information:"
    puts "-" * 30
    puts "file: #{@db_file}"
    puts "file size: #{File.size(@db_file)} bytes"
    puts "total keys: #{db.keys.length}"
    
    # count by prefix
    prefixes = {}
    db.each do |key, value|
      prefix = key.split(':').first
      prefixes[prefix] = (prefixes[prefix] || 0) + 1
    end
    
    puts "key distribution:"
    prefixes.each do |prefix, count|
      puts "  #{prefix}: #{count}"
    end
    
    db.close
  end
  
  # compact database to remove deleted entries
  def compact_db
    puts "\ncompacting database..."
    
    original_size = File.size(@db_file)
    
    db = Daybreak::DB.new(@db_file)
    db.compact
    db.close
    
    new_size = File.size(@db_file)
    saved = original_size - new_size
    
    puts "compaction completed"
    puts "original size: #{original_size} bytes"
    puts "new size: #{new_size} bytes"
    puts "space saved: #{saved} bytes"
  end
  
  # verify database integrity
  def verify_integrity
    puts "\nverifying integrity..."
    
    begin
      db = Daybreak::DB.new(@db_file)
      
      # try to read all keys
      key_count = 0
      error_count = 0
      
      db.each do |key, value|
        begin
          key_count += 1
          # basic validation
          raise "nil key" if key.nil?
          raise "empty key" if key.empty?
        rescue => e
          puts "error with key #{key}: #{e.message}"
          error_count += 1
        end
      end
      
      puts "verification completed"
      puts "total keys checked: #{key_count}"
      puts "errors found: #{error_count}"
      
      if error_count == 0
        puts "database integrity: OK"
      else
        puts "database integrity: ERRORS FOUND"
      end
      
      db.close
      
    rescue => e
      puts "critical error: #{e.message}"
      puts "database may be corrupted"
    end
  end
  
  # backup database
  def backup_db
    unless File.exist?(@db_file)
      puts "database file not found: #{@db_file}"
      return
    end
    
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    backup_file = "#{@db_file}.backup_#{timestamp}"
    
    FileUtils.cp(@db_file, backup_file)
    puts "database backed up to: #{backup_file}"
  end
  
  # clean old entries (example: remove inactive users)
  def cleanup_inactive
    unless File.exist?(@db_file)
      puts "database file not found: #{@db_file}"
      return
    end
    
    db = Daybreak::DB.new(@db_file)
    
    deleted_count = 0
    keys_to_delete = []
    
    db.each do |key, value|
      if key.start_with?('user:') && value.is_a?(Hash) && !value[:active]
        keys_to_delete << key
      end
    end
    
    keys_to_delete.each do |key|
      db.delete(key)
      deleted_count += 1
    end
    
    puts "cleaned up #{deleted_count} inactive users"
    
    db.flush
    db.close
  end
end

if __FILE__ == $0
  maintenance = Maintenance.new()
  
  case ARGV[0]
  when 'backup'
    maintenance.backup_db
  when 'cleanup'
    maintenance.cleanup_inactive
  when 'info'
    maintenance.show_info
  when 'compact'
    maintenance.compact_db
  when 'verify'
    maintenance.verify_integrity
  else
    maintenance.doit()
  end
end
