#!/usr/bin/env ruby

if ARGV.empty?
  puts "./new_post The Title For New Post"
  exit
end

title = ARGV.join(" ")
filename = "_posts/2020-01-01-#{title.gsub(/\s+/, "-").downcase}.markdown"

File.write(filename, <<-FILE
---
title: #{title}
image: /assets/#{Time.now.year}/
---
FILE
)

`git add #{filename}`
