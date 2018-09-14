module MSSQL::Type
  extend self

  def get_type(arg)
    case typeof(arg)
    when String.class
      SqlDataType::SqlVarchar
    when Char.class
      SqlDataType::SqlChar
    when Bool.class
      SqlDataType::SqlExtBit
    when Int8.class
      SqlDataType::SqlExtTinyInt
    when Int16.class
      SqlDataType::SqlSmallInt
    when Int32.class
      SqlDataType::SqlInteger
    when Int64.class
      SqlDataType::SqlExtBigInt
    when Float32.class
      SqlDataType::SqlReal
    when Float64.class
      SqlDataType::SqlFloat
    else
      SqlDataType::SqlUnknownType
    end
  end

  def get_c_type(arg)
    case typeof(arg)
    when String.class, Char.class
      SqlCDataType::SqlCChar
    when Bool.class
      SqlCDataType::SqlCBit
    when Int8.class
      SqlCDataType::SqlCSTinyInt
    when Int16.class
      SqlCDataType::SqlCSShort
    when Int32.class
      SqlCDataType::SqlCSLong
    when Int64.class
      SqlCDataType::SqlCSBigInt
    when UInt8.class
      SqlCDataType::SqlCUTinyInt
    when UInt16.class
      SqlCDataType::SqlCUShort
    when UInt32.class
      SqlCDataType::SqlCULong
    when UInt64.class
      SqlCDataType::SqlCUBigInt
    when Float32.class
      SqlCDataType::SqlCFloat
    when Float64.class
      SqlCDataType::SqlCDouble
    else
      SqlCDataType::SqlCDefault
    end
  end

  def to_mssql(arg)
    res =
      if typeof(arg) == Bool.class
        if arg
          1
        else
          0
        end
      elsif typeof(arg) == UInt8
        arg.to_i16
      elsif typeof(arg) == UInt16
        arg.to_i32
      elsif typeof(arg) == UInt32
        arg.to_i64
      else
        arg
      end

    MSSQL.encode_nts("#{res}")
  end
end

enum SqlDataType
  SqlUnknownType            = 0
  SqlChar                   = 1
  SqlNumeric                = 2
  SqlDecimal                = 3
  SqlInteger                = 4
  SqlSmallInt               = 5
  SqlFloat                  = 6
  SqlReal                   = 7
  SqlDouble                 = 8
  SqlDatetime               = 9
  SqlVarchar                = 12
  SqlUdt                    = 17
  SqlRow                    = 19
  SqlArray                  = 50
  SqlMultiset               = 55
  SqlDate                   = 91
  SqlTime                   = 92
  SqlTimestamp              = 93
  SqlTimeWithTimezone       = 94
  SqlTimestampWithTimezone  = 95
  SqlExtlongVarchar         = -1
  SqlExtBinary              = -2
  SqlExtVarbinary           = -3
  SqlExtlongvarbinary       = -4
  SqlExtBigInt              = -5
  SqlExtTinyInt             = -6
  SqlExtBit                 = -7
  SqlExtWChar               = -8
  SqlExtWVarchar            = -9
  SqlExtwLongVarchar        = -10
  SqlExtGuid                = -11
  SqlSsVariant              = -150
  SqlSsUdt                  = -151
  SqlSsXml                  = -152
  SqlSsTable                = -153
  SqlSsTime2                = -154
  SqlSsTimestampOffset      = -155
end

enum SqlCDataType
  SqlCUTinyInt                  = -28
  SqlCUBigInt                   = -27
  SqlCSTinyInt                  = -26
  SqlCSBigInt                   = -25
  SqlCULong                     = -18
  SqlCUShort                    = -17
  SqlCSLong                     = -16
  SqlCSShort                    = -15
  SqlCGuid                      = -11
  SqlCWChar                     = -8
  SqlCBit                       = -7
  SqlCBinary                    = -2
  SqlCChar                      = 1
  SqlCNumeric                   = 2
  SqlCFloat                     = 7
  SqlCDouble                    = 8
  SqlCDate                      = 9
  SqlCTime                      = 10
  SqlCTimestamp                 = 11
  SqlCTypeDate                  = 91
  SqlCTypeTime                  = 92
  SqlCTypeTimestamp             = 93
  SqlCTypeTimeWithTimezone      = 94
  SqlCTypeTimestampWithTimezone = 95
  SqlCDefault                   = 99
  SqlCIntervalYear              = 101
  SqlCIntervalMonth             = 102
  SqlCIntervalDay               = 103
  SqlCIntervalHour              = 104
  SqlCIntervalMinute            = 105
  SqlCIntervalSecond            = 106
  SqlCIntervalYearToMonth       = 107
  SqlCIntervalDayToHour         = 108
  SqlCIntervalDayToMinute       = 109
  SqlCIntervalDayToSecond       = 110
  SqlCIntervalHourToMinute      = 111
  SqlCIntervalHourToSecond      = 112
  SqlCIntervalMinuteToSecond    = 113
end
