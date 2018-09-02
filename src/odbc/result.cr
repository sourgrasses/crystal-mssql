module ODBC
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

    getter rows_affected

    def initialize(statement)
      super(statement)
      @col_index = 0
      @row_index = 0_i64

      LibODBC.row_count(statement.raw_stmt, out rows_affected)
      @rows_affected = rows_affected

      LibODBC.num_result_cols(statement.raw_stmt, out num_cols)
      @num_cols = num_cols.to_i32

      @fields = Array(ODBC::Field).new
      i = 0
      while i < @num_cols
        @fields.push(ODBC::Field.new(statement.raw_stmt, i))
        i += 1
      end

      @buffer = Array(UInt8*).new(@num_cols, Pointer(UInt8).null)
      @strlen = Array(Int64).new(@num_cols, 0)
      i = 0
      while i < @num_cols
        # kind of awkward workaround for dealing with an array of pointers and the fact that
        # arrays are themselves built of pointers and somake accessing the contained pointers
        # a bit clumsy
        #
        # TODO: a better way to handle this probably?
        tmp_buf = Pointer(UInt8).malloc

        # and here, since we're calling C functions here we have to specify the length of the buffer into which
        # we're reading the SqlCChars. does bind_col realloc strictly based on that? need to find some way to
        # get around this since we'd rather dynamically rellocate memory to accommodate a large field than
        # unnecessarily snip the end off
        LibODBC.bind_col(statement.raw_stmt, i + 1, SqlCDataType::SqlCChar.value, tmp_buf.as(Void*), 256, out ind)
        @buffer[i] = tmp_buf
        @strlen[i] = ind
        i += 1
      end
    end

    protected def conn
      statement.as(Statement).conn
    end

    def move_next
      if @row_index < @rows_affected - 1
        @row_index += 1
        true
      else
        false
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
      case @col_index
      when 0
        result = LibODBC.fetch_scroll(statement.raw_stmt, LibODBC::FetchOrientation::SqlFetchAbsolute, @row_index + 1)
        if result != LibODBC::SqlReturn::SqlSuccess && result != LibODBC::SqlReturn::SqlSuccessWithInfo
          err = ODBC.get_detail("SQLFetchScroll", statement.raw_stmt, 1)
          raise "Error fetching row #{@row_index + 1}: #{err}"
        end

        @col_index += 1
        return @buffer[0]
      when .<(@num_cols)
        value = buffer[@col_index]
        @col_index += 1
        return value
      else
        @col_index = 0
        @row_index += 1
        self.read
      end
    end
  end
end
