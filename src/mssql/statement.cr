module MSSQL
  class Statement < DB::Statement
    @raw_stmt : Void*
    @encoded_query : Bytes
    getter raw_stmt

    def initialize(connection, query : String)
      super(connection)
      @raw_stmt = Pointer(Void).null

      @encoded_query = MSSQL.encode_nts(query)
    end

    protected def conn
      connection.as(Connection).connection
    end

    protected def perform_query(args : Enumerable) : MSSQL::ResultSet
      @raw_stmt = MSSQL.alloc_stmt(@connection.raw_conn)

      param_num = 1
      args.each do |arg|
        value_type = MSSQL::Type.get_c_type(arg)
        param_type = MSSQL::Type.get_type(arg)
        num_of_decimals =
          if typeof(arg) == Float32
            6
          elsif typeof(arg) == Float64
            15
          else
            0
          end

        res = LibODBC.bind_parameter(raw_stmt, param_num, LibODBC::BindParam::SqlParamInput,
                                     value_type, param_type, arg.size, num_of_decimals,
                                     MSSQL::Type.to_mssql(arg).to_unsafe, arg.size, Pointer(Int64).null)

        param_num += 1
      end

      prep_result = LibODBC.prepare(raw_stmt, @encoded_query.to_unsafe, @encoded_query.size)
      if prep_result != LibODBC::SqlReturn::SqlSuccess && prep_result != LibODBC::SqlReturn::SqlSuccessWithInfo
        err = MSSQL.get_detail("SQLPrepare", raw_stmt, LibODBC::HandleType::SqlHandleStmt)
        raise "Error preparing SQL statement: #{err}"
      end

      exec_result = LibODBC.execute(raw_stmt)
      if exec_result != LibODBC::SqlReturn::SqlSuccess && exec_result != LibODBC::SqlReturn::SqlSuccessWithInfo
        err = MSSQL.get_detail("SQLExecute", raw_stmt, LibODBC::HandleType::SqlHandleStmt)
        raise "Error executing SQL statement: #{err}"
      end

      MSSQL::ResultSet.new(self)
    end

    protected def perform_exec(args : Enumerable) : DB::ExecResult
      result = perform_query(args)
      result.each { }
        DB::ExecResult.new(rows_affected: result.rows_affected, last_insert_id: 0_i64)
    end

    protected def do_close
      super

      LibODBC.free_handle(LibODBC::HandleType::SqlHandleStmt, @raw_stmt)
    end
  end
end
