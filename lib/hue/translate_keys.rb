module Hue
  module TranslateKeys
    def translate_keys(hash, map)
      new_hash = {}
      hash.each do |key, value|
        new_key = map[key.to_sym]
        key = new_key if new_key
        new_hash[key] = value
      end
      new_hash
    end

    def unpack_hash(hash, map)
      map.each do |local_key, remote_key|
        value = hash[remote_key.to_s]
        next unless value
        instance_variable_set("@#{local_key}", value)
      end
    end
  end
end
