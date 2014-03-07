defmodule ExLager.Test do
  use ExUnit.Case
  @top Path.expand "../..", __ENV__.file

  test "debug" do
    {enabled, disabled} = split(compile(:debug))
    assert disabled == []
    assert enabled == [
     :alert, :critical, :debug, :emergency,
     :error, :info, :notice, :warning]
  end

  test "info" do
    {enabled, disabled} = split(compile(:info))
    assert disabled == [:debug]
    assert enabled == [
     :alert, :critical, :emergency,
     :error, :info, :notice, :warning]
  end

  test "notice" do
    {enabled, disabled} = split(compile(:notice))
    assert disabled == [:debug, :info]
    assert enabled == [:alert, :critical, :emergency, :error, :notice, :warning]
  end

  test "warning" do
    {enabled, disabled} = split(compile(:warning))
    assert disabled == [:debug, :info, :notice]
    assert enabled == [:alert, :critical, :emergency, :error, :warning]
  end

  test "error" do
    {enabled, disabled} = split(compile(:error))
    assert disabled == [:debug, :info, :notice, :warning]
    assert enabled == [:alert, :critical, :emergency, :error]
  end

  test "critical" do
    {enabled, disabled} = split(compile(:critical))
    assert disabled == [:debug, :error, :info, :notice, :warning]
    assert enabled == [:alert, :critical, :emergency]
  end

  test "alert" do
    {enabled, disabled} = split(compile(:alert))
    assert disabled == [:critical, :debug, :error, :info, :notice, :warning]
    assert enabled == [:alert, :emergency]
  end

  test "emergency" do
    {enabled, disabled} = split(compile(:emergency))
    assert disabled == [:alert, :critical, :debug, :error, :info, :notice, :warning]
    assert enabled == [:emergency]
  end

  test "none" do
    {enabled, disabled} = split(compile(:none))
    assert disabled == [:alert, :critical, :debug, :emergency,
      :error, :info, :notice, :warning]
    assert enabled == []
  end

  test "compile_log_level(atom)" do
    assert compile_log_level(:debug) == :debug
    assert compile_log_level(:info) == :info
    assert compile_log_level(:notice) == :notice
    assert compile_log_level(:warning) == :warning
    assert compile_log_level(:error) == :error
    assert compile_log_level(:critical) == :critical
    assert compile_log_level(:alert) == :alert
    assert compile_log_level(:emergency) == :emergency
    assert compile_log_level(:none) == :none
  end

  test "compile_log_level(integer)" do
    assert compile_log_level(7) == :debug
    assert compile_log_level(6) == :info
    assert compile_log_level(5) == :notice
    assert compile_log_level(4) == :warning
    assert compile_log_level(3) == :error
    assert compile_log_level(2) == :critical
    assert compile_log_level(1) == :alert
    assert compile_log_level(0) == :emergency
    assert compile_log_level(-1) == :none
  end

  teardown_all _context do
    File.rm("#{@top}/test/#{beam(Lager)}")
    :ok
  end

  defp compile_log_level(level) do
    true = Lager.compile_log_level(level)
    Lager.compile_log_level
  end

  defp compile(level) do
    :code.purge Lager
    Code.compiler_options exlager_level: level
    Kernel.ParallelCompiler.files_to_path ["#{@top}/lib/lager.ex"], "#{@top}/test"
    Code.ensure_compiled(Lager)
    quoted =
      quote do
        require Lager
        [
         debug: Lager.debug("Hi debug"),
         info: Lager.info("Hi info"),
         notice: Lager.notice("Hi notice"),
         warning: Lager.warning("Hi warning"),
         error: Lager.error("Hi error"),
         critical: Lager.critical("Hi critical"),
         alert: Lager.alert("Hi alert"),
         emergency: Lager.emergency("Hi emergency"),
        ]
      end
    {res, _} = Code.eval_quoted quoted
    res
  end

  defp beam(module), do: "#{module}.beam"

  defp split(macros) do
    {e, d} = Enum.reduce macros, {[], []}, fn({level, res}, {e, d}) ->
      if nil?(res) do
        {e, [level|d]}
      else
        {[level|e], d}
      end
    end
    {Enum.sort(e), Enum.sort(d)}
  end
end