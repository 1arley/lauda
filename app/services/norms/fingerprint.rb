require 'digest'
require 'json'

module Norms
  class Fingerprint
    def self.call(data)
      Digest::SHA256.hexdigest(JSON.generate(canonical(data)))
    end

    def self.canonical(data)
      case data
      when Hash
        data.keys.map(&:to_s).sort.to_h do |key|
          value = data.key?(key) ? data[key] : data[key.to_sym]
          [key, canonical(value)]
        end
      when Array
        data.map { |value| canonical(value) }
      else
        data
      end
    end
    private_class_method :canonical
  end
end
