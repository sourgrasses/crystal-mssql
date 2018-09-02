module ODBC
  class Connection < DB::Connection
    getter raw_conn

    def initialize(context : DB::ConnectionContext)
      # set up all the basic connection info
      super(context)
      conn_string = serialize_conn_string
      # we could use the `SQL_NTS` macro to get the size, but since a `Slice` already knows its size
      # there's never a need to tax the driver by having it calculate the size for us
      conns_size = conn_string.size.to_i16

      @env = ODBC.alloc_env
      @raw_conn = ODBC.alloc_conn(@env)

      result = LibODBC.driver_connect(@raw_conn,
                                      nil,
                                      conn_string,
                                      conns_size,
                                      nil,
                                      0,
                                      nil,
                                      LibODBC::DriverConnect::SqlDriverComplete)

      if result == LibODBC::SqlReturn::SqlSuccessWithInfo
        puts ODBC.get_detail("SQLDriverConnect", @raw_conn, 1)
      elsif result != LibODBC::SqlReturn::SqlSuccess
        raise Errno.new("Error establishing connection to server")
      end

    end

    def build_prepared_statement(query)
      Statement.new(self, query)
    end

    def build_unprepared_statement(query)
      Statement.new(self, query)
    end

    def do_close
      LibODBC.disconnect(nil)
      LibODBC.free_handle(ODBC::HandleType::SqlHandleEnv.value, @env)
      LibODBC.free_handle(ODBC::HandleType::SqlHandleDbc, @raw_conn)
    end

    # :nodoc:
    private def serialize_conn_string : Bytes
      dsn = context.uri.host.not_nil!
      user = context.uri.user
      pass = context.uri.password
      conn_string = "DSN=#{dsn};UID=#{user};PWD=#{pass}"

      ODBC.encode_nts(conn_string)
    end
  end
end
