defmodule ExLager.Test do
  use ExUnit.Case
  @top Path.expand "../..", __FILE__

  test "debug" do
    level = 7
    {enabled, disabled} = split(compile(level))
    assert disabled == []
    assert enabled == [
     :alert, :critical, :debug, :emergency,
     :error, :info, :notice, :warning]
  end

  test "info" do
    level = 6
    {enabled, disabled} = split(compile(level))
    assert disabled == [:debug]
    assert enabled == [
     :alert, :critical, :emergency,
     :error, :info, :notice, :warning]
  end

  test "notice" do
    level = 5
    {enabled, disabled} = split(compile(level))
    assert disabled == [:debug, :info]
    assert enabled == [:alert, :critical, :emergency, :error, :notice, :warning]
  end

  test "warning" do
    level = 4
    {enabled, disabled} = split(compile(level))
    assert disabled == [:debug, :info, :notice]
    assert enabled == [:alert, :critical, :emergency, :error, :warning]
  end

  test "error" do
    level = 3
    {enabled, disabled} = split(compile(level))
    assert disabled == [:debug, :info, :notice, :warning]
    assert enabled == [:alert, :critical, :emergency, :error]
  end

  test "critical" do
    level = 2
    {enabled, disabled} = split(compile(level))
    assert disabled == [:debug, :error, :info, :notice, :warning]
    assert enabled == [:alert, :critical, :emergency]
  end

  test "alert" do
    level = 1
    {enabled, disabled} = split(compile(level))
    assert disabled == [:critical, :debug, :error, :info, :notice, :warning]
    assert enabled == [:alert, :emergency]
  end

  test "emergency" do
    level = 0
    {enabled, disabled} = split(compile(level))
    assert disabled == [:alert, :critical, :debug, :error, :info, :notice, :warning]
    assert enabled == [:emergency]
  end

  test "none" do
    level = -1
    {enabled, disabled} = split(compile(level))
    assert disabled == [:alert, :critical, :debug, :emergency,
      :error, :info, :notice, :warning]
    assert enabled == []
  end

  teardown_all _context do
    File.rm("#{@top}/test/#{beam(Lager)}")
    :ok
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