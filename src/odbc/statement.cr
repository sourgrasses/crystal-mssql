module ODBC
  class Statement < DB::Statement
    def initialize(connection, @query_sql : String)
      super(connection)
    end

    protected def conn
      connection.as(Connection).connection
    end

    protected def perform_query(args : Enumerable) : ODBC::ResultSet
      body = ODBC.alloc_statement(@connection)
      LibODBC.tables(body, nil, 0, nil, 0, nil, 0, "TABLE", 6)
    end

    protected def perform_exec(args : Enumerable) : ::DB::ExecResult
    end
  end
end
