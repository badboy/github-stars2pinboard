#!/usr/bin/env ruby
# encoding: utf-8

# "THE BEER-WARE LICENSE" (Revision 42):
# badboy_ wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return. Jan-Erik Rediger

require 'octokit'
require 'pinboard'

Octokit.netrc = true

pinclient = Pinboard::Client.new token: ARGV[1]

starred = Octokit.starred

starred.each do |star|
  name = star["name"]
  lang = (star["language"]||'').downcase
  desc = star["description"]
  url  = star["html_url"]

  status = pinclient.add_post({
    replace:     "no",
    url:         url,
    description: name,
    extended:    desc,
    tags:        "githubstars #{lang}"
  })

  puts "#{name}: #{status}"
end
