require File.expand_path(File.dirname(__FILE__)) + '/test_helper.rb'
require 'benchmark'

#inspired by moneta benchmarks
def single(instance, &blk)
  data = uniform
  samples = []
  data.each do |i|
    samples << Benchmark.measure do
      if blk.nil?
        instance[i] = i
      else
        blk.call i
      end
    end.real * 1000
  end
  instance.clear
  samples
end

def multi(instance, &blk)
  data = uniform

  samples = Benchmark.measure do
    data.each do |i|
      if blk.nil?
        instance[i] = i
      else
        blk.call i
      end
    end
  end.real * 1000
  instance.clear
  samples
end

DICT = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890".freeze
def uniform
  min, max = 3, 1024
  1000.times.map do
    n = rand(max - min) + max
    (1..n).map { DICT[rand(DICT.length)] }.join
  end
end

def run(instance, message = '', &blk)
  puts "Running benchmarks for #{instance.class.name} #{message}"
  single instance, &blk
  report single(instance, &blk)
  multi instance, &blk
  report multi(instance, &blk)
end

def report(samples)
  if Array === samples
    samples.sort!
    total  = samples.inject(:+)
    mean   = total / samples.length
    stddev = Math.sqrt(samples.inject(0) {|m, s| m += (s - mean) ** 2 } / samples.length)
    puts "#{samples.length} samples, average time: #{mean.round(4)} ms, std. dev: #{stddev.round(4)} ms"
    puts "95% < #{samples.slice((samples.length * 0.95).to_i).round(4)} ms"
  else
    puts "Total time: #{samples.round(4)} ms"
    puts "=" * 64
  end
end

run Hash.new
db = Daybreak::DB.new DB_PATH
run db
run db, 'with sync' do |i|
  db[i] = i
  db.sync
end
db.close
