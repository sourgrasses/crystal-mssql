module MSSQL
  class Field
    @name : String
    @col_type : SqlDataType
    @col_size : LibODBC::SqlULen
    @nullable : Bool

    getter name, col_type, col_size, nullable

    def initialize(stmt : Void*, col_num : Int32)
      name = Pointer(UInt8).malloc(256)
      LibODBC.describe_col(stmt, col_num, name,
                           256, out name_len, out col_type,
                           out col_size, out digits, out nullable)

      @name = String.new(name)
      @col_type = SqlDataType.new(col_type.to_i32)
      @col_size = col_size
      @nullable =  case nullable
                   when LibODBC::Nullable::SqlNullable
                     true
                   else
                     false
                   end
    end
  end

  class ResultSet < DB::ResultSet
    @num_cols : Int32
    @rows_affected : Int64
    @buffer : Array(UInt8*)
    @strlen : Array(Int64)

    getter rows_affected, num_cols

    def initialize(statement)
      super(statement)
      @col_index = 0
      @row_index = 0_i64

      LibODBC.row_count(statement.raw_stmt, out rows_affected)
      @rows_affected = rows_affected

      LibODBC.num_result_cols(statement.raw_stmt, out num_cols)
      @num_cols = num_cols.to_i32

      @fields = Array(MSSQL::Field).new
      i = 0
      while i < @num_cols
        @fields.push(MSSQL::Field.new(statement.raw_stmt, i + 1))
        i += 1
      end

      @buffer = Array(UInt8*).new(@num_cols, Pointer(UInt8).null)
      @strlen = Array(Int64).new(@num_cols, 0)
      i = 0
      while i < @num_cols
        # kind of awkward workaround for dealing with an array of pointers and the fact that
        # arrays are themselves built of pointers and so make accessing the contained pointers
        # a bit clumsy
        #
        # TODO: a better way to handle this probably?
        tmp_buf = Pointer(UInt8).malloc(@fields[i].col_size)

        LibODBC.bind_col(statement.raw_stmt, i + 1, SqlCDataType::SqlCChar.value, tmp_buf.as(Void*), @fields[i].col_size, out ind)

        @buffer[i] = tmp_buf
        @strlen[i] = ind

        i += 1
      end
    end

    protected def conn
      statement.as(Statement).conn
    end

    def move_next
      @col_index = 0

      result = LibODBC.fetch(statement.raw_stmt)
      if result != LibODBC::SqlReturn::SqlSuccess && result != LibODBC::SqlReturn::SqlSuccessWithInfo
        false
      else
        @row_index += 1
        true
      end
    end

    def column_count : Int32
      @num_cols
    end

    def column_name(index : Int32) : String
      @fields[index].name
    end

    def column_type(index : Int32) : SqlDataType
      @fields[index].col_type
    end

    def read
      value = @buffer[@col_index]
      @col_index += 1
      value
    end

    protected def do_close
      super
    end
  end
end
