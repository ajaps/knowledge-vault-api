class LocalStorage
  BASE = Rails.root.join("storage").freeze

  def self.save!(io:, vault_id:, document_id:, original_filename:)
    ext = File.extname(original_filename.to_s)
    key = File.join("vaults", vault_id.to_s, "docs", document_id.to_s, "#{SecureRandom.uuid}#{ext}")

    full = BASE.join(key)
    FileUtils.mkdir_p(full.dirname)

    digest = Digest::SHA256.new
    size = 0

    File.open(full, "wb") do |f|
      while (chunk = io.read(2 * 1024 * 1024))
        digest.update(chunk)
        size += chunk.bytesize
        f.write(chunk)
      end
    end

    { key:, size:, checksum: digest.hexdigest }
  end
end
