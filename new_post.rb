#!/usr/bin/env ruby

if ARGV.empty?
  puts "./new_post The Title For New Post"
  exit
end

title = ARGV.join(" ")

File.write("_posts/2020-01-01-#{title.gsub(/\s+/, "-").downcase}.markdown", <<-FILE
---
title: #{title}
---
FILE
)
