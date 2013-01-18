#!/usr/bin/env ruby
# encoding: utf-8

# "THE BEER-WARE LICENSE" (Revision 42):
# badboy_ wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return. Jan-Erik Rediger

require 'bundler/setup'
require 'octokit'
require 'pinboard'
require 'digest/sha1'

CACHE_FILE = "./cache"
Octokit.netrc = true

pinclient = Pinboard::Client.new token: ARGV[0]

octo = Octokit::Client.new auto_traversal: true
starred = octo.starred

def hash name, lang, url
  Digest::SHA1.hexdigest "%s:%s:%s" % [name, lang, url]
end

cache = []

if File.exist?(CACHE_FILE)
  cache = File.readlines(CACHE_FILE).map(&:chomp)
end

cache_file = File.open(CACHE_FILE, "w")
i = 1
total = starred.size
starred.each do |star|
  name = star["name"]
  lang = (star["language"]||'').downcase
  desc = star["description"]
  url  = star["html_url"]

  print "#{i.to_s.rjust(total.to_s.size)}/#{total} #{name}: "

  h = hash name, lang, url
  cache_file.puts h
  if cache.include?(h)
    status = "skipped"
  else
    status = pinclient.add_post({
      replace:     "no",
      url:         url,
      description: name,
      extended:    desc,
      tags:        "githubstars #{lang}"
    })
  end

  puts status
  i += 1
end
cache_file.close
