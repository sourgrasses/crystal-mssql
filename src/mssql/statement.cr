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

      prep_result = LibODBC.prepare(raw_stmt, @encoded_query.to_unsafe, @encoded_query.size)
      if prep_result != LibODBC::SqlReturn::SqlSuccess && prep_result != LibODBC::SqlReturn::SqlSuccessWithInfo
        err = MSSQL.get_detail("SQLPrepare", @raw_stmt, 1)
        raise "Error preparing SQL statement: #{err}"
      end

      exec_result = LibODBC.execute(raw_stmt)
      if exec_result != LibODBC::SqlReturn::SqlSuccess && exec_result != LibODBC::SqlReturn::SqlSuccessWithInfo
        err = MSSQL.get_detail("SQLExecute", @raw_stmt, 1)
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
