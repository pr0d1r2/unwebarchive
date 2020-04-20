# frozen_string_literal: true

require 'yaml'

RSpec.shared_context :webarchive_testing_data do
  let(:webarchive) { File.expand_path("../../../testing-data/webarchives/#{webarchive_name}.webarchive", __dir__) }
  let(:exportdir) { File.expand_path("../../../#{webarchive_name}", __dir__) }

  let(:contained_resources_yml) { "#{webarchive}.yml" }
  let(:contained_resources) { YAML.load_file(contained_resources_yml) }

  let(:extracted_resources) do
    {
      'swprs.org/index.html' => '4ebbf0ee33e16cf93950b50ac1458013',
      'swprs.org/s0.wp.com/wp-includes/js/wp-emoji-release.min.js?m=1582709031h&ver=5.4' => 'ec33f485ba2d4767dae9d112b78f8b02',
      'swprs.org/s0.wp.com/wp-content/plugins/custom-fonts/js/webfont.js' => '9c75d05db8b3b7806807ae6011ac40e7',
      'swprs.org/swprs.org.webarchive' => 'de1da85360ed3b44edbe649f1aee333e'
    }
  end

  before { cleanup }

  after { cleanup }

  def cleanup
    FileUtils.rm_rf(exportdir) if File.directory?(exportdir)
  end
end
