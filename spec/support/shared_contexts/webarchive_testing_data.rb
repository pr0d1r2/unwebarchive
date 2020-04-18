# frozen_string_literal: true

RSpec.shared_context :webarchive_testing_data do
  let(:webarchive_source) { File.expand_path("../../../testing-data/webarchives/#{webarchive_name}.webarchive", __dir__) }
  let(:webarchive) { File.expand_path("../../../#{webarchive_name}.webarchive", __dir__) }
  let(:exportdir) { File.expand_path("../../../#{webarchive_name}", __dir__) }

  before do
    cleanup
    FileUtils.cp(webarchive_source, webarchive)
  end

  after { cleanup }

  def cleanup
    FileUtils.rm_rf(exportdir) if File.directory?(exportdir)
    FileUtils.rm_f(webarchive) if File.exist?(webarchive)
  end
end
