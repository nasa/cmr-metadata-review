module Helpers
  module RecordHelpers
    def get_stub(file_name)
      file = "#{Rails.root}/test/stubs/#{file_name}"
      File.read(file)
    end
  end
end
