# frozen_string_literal: true

require 'fileutils'
require_relative 'plutil'
require_relative 'webarchive'

class UnWebarchive
  ADJUSTABLE_FORMATS = %w[.html .css].freeze
  EXEMPTED_FORMATS = %w[.png .jpg .gif .svg .woff .woff2 .aspx .js].freeze

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
      Webarchive.resources(@file).each do |file, data|
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
    format = File.extname(name.split('?').first)
    if ADJUSTABLE_FORMATS.include?(format)
      puts "[INFO] Fixing paths on '#{@dir}/#{name}' ..."
      resource_data = adjust(resource_data, format)
    elsif EXEMPTED_FORMATS.include?(format)
      puts "[INFO] Exempted path analisis on '#{@dir}/#{name}' ..."
    else
      puts "[WARN] Avoiding paths analisis on '#{@dir}/#{name}' ..."
    end
    resource_data
  end

  def adjust(resource_data, format)
    case format
    when '.html'
      resource_data.gsub!(%r{href="[^=]*http[^=]*://}, 'href="')
      resource_data.gsub!(%r{src="[^=]*http[^=]*://}, 'src="')
    when '.css'
      resource_data.gsub!(%r{url\('[^\)]*http[^\)]*://}, "url('../../")
      resource_data.gsub!(%r{url\([^'\)]*http[^'\)]*://}, 'url(../../')
    end
  end
end
