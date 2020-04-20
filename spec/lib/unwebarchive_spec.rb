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
    extracted_resources.each do |file, md5|
      expect(File.exist?(file)).to be_truthy
      expect(Digest::MD5.hexdigest(File.read(file))).to eq(md5)
    end
  end
end
