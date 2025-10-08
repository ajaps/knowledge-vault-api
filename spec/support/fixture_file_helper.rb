module FixtureFileHelper
  def fixture_file_upload(filename, content_type)
    file_path = Rails.root.join('spec', 'fixtures', 'files', filename)
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, 'test content') unless File.exist?(file_path)
    
    Rack::Test::UploadedFile.new(file_path, content_type)
  end
end

RSpec.configure do |config|
  config.include FixtureFileHelper, type: :request
end