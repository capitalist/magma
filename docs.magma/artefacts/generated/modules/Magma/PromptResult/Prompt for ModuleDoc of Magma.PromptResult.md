---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.PromptResult]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-06 16:03:21
tags: [magma-vault]
aliases: []
---

**Generated results**

```dataview
TABLE
	tags AS Tags,
	magma_generation_type AS Generator,
	magma_generation_params AS Params
WHERE magma_prompt = [[]]
```

Final version: [[ModuleDoc of Magma.PromptResult]]

**Actions**

```button
name Execute
type command
action Shell commands: Execute: magma.prompt.exec
color blue
```
```button
name Execute manually
type command
action Shell commands: Execute: magma.prompt.exec-manual
color blue
```
```button
name Copy to clipboard
type command
action Shell commands: Execute: magma.prompt.copy
color default
```
```button
name Update
type command
action Shell commands: Execute: magma.prompt.update
color default
```

# Prompt for ModuleDoc of Magma.PromptResult

## System prompt

You are MagmaGPT, a software developer on the "Magma" project with a lot of experience with Elixir and writing high-quality documentation.

Your task is to write documentation for Elixir modules. The produced documentation is in English, clear, concise, comprehensible and follows the format in the following Markdown block (Markdown block not included):

```markdown
## Moduledoc

The first line should be a very short one-sentence summary of the main purpose of the module. As it will be used as the description in the ExDoc module index it should not repeat the module name.

Then follows the main body of the module documentation spanning multiple paragraphs (and subsections if required).


## Function docs

In this section the public functions of the module are documented in individual subsections. If a function is already documented perfectly, just write "Perfect!" in the respective section.

### `function/1`

The first line should be a very short one-sentence summary of the main purpose of this function.

Then follows the main body of the function documentation.
```

<!--
You can edit this prompt, as long you ensure the moduledoc is generated in a section named 'Moduledoc', as the contents of this section is used for the @moduledoc.
-->

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]

#### Peripherally relevant modules

##### `Magma` ![[Magma#Description|]]


## Request

### ![[Magma.PromptResult#ModuleDoc prompt task|]]

### Description of the module `Magma.PromptResult` ![[Magma.PromptResult#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.PromptResult do
  use Magma.Document, fields: [:prompt, :generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Generation, Prompt, View}
  alias Magma.Document.Loader

  import Magma.Utils, only: [init_field: 2, set_file_read_only: 1]

  require Logger

  @impl true
  def title(%__MODULE__{prompt: %Prompt{} = prompt}) do
    "Prompt result of '#{prompt.name}'"
  end

  @impl true
  def title(%__MODULE__{prompt: %Artefact.Prompt{artefact: artefact, concept: concept}}) do
    "Generated #{artefact.name(concept)}"
  end

  def build_name(%__MODULE__{prompt: %Prompt{} = prompt} = result) do
    "#{prompt.name} (Prompt result #{NaiveDateTime.to_iso8601(result.created_at)})"
  end

  def build_name(%__MODULE__{} = result) do
    "#{title(result)} (#{NaiveDateTime.to_iso8601(result.created_at)})"
  end

  @impl true
  def build_path(%__MODULE__{prompt: %Prompt{}} = result) do
    {:ok,
     [Prompt.path_prefix(), "__prompt_results__", "#{build_name(result)}.md"]
     |> Vault.path()}
  end

  @impl true
  def build_path(
        %__MODULE__{prompt: %Artefact.Prompt{artefact: artefact, concept: concept}} = result
      ) do
    {:ok,
     [
       concept |> artefact.relative_prompt_path() |> Path.dirname(),
       "__prompt_results__",
       "#{build_name(result)}.md"
     ]
     |> Vault.artefact_generation_path()}
  end

  @impl true
  def from(%__MODULE__{} = result), do: result
  def from(%Artefact.Version{} = version), do: version.draft

  def new(prompt, attrs \\ []) do
    struct(__MODULE__, [{:prompt, prompt} | attrs])
    |> init_field(created_at: Document.now())
    |> Document.init_path()
  end

  def new!(prompt, attrs \\ []) do
    case new(prompt, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(prompt, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, []) do
    with {:ok, document} <-
           document
           |> Document.init(generation: document.prompt.generation || Generation.default().new!())
           |> execute_prompt(opts),
         {:ok, document} <- Document.create(document, opts) do
      make_read_only(document)
      {:ok, document}
    end
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.PromptResult.create/3 is available only with an initialized document"
      )

  def create(prompt, attrs, opts) do
    with {:ok, document} <- new(prompt, attrs) do
      create(document, opts)
    end
  end

  defp execute_prompt(%__MODULE__{} = document, opts) do
    with {:ok, result} <- Generation.execute(document.generation, document.prompt, opts) do
      {:ok,
       %__MODULE__{
         document
         | content: render(document, post_process_result(document, result))
       }}
    end
  end

  defp post_process_result(document, result) do
    result
    |> String.trim_leading()
    |> trim_header(document)
    |> String.trim_trailing()
  end

  defp trim_header("#" <> _ = result, document) do
    if trim_header?(document) do
      case String.split(result, "\n", parts: 2) do
        [_, rest] -> String.trim_leading(rest)
        # It seems we're only getting just a header and nothing else, so we at least indent it.
        [only_header_result] -> "#" <> only_header_result
      end
    else
      result
    end
  end

  defp trim_header(result, _), do: result

  defp trim_header?(%__MODULE__{prompt: %Artefact.Prompt{artefact: artefact_type}}) do
    artefact_type.trim_prompt_result_header?()
  end

  defp trim_header?(_), do: false

  defp render(prompt_result, execution_result) do
    """

    #{controls(prompt_result)}

    # #{title(prompt_result)}

    #{execution_result}
    """
  end

  def controls(%__MODULE__{prompt: %Prompt{}}) do
    View.delete_current_file_button()
  end

  def controls(%__MODULE__{prompt: %Artefact.Prompt{}} = prompt_result) do
    """
    #{View.button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
    #{View.delete_current_file_button()}

    Final version: #{View.link_to_version(prompt_result)}
    """
    |> String.trim_trailing()
  end

  @impl true
  def render_front_matter(%__MODULE__{} = document) do
    """
    magma_prompt: "#{View.link_to(document.prompt)}"
    magma_generation_type: #{inspect(Magma.Generation.short_name(document.generation))}
    magma_generation_params: #{View.yaml_nested_map(document.generation)}
    """
    |> String.trim_trailing()
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = prompt_result) do
    {prompt_link, metadata} = Map.pop(prompt_result.custom_metadata, :magma_prompt)

    if prompt_link do
      with {:ok, prompt} <- Loader.load_linked([Prompt, Artefact.Prompt], prompt_link),
           {:ok, generation, metadata} <- Generation.extract_from_metadata(metadata) do
        {:ok,
         %__MODULE__{
           prompt_result
           | prompt: prompt,
             generation: generation,
             custom_metadata: metadata
         }}
      end
    else
      {:error, "magma_prompt missing"}
    end
  end

  defp make_read_only(%__MODULE__{generation: %Generation.Manual{}} = result), do: result

  defp make_read_only(result) do
    case set_file_read_only(result.path) do
      :ok ->
        result

      {:error, error} ->
        Logger.warning("Failed to make #{result.path} read-only: #{inspect(error)}")
        result
    end
  end
end

```
