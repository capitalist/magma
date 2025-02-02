defmodule Magma do
  @moduledoc """
  Magma is an environment for writing and executing complex prompts.

  It is primarily designed to support developers in documenting their projects.
  It provides a system of documents for predefined workflows, to generate
  various documentation artefacts.

  Read the [User Guide](Magma User Guide - Introduction to Magma (article section).md) to learn more.
  """

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: [defmoduledoc: 0]

      defmoduledoc()
    end
  end

  @doc """
  Adds the contents of the final version of the `Magma.Artefacts.ModuleDoc` as the `@moduledoc`.

  Usually this done via `use Magma`.
  """
  defmacro defmoduledoc do
    quote do
      magma_moduledoc_path = Magma.Artefacts.ModuleDoc.version_path(__MODULE__)
      @external_resource magma_moduledoc_path

      if moduledoc = Magma.Artefacts.ModuleDoc.get(__MODULE__) do
        @moduledoc moduledoc
      else
        Magma.__moduledoc_artefact_not_found__(__MODULE__, magma_moduledoc_path)
      end
    end
  end

  @doc false
  def __moduledoc_artefact_not_found__(module, path) do
    case Application.get_env(:magma, :on_moduledoc_artefact_not_found) do
      :warn ->
        IO.warn("No Magma artefact for moduledoc of #{inspect(module)} found at #{path}")

      _ ->
        nil
    end
  end
end
