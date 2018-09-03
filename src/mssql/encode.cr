module MSSQL
  extend self

  # Coerce the `String` into utf8 encoding
  # First we want to encode the string and then get an unsafe `Pointer` to the memory
  # so we don't have to realloc to append a null byte, and then we append `0_u8`
  # to make a null-terminated string
  def encode_nts(line : String) : Bytes
    encoded = line.encode("UTF-8")
    size = encoded.bytesize() + 1
    line_bytes = Slice.new(encoded.to_unsafe(), size)
    line_bytes[size - 1] = 0_u8

    line_bytes
  end
end
