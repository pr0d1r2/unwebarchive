# frozen_string_literal: true

require 'spec_helper'
require 'digest'

require_relative '../../lib/webarchive'

RSpec.describe Webarchive do
  subject { described_class.new(webarchive) }

  let(:webarchive_name) { 'swprs.org' }

  include_context :webarchive_testing_data

  specify do
    expect(
      subject.resources.transform_values do |data|
        Digest::MD5.hexdigest(data)
      end
    ).to eq(contained_resources)
  end
end
