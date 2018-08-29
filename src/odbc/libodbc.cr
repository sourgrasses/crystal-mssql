@[Link("odbc")]
lib LibODBC
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
  alias SqlLen = Int64
  alias SqlULen = UInt64
  alias Bookmark = Array(UInt32)

  alias SqlHandle = Void*
  alias SqlHStmt = Void*
  alias SqlHEnv = Void*
  alias SqlHDBC = Void*

  alias SqlPointer = Void*

  enum SqlReturn
    SqlSuccess          = 0
    SqlSuccessWithInfo  = 1
    SqlInvalidHandle    = -2
    SqlError            = -1
  end

  enum SqlDriverConnect
    SqlDriverNoPrompt           = 0
    SqlDriverComplete           = 1
    SqlDriverPrompt             = 2
    SqlDriverCompleteRequired   = 3
  end

  enum EnvAttr
    SqlAttrOdbcVersion       = 200
    SqlAttrConnectionPooling = 201
    SqlAttrCpMatch           = 202
    SqlAttrApplicationKey    = 203
    SqlAttrOutputNts         = 10001
  end

  enum OdbcVer
    SqlOvOdbc2      = 2
    SqlOvOdbc3      = 3
    SqlOvOdbc380    = 380
    SqlOvOdbc4      = 400
  end

  fun alloc_handle = SQLAllocHandle(handle_type : SqlSmallInt,
                                    input_handle : SqlHandle*,
                                    output_handle_ptr : SqlHandle*) : SqlReturn

  fun bind_col = SQLBindCol(statement_handle : SqlHStmt,
                            column_number : SqlUSmallInt,
                            target_type : SqlSmallInt,
                            target_value_ptr : SqlPointer,
                            buffer_length : SqlLen,
                            strlen_or_ind : SqlLen*) : SqlReturn

  fun bind_parameter = SQLBindParameter(statement_handle : SqlHStmt,
                                        parameter_number : SqlUSmallInt,
                                        input_output_type : SqlSmallInt,
                                        value_type : SqlSmallInt,
                                        parameter_type : SqlSmallInt,
                                        column_size : SqlULen,
                                        decimal_digits : SqlSmallInt,
                                        parameter_value_ptr : SqlPointer,
                                        buffer_length : SqlLen,
                                        strlen_or_ind_ptr : SqlLen*) : SqlReturn

  fun connect = SQLConnect(connection_handle : SqlHDBC,
                           server_name : SqlChar*,
                           name_length1 : SqlSmallInt,
                           user_name : SqlChar*,
                           name_length2 : SqlSmallInt,
                           authentication : SqlChar*,
                           name_length3 : SqlSmallInt) : SqlReturn

  fun data_sources = SQLDataSources(environment_handle : SqlHEnv,
                                    direction : SqlUSmallInt,
                                    server_name : SqlChar*,
                                    buffer_length1 : SqlSmallInt,
                                    name_length1_ptr : SqlSmallInt*,
                                    description : SqlChar*,
                                    buffer_length2 : SqlSmallInt,
                                    name_length2_ptr : SqlSmallInt*) : SqlReturn

  fun describe_col = SQLDescribeCol(statement_handle : SqlHStmt,
                                    column_number : SqlUSmallInt,
                                    column_name : SqlChar*,
                                    buffer_length : SqlSmallInt,
                                    name_length_ptr : SqlSmallInt*,
                                    data_type_ptr : SqlSmallInt*,
                                    columns_size_ptr : SqlULen*,
                                    decimal_digits_ptr : SqlSmallInt*,
                                    nullable_ptr : SqlSmallInt*) : SqlReturn

  fun disconnect = SQLDisconnect(connection_handle : SqlHDBC)

  fun driver_connect = SQLDriverConnect(connection_handle : SqlHDBC,
                                        window_handle : SqlHEnv,
                                        in_connection_string : SqlChar*,
                                        string_length1 : SqlSmallInt,
                                        out_connection_string : SqlChar*,
                                        buffer_length : SqlSmallInt,
                                        string_length2_ptr : SqlSmallInt*,
                                        driver_completion : SqlUSmallInt) : SqlReturn

  fun drivers = SQLDrivers(environment_handle : SqlHEnv,
                           direction : SqlUSmallInt,
                           driver_description : SqlChar*,
                           buffer_length1 : SqlSmallInt,
                           description_length_ptr : SqlSmallInt*,
                           driver_attributes : SqlChar*,
                           buffer_length2 : SqlSmallInt,
                           attributes_length_ptr : SqlSmallInt*) : SqlReturn

  fun end_tran = SQLEndTran(handle_type : SqlSmallInt,
                            handle : SqlHandle,
                            completion_type : SqlSmallInt) : SqlReturn

  fun exec_direct = SQLExecDirect(statement_handle : SqlHStmt,
                                  statement_text : SqlChar*,
                                  text_length : SqlInteger) : SqlReturn

  fun execute = SQLExecute(statement_handle : SqlHStmt) : SqlReturn

  fun fetch = SQLFetch(statement_handle : SqlHStmt) : SqlReturn

  fun free_handle = SQLFreeHandle(handle_type : SqlSmallInt, handle : SqlHandle)

  fun free_stmt = SQLFreeStmt(statement_handle : SqlHStmt, option : SqlUSmallInt)

  fun get_data = SQLGetData(statement_handle : SqlHStmt,
                            col_or_param_num : SqlUSmallInt,
                            target_type : SqlSmallInt,
                            target_value_ptr : SqlPointer,
                            buffer_length : SqlLen,
                            str_len_or_ind_ptr : SqlLen*) : SqlReturn

  fun get_diag_rec = SQLGetDiagRec(handle_type : SqlSmallInt,
                                   handle : SqlHandle,
                                   rec_number : SqlSmallInt,
                                   sql_state : SqlChar*,
                                   native_error_ptr : SqlInteger*,
                                   messagE_text : SqlChar*,
                                   buffer_length : SqlSmallInt,
                                   text_length_ptr : SqlSmallInt*) : SqlReturn

  fun get_info = SQLGetInfo(connection_handle : SqlHDBC,
                            info_type : SqlUSmallInt,
                            info_value_ptr : SqlPointer,
                            buffer_legnth : SqlSmallInt,
                            string_length_ptr : SqlSmallInt*) : SqlReturn

  fun num_result_cols = SQLNumResultCols(statement_handle : SqlHStmt, column_count_ptr : SqlSmallInt*) : SqlReturn

  fun prepare = SQLPrepare(statement_handle : SqlHStmt, statement_text : SqlChar*, text_length : SqlInteger) : SqlReturn

  fun set_connect_attr = SQLSetConnectAttr(connection_handle : SqlHDBC,
                                           attribute : SqlInteger,
                                           value_ptr : SqlPointer,
                                           string_length : SqlInteger) : SqlReturn

  fun set_env_attr = SQLSetEnvAttr(environment_handle : SqlHEnv,
                                   attribute : SqlInteger,
                                   value_ptr : SqlPointer,
                                   string_length : SqlInteger) : SqlReturn

  fun set_stmt_attr = SQLSetStmtAttr(statement_handle : SqlHStmt,
                                     attribute : SqlInteger,
                                     value_ptr : SqlPointer,
                                     string_length : SqlInteger) : SqlReturn

  fun tables = SQLTables(statement_handle : SqlHStmt,
                         catalog_name : SqlChar*,
                         name_length1 : SqlSmallInt,
                         schema_name : SqlChar*,
                         name_length2 : SqlSmallInt,
                         table_name : SqlChar*,
                         name_length3 : SqlSmallInt,
                         tale_type : SqlChar*,
                         name_length4 : SqlSmallInt) : SqlReturn
end
