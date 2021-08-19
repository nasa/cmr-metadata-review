module Helpers
  module RecordHelpers
    def get_stub(file_name)
      file = "#{Rails.root}/test/stubs/#{file_name}"
      File.read(file)
    end

    def sort_by_key(hash, recursive = false, &block)
      hash.keys.sort(&block).reduce({}) do |seed, key|
        seed[key] = hash[key]
        if recursive && seed[key].is_a?(Hash)
          seed[key] = sort_by_key(seed[key], sort_by_key(true, &block))
        end
        seed
      end
    end
  end
end
