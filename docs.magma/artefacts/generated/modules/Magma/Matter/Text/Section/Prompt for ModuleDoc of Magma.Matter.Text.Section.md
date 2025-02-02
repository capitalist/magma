---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Matter.Text.Section]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-06 16:03:20
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

Final version: [[ModuleDoc of Magma.Matter.Text.Section]]

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

# Prompt for ModuleDoc of Magma.Matter.Text.Section

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

##### `Magma.Matter` ![[Magma.Matter#Description|]]

##### `Magma.Matter.Text` ![[Magma.Matter.Text#Description|]]


## Request

### ![[Magma.Matter.Text.Section#ModuleDoc prompt task|]]

### Description of the module `Magma.Matter.Text.Section` ![[Magma.Matter.Text.Section#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Matter.Text.Section do
  use Magma.Matter, fields: [:main_text]

  alias Magma.{Concept, Prompt}
  alias Magma.Matter.Text
  alias Magma.Artefacts.TableOfContents
  alias Magma.View

  require Logger

  @type t :: %__MODULE__{}

  @impl true
  def artefacts, do: [Magma.Artefacts.Article]

  @impl true
  def relative_base_path(%__MODULE__{main_text: main_text}) do
    Text.relative_base_path(main_text)
  end

  @impl true
  def relative_concept_path(%__MODULE__{} = section) do
    section
    |> relative_base_path()
    |> Path.join("#{concept_name(section)}.md")
  end

  @impl true
  def concept_name(%__MODULE__{name: name, main_text: main_text}) do
    "#{main_text.name} - #{name}"
  end

  @impl true
  def concept_title(%__MODULE__{name: name}), do: name

  @impl true
  def default_description(%__MODULE__{}, abstract: abstract), do: abstract

  @impl true
  def context_knowledge(%Concept{subject: %__MODULE__{main_text: main_text}}) do
    """
    #### Outline of the '#{main_text.name}' content #{View.transclude(TableOfContents.name(main_text), :title)}

    """ <>
      case Concept.load(main_text.name) do
        {:ok, text_concept} ->
          Prompt.Template.include_context_knowledge(text_concept)

        {:error, error} ->
          Logger.warning("error on main text context knowledge extraction: #{inspect(error)}")
          ""
      end
  end

  @impl true
  def prompt_concept_description_title(%__MODULE__{name: name}) do
    "Description of the intended content of the '#{name}' section"
  end

  @impl true
  def new(attrs) when is_list(attrs) do
    {:ok, struct(__MODULE__, attrs)}
  end

  def new(main_text, name) do
    new(name: name, main_text: main_text)
  end

  def new!(attrs) do
    case new(attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  def new!(main_text, name) do
    case new(main_text, name) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @impl true
  def extract_from_metadata(_document_name, document_title, metadata) do
    {main_text_link, metadata} = Map.pop(metadata, :magma_section_of)

    if main_text_link do
      with {:ok, main_text_concept} <- Concept.load_linked(main_text_link),
           {:ok, matter} <- new(main_text_concept.subject, document_title) do
        {:ok, matter, metadata}
      end
    else
      {:error, "magma_section_of missing"}
    end
  end

  def render_front_matter(%__MODULE__{} = section) do
    """
    #{super(section)}
    magma_section_of: "#{View.link_to(section.main_text)}"
    """
    |> String.trim_trailing()
  end
end

```
