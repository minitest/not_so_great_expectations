# -*- ruby -*-

require "rubygems"
require "hoe"

Hoe.plugin :isolate
Hoe.plugin :seattlerb
Hoe.plugin :rdoc
Hoe.plugin :cov

Hoe.spec "not_so_great_expectations" do
  developer "Ryan Davis", "ryand-ruby@zenspider.com"

  license "MIT"

  dependency "rubocop", "> 0"
  dependency "rubocop-minitest", "> 0"
  dependency "pry-byebug", "> 0", :development
end

task :rc => :isolate do
  args = ENV["A"]

  system "rubocop #{args}"
end

task :rubocop => :isolate do
  path = ENV["D"] || "spec"

  sh "cd #{path}; git checkout ."

  system "rubocop -A -fq --no-parallel #{path}"
  puts
  puts "Unmatched:"
  puts
  system "rg '\\.to(_not)? ' #{path}"
end

task :parse => :isolate do
  cmd = "ruby-parse -e %p" % [ENV["R"]]

  puts `#{cmd}`.to_s.split.join(" ").gsub(/\bnil\b/, "nil?")
end

# vim: syntax=ruby
