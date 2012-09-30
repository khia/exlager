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

  quoted = lc {level, _num} inlist levels do
    quote do
      defmacro unquote(level).(message) do
        log(unquote(level), '~s', [message], __CALLER__)
      end
      defmacro unquote(level).(format, message) do
        log(unquote(level), format, message, __CALLER__)
      end
    end
  end
  Module.eval_quoted __MODULE__, quoted, file: __FILE__, line: __ENV__.line

  quoted = lc {level, num} inlist levels do
    quote do: defp level_to_num(unquote(level)),     do:  unquote(num)
  end
  Module.eval_quoted __MODULE__, quoted, file: __FILE__, line: __ENV__.line

  defp log(level, format, args, caller) do
    {name, __arity} = caller.function || {:unknown, 0}
    module = caller.module || :unknown
    if is_binary(format), do: format = binary_to_list(format)
    if should_log(level) do
       dispatch(level, module, name, caller.line, format, args)
    end
  end

  defp dispatch(level, module, name, line, format, args) do
    if version <= 120 do
      quote do
        :lager.dispatch_log(unquote(level), unquote(module), unquote(name),
           unquote(line), self, [], unquote(format), unquote(args))
      end
    else
      quote do
        :lager.dispatch_log(unquote(level),
           [module: unquote(module),
            function: unquote(name),
            line: unquote(line),
            pid: self],
           unquote(format), unquote(args), unquote(truncation_size))
      end
    end
  end

  defp should_log(level) do
    {log_level, _} = :lager_mochiglobal.get(:loglevel, {level_to_num(:none), []})
    level_to_num(level) <= log_level
  end

  defp truncation_size, do: Mix.project[:opts][:truncation_size] || 4096

  defp version do
    {:ok, vsn} = Erlang.application.get_key(:lager, :vsn)
    vsn = Enum.filter vsn, fn(x) -> [x] != '.' end
    {vsn, []} = :string.to_integer vsn
    vsn
  end
end