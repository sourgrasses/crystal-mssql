class ODBC::Driver < DB::Driver
  def build_connection(context : DB::ConnectionContext)
    ODBC::Connection.new(context)
  end
end

DB.register_driver "odbc", ODBC::Driver
