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
      error = MSSQL.get_detail("SQLSetEnvAttr", output_handle_ptr, 1)
      raise Errno.new(error)
    end

    output_handle_ptr
  end

  def alloc_conn(env : Void*) : Void*
    result = LibODBC.alloc_handle(LibODBC::HandleType::SqlHandleDbc.value, env.as(Void**), out output_handle_ptr)

    if result.value != 0 && result.value != 1
      error = MSSQL.get_detail("SQLAllocHandle", output_handle_ptr, 1)
      raise Errno.new(error)
    end

    output_handle_ptr
  end

  def alloc_stmt(dbc : Void*) : Void*
    result = LibODBC.alloc_handle(LibODBC::HandleType::SqlHandleStmt.value, dbc.as(Void**), out output_handle_ptr)
    if result.value != 0 && result.value != 1
      error = MSSQL.get_detail("SQLAllocHandle", output_handle_ptr, 1)
      raise Errno.new(error)
    end

    output_handle_ptr
  end

  def get_detail(func : String, handle : Void*, type : LibODBC::SqlSmallInt) : String
    message = Slice(UInt8).new(256)
    state = Slice(UInt8).new(8)
    LibODBC.get_diag_rec(type, handle, 1, state.to_unsafe, out native, message.to_unsafe, 256 * 8, out len)

    String.new(message)
  end
end
