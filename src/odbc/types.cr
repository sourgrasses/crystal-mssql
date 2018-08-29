alias SqlChar = UInt8

alias SqlWChar = UInt32

alias SqlSmallInt = Int16

alias SqlUSmallInt = UInt16

alias SqlInteger = Int32

alias SqlUInteger = UInt32

alias SqlReal = Float32

alias SqlDouble = Float64

alias SqlFloat = Float64

alias SqlBigInt = Int64

alias SqlUBigInt = UInt64

alias Bookmark = Array(UInt32)

enum SqlResult
  SqlSuccess
  SqlSuccessWithInfo
  SqlInvalidHandle
  SqlError
end
