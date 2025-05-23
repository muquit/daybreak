########################################################################
# Safely open daybreak database for reating or writing by checking
# database size and space available.
#
# This is specific to Linux/Mac as df is used to check space. 
#
# With assistance from Claude AI 3.7 Sonnet.
# Interesting methods:
#    SafeDaybreak.open_to_write()
#    SafeDaybreak.open_to_read()
#    etc.
# muquit@muquit.com May-23-2025 
########################################################################
require 'daybreak'

class SafeDaybreak
  class InsufficientSpaceError < StandardError; end
  
  # Constants for consistency
  DEFAULT_MIN_MB = 10
  DEFAULT_MULTIPLIER = 1.5

  def self.open_to_write(db_path, options = {})
    return open_new_database(db_path, options) unless File.exist?(db_path)
    
    db_size_bytes = File.size(db_path)
    db_size_mb = db_size_bytes / (1024.0 * 1024.0)
    free_space_mb = get_free_space_mb(db_path)
    
    # Calculate required space
    min_required_mb = calculate_required_space(db_size_mb, options)
    
    if free_space_mb < min_required_mb
      # Improved message handling for small databases
      if db_size_mb < 1
        # Show in KB for very small databases
        db_size_kb = (db_size_bytes / 1024.0).round(2)
        raise InsufficientSpaceError, 
          "Database is #{db_size_kb}KB, only #{free_space_mb}MB free. " \
          "Need at least #{min_required_mb}MB free space."
      else
        raise InsufficientSpaceError, 
          "Database is #{db_size_mb.round(2)}MB, only #{free_space_mb}MB free. " \
          "Need at least #{min_required_mb}MB free space."
      end
    end
    
    return Daybreak::DB.new(db_path)
  end

  def self.open_to_writeX(db_path, options = {})
    return open_new_database(db_path, options) unless File.exist?(db_path)
    
    db_size_mb = File.size(db_path) / (1024.0 * 1024.0)
    free_space_mb = get_free_space_mb(db_path)
    
    # Calculate required space
    min_required_mb = calculate_required_space(db_size_mb, options)
    
    if free_space_mb < min_required_mb
      raise InsufficientSpaceError, 
        "Database is #{db_size_mb.round(2)}MB, only #{free_space_mb}MB free. " \
        "Need at least #{min_required_mb}MB free space."
    end
    
    return Daybreak::DB.new(db_path)
  end

  def self.database_frozen?(db_path)
    return false if !File.exist?(db_path)
    begin
      return ! SafeDaybreak.safe_to_open_database?(db_path)
    rescue => e
      return true
    end
    return false
  end  
  def self.open_to_read(db_path)
    if !File.exist?(db_path)
      raise "Database not found: #{db_path}"
    end
    
    # Still check for minimal space even for reading
    free_space_mb = get_free_space_mb(db_path)
    if free_space_mb < 1  # Need at least 1MB for temp files
      raise InsufficientSpaceError, "Insufficient space even for read-only access"
    end
    
    return Daybreak::DB.new(db_path)
  end

  def self.safe_to_open_database?(db_path)
    return true unless File.exist?(db_path)
    
    db_size_mb = File.size(db_path) / (1024.0 * 1024.0)
    free_space_mb = get_free_space_mb(File.dirname(db_path))
    required_space_mb = calculate_required_space(db_size_mb)
    return free_space_mb >= required_space_mb
  end
  
  private
  
  def self.calculate_required_space(db_size_mb, options = {})
    multiplier = options[:safety_multiplier] || DEFAULT_MULTIPLIER
    min_absolute_mb = options[:min_absolute_mb] || DEFAULT_MIN_MB
    
    # Calculate based on database size
    size_based_requirement = (db_size_mb * multiplier).ceil
    
    # Return the larger of the two requirements
    return [size_based_requirement, min_absolute_mb].max
  end
  
  def self.open_new_database(db_path, options)
    # For new databases, just check minimum space
    free_space_mb = get_free_space_mb(db_path)
    min_mb = options[:min_absolute_mb] || DEFAULT_MIN_MB
    
    if free_space_mb < min_mb
      raise InsufficientSpaceError,
        "Cannot create new database: only #{free_space_mb}MB free, need #{min_mb}MB"
    end
    
    return Daybreak::DB.new(db_path)
  end
  
  def self.get_free_space_mb(path)
    dir = File.dirname(path)
    output = `df -m "#{dir}" 2>/dev/null | tail -1`
    
    # Better error handling
    if output.empty?
      raise "Unable to determine free space for: #{dir}"
    end
    
    return output.split[3].to_i
  end
end

# Test
if __FILE__ == $0
  begin
    db_path = "./example.db"
    
    puts "Checking if safe to open..."
    if SafeDaybreak.safe_to_open_database?(db_path)
      puts "Safe to open!"
      
      # Test write
      db = SafeDaybreak.open_to_write(db_path)
      puts "Opened for writing"
      db.close
      
      # Test read
      db = SafeDaybreak.open_to_read(db_path)
      puts "Opened for reading"
      db.close
    else
      puts "Not safe to open database"
    end
  rescue SafeDaybreak::InsufficientSpaceError => e
    puts "Space error: #{e.message}"
  rescue => e
    puts "Error: #{e.message}"
  end
end
