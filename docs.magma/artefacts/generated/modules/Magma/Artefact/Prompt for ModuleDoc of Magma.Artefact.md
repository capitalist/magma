---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.Artefact]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-11-03 04:39:55
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

Final version: [[ModuleDoc of Magma.Artefact]]

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

# Prompt for ModuleDoc of Magma.Artefact

## System prompt

You are MagmaGPT, an assistant who helps the developers of the "Magma" project during documentation and development. Your responses are in plain and clear English.

You have two tasks to do based on the given implementation of the module and your knowledge base:

1. generate the content of the `@doc` strings of the public functions
2. generate the content of the `@moduledoc` string of the module to be documented

Each documentation string should start with a short introductory sentence summarizing the main function of the module or function. Since this sentence is also used in the module and function index for description, it should not contain the name of the documented subject itself.

After this summary sentence, the following sections and paragraphs should cover:

- What's the purpose of this module/function?
- For moduledocs: What are the main function(s) of this module?
- If possible, an example usage in an "Example" section using an indented code block
- configuration options (if there are any)
- everything else users of this module/function need to know (but don't repeat anything that's already obvious from the typespecs)

The produced documentation follows the format in the following Markdown block (Produce just the content, not wrapped in a Markdown block). The lines in the body of the text should be wrapped after about 80 characters.

```markdown
## Function docs

### `function/1`

Summary sentence

Body

## Moduledoc

Summary sentence

Body
```

<!--
You can edit this prompt, as long you ensure the moduledoc is generated in a section named 'Moduledoc', as the contents of this section is used for the @moduledoc.
-->

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]

#### Peripherally relevant modules

##### `Magma` ![[Magma#Description|]]

##### `Magma.Artefact.Prompt` ![[Magma.Artefact.Prompt#Description|]]

##### `Magma.Artefact.Version` ![[Magma.Artefact.Version#Description|]]

![[Magma.Artefact#Context knowledge|]]


## Request

![[Magma.Artefact#ModuleDoc prompt task|]]

### Description of the module `Magma.Artefact` ![[Magma.Artefact#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.Artefact do
  alias Magma.Concept
  alias __MODULE__

  @type t :: module

  @doc """
  A callback that return the name of an artefact.
  """
  @callback name(Concept.t()) :: binary

  @doc """
  A callback that returns the name of the `Magma.Artefact.Prompt` document for this type of matter.
  """
  @callback prompt_name(Concept.t()) :: binary

  @doc """
  A callback that returns the system prompt text of the `Magma.Artefact.Prompt` document for this type of matter that describes what to generate.

  As opposed to the `c:request_prompt_task/1` this is a general, static text
  used by artefacts of this type.
  """
  @callback system_prompt_task(Concept.t()) :: binary

  @doc """
  A callback that returns the request prompt text of the `Magma.Artefact.Concept` document for this type of matter that describes what to generate.

  Despite returning also a general text like the `c:system_prompt_task/1`, this
  one is included in the "Artefacts" section of the `Magma.Concept` document
  (and only transcluded in `Magma.Artefact.Prompt` document), so that the user
  has a chance to adapt it for a specific instance of this artefact type.
  """
  @callback request_prompt_task(Concept.t()) :: binary

  @doc """
  A callback that returns the title of the "Artefacts" subsection for this type of matter in the `Magma.Concept` document.

  This section consists of links to the `Magma.Artefact.Prompt` and the
  `Magma.Artefact.Version` of this document and another subsection for the
  text returned by the `c:request_prompt_task/1` callback.
  """
  @callback concept_section_title :: binary

  @doc """
  A callback that returns the title of the "Artefacts" subsection for this type of matter in the `Magma.Concept` document where for the text returned by the `c:request_prompt_task/1` callback is rendered.

  By default, this is just the `concept_section_title/0` with `"prompt task"` appended.
  """
  @callback concept_prompt_task_section_title :: binary

  @doc """
  A callback that returns the title to be used for the `Magma.Artefact.Version` document.
  """
  @callback version_title(Artefact.Version.t()) :: binary

  @doc """
  A callback that allows to specify a text which should be included in the prologue of the `Magma.Artefact.Version` document of this artefact type.
  """
  @callback version_prologue(Artefact.Version.t()) :: binary | nil

  @doc """
  A callback that returns if the initial header of a generated `Magma.PromptResult` for this type artefact should be stripped.

  Since the title for the `Magma.PromptResult` is already defined,
  the title generated by an LLM should be ignored usually.
  For some types of artefacts, however, this should not be the case.
  These artefact types, the default implementation returning `true`,
  can be overwritten.
  """
  @callback trim_prompt_result_header? :: boolean

  @doc """
  A callback that returns the general path segment to be used for documents for this type of artefact.
  """
  @callback relative_base_path(Concept.t()) :: Path.t()

  @doc """
  A callback that returns the path for `Magma.Artefact.Prompt` documents about this type of artefact.

  Since the `Magma.PromptResult` document are always stored in the subdirectory
  where the prompt are stored, this function also determines their path.

  This path is relative to the `Magma.Vault.artefact_generation_path/0`.
  """
  @callback relative_prompt_path(Concept.t()) :: Path.t()

  @doc """
  A callback that returns the path for `Magma.Artefact.Version` documents about this type of artefact.

  This path is relative to the `Magma.Vault.artefact_version_path/0`.
  """
  @callback relative_version_path(Concept.t()) :: Path.t()

  @doc """
  A callback that allows to implement a custom `Magma.Artefact.Version` document creation function.

  This function should return `nil` if the default `Magma.Artefact.Version.create/2`
  should be used (which the default implementation does automatically).
  """
  @callback create_version(Artefact.Version.t(), keyword) ::
              {:ok, Path.t() | Artefact.Version.t()} | {:error, any} | nil

  defmacro __using__(opts) do
    matter_type = Keyword.fetch!(opts, :matter)

    quote do
      @behaviour Magma.Artefact
      alias Magma.Artefact

      def matter_type, do: unquote(matter_type)

      @impl true
      def concept_section_title, do: Artefact.type_name(__MODULE__)

      @impl true
      def concept_prompt_task_section_title, do: "#{concept_section_title()} prompt task"

      @impl true
      def prompt_name(%Concept{} = concept), do: "Prompt for #{name(concept)}"

      @impl true
      def relative_prompt_path(%Concept{} = concept) do
        concept
        |> relative_base_path()
        |> Path.join("#{prompt_name(concept)}.md")
      end

      @impl true
      def relative_version_path(%Concept{} = concept) do
        concept
        |> relative_base_path()
        |> Path.join("#{name(concept)}.md")
      end

      @impl true
      def version_title(%Artefact.Version{artefact: __MODULE__} = version), do: version.name

      @impl true
      def version_prologue(%Artefact.Version{artefact: __MODULE__}), do: nil

      @impl true
      def trim_prompt_result_header?, do: true

      @impl true
      def create_version(%Artefact.Version{artefact: __MODULE__}, opts), do: nil

      def prompt(%Concept{subject: %unquote(matter_type){}} = concept, attrs \\ []) do
        Artefact.Prompt.new(concept, __MODULE__, attrs)
      end

      def prompt!(%Concept{subject: %unquote(matter_type){}} = concept, attrs \\ []) do
        Artefact.Prompt.new!(concept, __MODULE__, attrs)
      end

      def create_prompt(
            %Concept{subject: %unquote(matter_type){}} = concept,
            attrs \\ [],
            opts \\ []
          ) do
        Artefact.Prompt.create(concept, __MODULE__, attrs, opts)
      end

      def load_version(%Concept{} = concept) do
        concept
        |> name()
        |> Artefact.Version.load()
      end

      def load_version!(concept) do
        case load_version(concept) do
          {:ok, version} -> version
          {:error, error} -> raise error
        end
      end

      defoverridable prompt_name: 1,
                     version_prologue: 1,
                     trim_prompt_result_header?: 0,
                     relative_prompt_path: 1,
                     relative_version_path: 1,
                     version_title: 1,
                     create_version: 2
    end
  end

  @doc """
  Returns the artefact type name for the given artefact type module.

  ## Example

      iex> Magma.Artefact.type_name(Magma.Artefacts.ModuleDoc)
      "ModuleDoc"

      iex> Magma.Artefact.type_name(Magma.Artefacts.Article)
      "Article"

      iex> Magma.Artefact.type_name(Magma.Vault)
      ** (RuntimeError) Invalid Magma.Artefacts type: Magma.Vault

      iex> Magma.Artefact.type_name(NonExisting)
      ** (RuntimeError) Invalid Magma.Artefacts type: NonExisting

  """
  def type_name(type) do
    if type?(type) do
      case Module.split(type) do
        ["Magma", "Artefacts" | name_parts] -> Enum.join(name_parts, ".")
        _ -> raise "Invalid Magma.Artefacts type name scheme: #{inspect(type)}"
      end
    else
      raise "Invalid Magma.Artefacts type: #{inspect(type)}"
    end
  end

  @doc """
  Returns the artefact type module for the given string.

  ## Example

      iex> Magma.Artefact.type("ModuleDoc")
      Magma.Artefacts.ModuleDoc

      iex> Magma.Artefact.type("TableOfContents")
      Magma.Artefacts.TableOfContents

      iex> Magma.Artefact.type("Vault")
      nil

      iex> Magma.Artefact.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(Magma.Artefacts, string)

    if type?(module) do
      module
    end
  end

  @doc """
  Checks if the given `module` is a `Magma.Artefact` type module.
  """
  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :relative_prompt_path, 1)
  end
end

```
