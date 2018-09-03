class MSSQL::Driver < DB::Driver
  def build_connection(context : DB::ConnectionContext)
    MSSQL::Connection.new(context)
  end
end

DB.register_driver "mssql", MSSQL::Driver
