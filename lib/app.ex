defmodule Lager.App do
  use Application.Behaviour
  alias GenX.Supervisor, as: Sup

  def start(_, _) do
    Sup.start_link supervision_tree
  end

  defp supervision_tree do
    children = []
    Sup.OneForOne[id: __MODULE__, registered: __MODULE__, children: children]
  end

end
