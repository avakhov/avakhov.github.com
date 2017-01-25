require 'benchmark'

c = 60_000
name = "head"
re = /#{name}-tail-\d{4}-\d{2}/
string = "head-tail-2012-12"
i = 0

Benchmark.bm do |bm|
  bm.report { c.times { i += 1 if string =~ /#{name}-tail-\d{4}-\d{2}/ } }
  bm.report { c.times { i += 1 if string =~ /#{name}-tail-\d{4}/ } }
  bm.report { c.times { i += 1 if string =~ /#{name}-tail/ } }
  bm.report { c.times { i += 1 if string =~ re } }
end
puts "i: #{i}"
