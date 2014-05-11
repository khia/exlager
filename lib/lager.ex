defmodule Lager do
   defdelegate [
     trace_console(filter),
     trace_file(file, filter, level),
     stop_trace(trace),
     clear_all_traces(),
     status(),
     set_loglevel(handler, level),
     set_loglevel(handler, indent, level),
     get_loglevel(handler),
     posix_error(error)
    ], to: :lager

  levels =
    [debug:      7,
     info:       6,
     notice:     5,
     warning:    4,
     error:      3,
     critical:   2,
     alert:      1,
     emergency:  0,
     none:      -1
    ]

  quoted = for {level, _num} <- levels do
    quote do
      defmacro unquote(level)(message) do
        log(unquote(level), '~s', [message], __CALLER__)
      end
      defmacro unquote(level)(format, message) do
        log(unquote(level), format, message, __CALLER__)
      end
    end
  end
  Module.eval_quoted __MODULE__, quoted, [], __ENV__

  quoted = for {level, num} <- levels do
    quote do
      defp level_to_num(unquote(level)), do:  unquote(num)
    end
  end
  Module.eval_quoted __MODULE__, quoted, [], __ENV__
  defp level_to_num(_), do: nil

  quoted = for {level, num} <- levels do
    quote do
      defp num_to_level(unquote(num)),     do:  unquote(level)
    end
  end
  Module.eval_quoted __MODULE__, quoted, [], __ENV__
  defp num_to_level(_), do: nil

  defp log(level, format, args, caller) do
    {name, __arity} = caller.function || {:unknown, 0}
    module = caller.module || :unknown
    if is_binary(format), do: format = String.to_char_list!(format)
    if should_log(level) do
       dispatch(level, module, name, caller.line, format, args)
    end
  end

  defp dispatch(level, module, name, line, format, args) do
    quote do
      :lager.dispatch_log(unquote(level),
         [module: unquote(module),
          function: unquote(name),
          line: unquote(line),
          pid: self],
         unquote(format), unquote(args), unquote(compile_truncation_size))
    end
  end

  defp should_log(level), do: level_to_num(level) <= level_to_num(compile_log_level)

  @doc """
  This function is used to get compile time log level.
  Examples:
    iex(4)> Lager.compile_log_level
    :info
  """
  def compile_log_level() do
    options = Enum.into(Code.compiler_options, [])
    level = options[:exlager_level] || :info
    if is_integer(level) do
      level = num_to_level(level)
      IO.puts "Using integers is deprecated, please use :#{level} instead"
    end
    level
  end

  @doc """
  This function is used to set compile time log level.
  By default the log level is 'info'.
  Examples:
    iex(4)> Lager.compile_log_level(6)
    true
    iex(4)> Lager.compile_log_level(:info)
    true
  """
  def compile_log_level(level) when level in -1..7 do
    compile_log_level(num_to_level(level))
  end
  def compile_log_level(level) when is_atom(level) do
    :ok = Code.compiler_options exlager_level: level
    true
  end
  def compile_log_level(level) do
    IO.puts "ERROR: unknown level #{inspect level}"
    false
  end

  def compile_truncation_size() do
    options = Enum.into(Code.compiler_options, [])
    options[:exlager_truncation_size] || 4096
  end

  @doc """
  This function is used to set compile time truncation size.
  By default the truncation size is 4096.
  Examples:
    iex(4)> Lager.compile_truncation_size(512)
    true
  """
  def compile_truncation_size(size) do
    :ok = Code.compiler_options exlager_truncation_size: size
    true
  end
end
