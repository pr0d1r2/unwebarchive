# frozen_string_literal: true

require 'fileutils'
require 'plist'
require_relative 'plutil'

class UnWebarchive
  def initialize(webarchive, exportdir)
    @file = webarchive
    @dir  = exportdir
  end

  def self.extract(webarchive, exportdir)
    new(webarchive, exportdir).extract
  end

  def extract
    prepare_exportdir
    parse_webarchive
  end

  def prepare_exportdir
    if File.exist?(@dir)
      print "Override existing export directory '#{@dir}' [Yes/No]? "
      exit 1 unless gets.chomp[/^y(es)?$/i]
    end
    FileUtils.mkdir_p(@dir)
    FileUtils.cp(@file, @dir)
  end

  def parse_webarchive
    FileUtils.cd(@dir) do
      system("plutil -convert xml1 #{@file}")
      plist = Plist.parse_xml(File.read(@file))
      file = plist['WebMainResource']['WebResourceURL']
      data = plist['WebMainResource']['WebResourceData'].read
      data.gsub!(%r{file:///}, './')
      export('file:///index.html', data)
      plist['WebSubresources'].each do |res|
        file = res['WebResourceURL']
        data = res['WebResourceData'].read
        export(file, data)
      end
    end
  end

  def export(resource_uri, resource_data)
    if resource_uri[/^file:/]
      name = resource_uri.sub('file:///', '')
      write_file(name, resource_data)
    elsif resource_uri[/^http/]
      name = resource_uri.sub(%r{^http.*\://}, '')
      write_file(name, resource_data)
    else
      puts "[ERR] skipping #{resource_uri}"
    end
  end

  def write_file(name, resource_data)
    puts "[INFO] Writing '#{@dir}/#{name}' ..."
    dirname = File.dirname(name)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    File.open(name, 'w') do |file|
      file.print fix_paths(name, resource_data)
    end
  end

  def fix_paths(name, resource_data)
    exempted_formats = ['.png', '.jpg', '.gif', '.svg', '.woff', '.woff2', '.aspx', '.js']
    if File.extname(name.split('?').first) == '.html'
      puts "[INFO] Fixing paths on '#{@dir}/#{name}' ..."
      resource_data.gsub!(%r{href="[^=]*http[^=]*://}, 'href="')
      resource_data.gsub!(%r{src="[^=]*http[^=]*://}, 'src="')
    elsif File.extname(name.split('?').first) == '.css'
      resource_data.gsub!(%r{url\('[^\)]*http[^\)]*://}, "url('../../")
      resource_data.gsub!(%r{url\([^'\)]*http[^'\)]*://}, 'url(../../')
    elsif exempted_formats.include? File.extname(name.split('?').first)
      puts "[INFO] Exempted path analisis on '#{@dir}/#{name}' ..."
    else
      puts "[WARN] Avoiding paths analisis on '#{@dir}/#{name}' ..."
    end
    resource_data
  end
end
