#!/usr/bin/env ruby
########################################################################
# Create and populate a daybreak database
# With Claude AI Sonnet 4
# muquit@muquit.com May-23-2025 
########################################################################
require 'daybreak'

class CreateDb
  def initialize
    $stdout.sync = true
    $stderr.sync = true
    @db_file = 'example.db'
  end

  def doit
    db = Daybreak::DB.new(@db_file)
    
    # create users
    db['user:1'] = { name: 'John Doe', email: 'john@example.com', age: 30, active: true }
    db['user:2'] = { name: 'Jane Smith', email: 'jane@example.com', age: 25, active: true }
    db['user:3'] = { name: 'Bob Wilson', email: 'bob@example.com', age: 35, active: false }
    
    # create settings
    db['settings:theme'] = 'dark'
    db['settings:language'] = 'en'
    db['settings:debug'] = false
    
    # create products
    db['product:1'] = { name: 'Laptop', price: 999.99, category: 'Electronics', stock: 10 }
    db['product:2'] = { name: 'Mouse', price: 29.99, category: 'Electronics', stock: 50 }
    db['product:3'] = { name: 'Desk', price: 299.99, category: 'Furniture', stock: 5 }
    
    # create counters
    db['counter:users'] = 3
    db['counter:products'] = 3
    db['counter:orders'] = 0
    
    # create company info
    db['company:info'] = {
      name: 'Tech Corp',
      founded: 2010,
      employees: 100,
      revenue: 5000000
    }
    
    db.flush
    puts "database created: #{@db_file}"
    puts "total keys: #{db.keys.length}"
    
    db.close
  end
end

if __FILE__ == $0
  CreateDb.new().doit()
end
