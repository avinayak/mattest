defmodule NifDemo do
  @moduledoc """
  Documentation for `Mattest`.
  """

  @on_load :load_nifs

  def load_nifs do
    :erlang.load_nif(:code.priv_dir(:mattest) ++ ~c"/nif_demo", 0)
  end

  def add(_a, _b), do: raise("NIF add/2 not implemented")
end
