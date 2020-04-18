# frozen_string_literal: true

require 'spec_helper'
require 'digest'

require_relative '../../lib/unwebarchive'

RSpec.describe UnWebarchive do
  subject { described_class.new(webarchive, exportdir) }

  let(:webarchive_name) { 'swprs.org' }

  include_context :webarchive_testing_data

  specify do
    expect { subject.extract }.to raise_error(Errno::ENAMETOOLONG) # TODO: add support for shortening names
    {
      'swprs.org/index.html' => '4ebbf0ee33e16cf93950b50ac1458013',
      'swprs.org/s0.wp.com/wp-includes/js/wp-emoji-release.min.js?m=1582709031h&ver=5.4' => 'ec33f485ba2d4767dae9d112b78f8b02',
      'swprs.org/s0.wp.com/wp-content/plugins/custom-fonts/js/webfont.js' => '9c75d05db8b3b7806807ae6011ac40e7',
      'swprs.org/swprs.org.webarchive' => 'de1da85360ed3b44edbe649f1aee333e'
    }.each do |file, md5|
      expect(File.exist?(file)).to be_truthy
      expect(Digest::MD5.hexdigest(File.read(file))).to eq(md5)
    end
  end
end
