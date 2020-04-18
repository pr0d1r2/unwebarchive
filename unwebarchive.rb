#!/usr/bin/env ruby
#
# Mac OS X webarchive is a binary format of a plist file. You can extract the contents manually:
#  1. convert the plist file into XML by "plutil -convert xml1 file.webarchive"
#  2. parse the resulted XML file by some XML parser
#  3. decode "WebResourceData" by Base64.decode64(data) in each key
#  4. save the decoded content into a file indicated by "WebResourceData"
# Thankfully, the plist library can take care of annoying steps 2 and 3.
#
# Preparation:
#  % gem install plist
#
# Usage:
#  % unwebarchive.rb filename.webarchive
#
# Result:
#  You'll find the extracted contents under the 'filename/' directory.
#

require 'rubygems'
require_relative 'lib/unwebarchive'

webarchive = ARGV.shift
exportdir = File.basename(webarchive, ".webarchive")

UnWebarchive.new(webarchive, exportdir)
