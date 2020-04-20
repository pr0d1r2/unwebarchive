# frozen_string_literal: true

require 'plist'
require 'fileutils'
require 'tmpdir'

# Allows to list all resources contained in "*.webarchive" file
class Webarchive
  def initialize(file)
    @plist = plist_data(file)
  end

  def self.resources(file)
    new(file).resources
  end

  def resources
    main_resource_hash.merge(resources_hash)
  end

  private

  def main_resource_hash
    { 'file:///index.html' => main_data }
  end

  def main_data
    data = @plist['WebMainResource']['WebResourceData'].read
    data.gsub!(%r{file:///}, './')
    data
  end

  def resources_hash
    Hash[
      @plist['WebSubresources'].map do |res|
        [res['WebResourceURL'], res['WebResourceData'].read]
      end
    ]
  end

  def plist_data(file)
    Dir.mktmpdir do |dir|
      tmpfile = File.expand_path(File.basename(file), dir)
      FileUtils.cp(file, tmpfile)
      system("plutil -convert xml1 #{tmpfile}")
      Plist.parse_xml(File.read(tmpfile))
    end
  end
end
