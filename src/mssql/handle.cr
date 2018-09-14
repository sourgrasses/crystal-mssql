module MSSQL
  extend self

  def alloc_env : Void*
    result = LibODBC.alloc_handle(LibODBC::HandleType::SqlHandleEnv.value, nil, out output_handle_ptr)
    if result.value != 0 && result.value != 1
      raise Errno.new("Error allocating environment handle")
    end

    version = Pointer(Void).new(LibODBC::OdbcVer::SqlOvOdbc3.value)
    env_result = LibODBC.set_env_attr(output_handle_ptr, LibODBC::EnvAttr::SqlAttrOdbcVersion.value, version, 0)
    if env_result.value != 0 && env_result.value != 1
      error = MSSQL.get_detail("SQLSetEnvAttr", output_handle_ptr, LibODBC::HandleType::SqlHandleEnv)
      raise Errno.new(error)
    end

    output_handle_ptr
  end

  def alloc_conn(env : Void*) : Void*
    result = LibODBC.alloc_handle(LibODBC::HandleType::SqlHandleDbc.value, env.as(Void**), out output_handle_ptr)

    if result.value != 0 && result.value != 1
      error = MSSQL.get_detail("SQLAllocHandle", output_handle_ptr, LibODBC::HandleType::SqlHandleDbc)
      raise Errno.new(error)
    end

    output_handle_ptr
  end

  def alloc_stmt(dbc : Void*) : Void*
    result = LibODBC.alloc_handle(LibODBC::HandleType::SqlHandleStmt.value, dbc.as(Void**), out output_handle_ptr)
    if result.value != 0 && result.value != 1
      error = MSSQL.get_detail("SQLAllocHandle", output_handle_ptr, LibODBC::HandleType::SqlHandleStmt)
      raise Errno.new(error)
    end

    output_handle_ptr
  end

  def get_detail(func : String, handle : Void*, type : LibODBC::HandleType) : String
    diag_num = Slice(Int64).new(1)

    result = LibODBC.get_diag_field(type, handle, 0, LibODBC::DiagIdentifier::SqlDiagNumber, diag_num.to_unsafe, 0_i16, Pointer(Int16).null)
    if result.value != 0 && result.value != 1
      raise Errno.new("Error getting number of diagnostic fields")
    end

    num = diag_num[0].to_i32
    message_acc = Array(Bytes).new(num)

    iter = 1..num
    iter.each do |i|
      message = Bytes.new(256)
      LibODBC.get_diag_rec(type, handle, i, out state, out native, message.to_unsafe, 256 * 8, out len)
      message_acc.push(message)
      i += 1
    end

    message_acc = message_acc.map { |b| String.new((b.reject { |v| v == 0 }).to_unsafe) }
    message_acc.join('\n')
  end
end
