# frozen_string_literal: true

require 'plist'

# Allows to list all resources contained in "*.webarchive" file
class Webarchive
  def initialize(file)
    system("plutil -convert xml1 #{file}")
    @plist = Plist.parse_xml(File.read(file))
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
end
