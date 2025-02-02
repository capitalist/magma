---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "[[Magma.DocumentStruct]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-18 14:52:48
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

Final version: [[ModuleDoc of Magma.DocumentStruct]]

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

# Prompt for ModuleDoc of Magma.DocumentStruct

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

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response (unless its explicitly requested to include some parts of it) as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]

#### Peripherally relevant modules

##### `Magma` ![[Magma#Description|]]

##### `Magma.DocumentStruct.Section` ![[Magma.DocumentStruct.Section#Description|]]


## Request

![[Magma.DocumentStruct#ModuleDoc prompt task|]]

### Description of the module `Magma.DocumentStruct` ![[Magma.DocumentStruct#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

```elixir
defmodule Magma.DocumentStruct do
  use Magma

  defstruct [:prologue, :sections]

  alias Magma.DocumentStruct.{Section, Parser}
  alias Magma.DocumentStruct.TransclusionResolution

  @type t :: %__MODULE__{
          prologue: binary,
          sections: [Section.t()]
        }

  @doc false
  @pandoc_extension {:markdown,
   %{
     enable: [:wikilinks_title_after_pipe],
     disable: [
       :multiline_tables,
       :smart,
       # for unknown reasons Pandoc sometimes generates header attributes where there should be none, when this is enabled
       :header_attributes,
       # this extension causes HTML comments to be converted to code blocks
       :raw_attribute
     ]
   }}
  def pandoc_extension, do: @pandoc_extension

  @doc false
  def new(args) do
    struct(__MODULE__, args)
  end

  @doc """
  TODO
  """
  defdelegate parse(content), to: Parser

  @doc """
  Fetches the section with the given `title` and returns it in an ok tuple.

  If no section with `section` exists, it returns `:error`.

  This implements `Access.fetch/2` function, so that the `document_struct[title]`
  syntax is supported.

  Note that only sections directly under the given section is searched.
  If a recursive search is needed, `section_by_title/2` should be used.
  """
  defdelegate fetch(document_struct, key), to: Section

  @doc """
  Fetches the first section with the given `title`.

  Other than accessing the sections with the `fetch/2`, this searches the
  sections recursively.
  """
  @spec section_by_title(t(), binary) :: Section.t() | nil
  def section_by_title(%{sections: sections}, title) do
    Enum.find_value(sections, &Section.section_by_title(&1, title))
  end

  @doc """
  Returns the first section.

  Assuming that the first section with header level 1 is the main section.
  """
  @spec main_section(t()) :: Section.t() | nil
  def main_section(%{sections: [%Section{} = main_section | _]}), do: main_section
  def main_section(%{sections: []}), do: nil

  @doc """
  Returns the header title of the main section.
  """
  @spec title(t()) :: binary | nil
  def title(document) do
    if main_section = main_section(document) do
      String.trim(main_section.title)
    end
  end

  def to_string(%{prologue: prologue} = document) do
    %Panpipe.Document{children: prologue ++ ast(document)}
    # TODO: use new way to enabling and disabling extensions on format functions
    #      |> Panpipe.to_markdown()
    |> Panpipe.Pandoc.Conversion.convert(to: @pandoc_extension, wrap: "none")
  end

  defp ast(%{sections: sections}, opts \\ []) do
    Enum.flat_map(sections, &Section.ast(&1, opts))
  end

  def set_level(%__MODULE__{} = document_struct, level) do
    %__MODULE__{
      document_struct
      | sections: Enum.map(document_struct.sections, &Section.set_level(&1, level))
    }
  end

  def remove_comments(%__MODULE__{} = document_struct) do
    %__MODULE__{
      document_struct
      | prologue: Section.remove_comments(document_struct.prologue),
        sections: Enum.map(document_struct.sections, &Section.remove_comments/1)
    }
  end

  defdelegate resolve_transclusions(document_struct), to: TransclusionResolution
end

```
