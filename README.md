# Swift Playground

Create and modify Xcode Swift Playgrounds from Ruby. Includes both a Ruby API and a CLI.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Contents

- [Installation](#installation)
- [CLI Usage](#cli-usage)
  - [Creating an empty playground](#creating-an-empty-playground)
  - [Generate a playground from markdown](#generate-a-playground-from-markdown)
- [Ruby Usage](#ruby-usage)
  - [Constructing a basic playground](#constructing-a-basic-playground)
  - [Generating a playground from markdown](#generating-a-playground-from-markdown)
  - [Sections](#sections)
- [Markdown Format](#markdown-format)
- [Default Stylesheet](#default-stylesheet)
- [Credits](#credits)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation

Install via RubyGems:
```
$ gem install playground
```

## CLI Usage

### Creating an empty playground

The playground created is the same as as Xcode would via "File > New > Playground…":
```
$ swift-playground new [options] example.playground
```

This command supports these options (see `swift-playground help new`):

* __`--platform=[ios|osx]`__

    The target platform for the generated playground (default: ios).
* __`--[no-]reset`__

    Allow the playground to be reset to it's original state via "Editor > Reset Playground" in Xcode (default: enabled).
* __`--open`__

    Open the playground in Xcode once it has been created.

### Generate a playground from markdown

```
$ swift-playground generate [options] example.md
```

This command supports the following options (see `swift-playground help generate`) in addition to the options supported by the `new` command that are detailed above:

* __`--stylesheet=<file>`__

    CSS stylesheet for the HTML documentation sections of the playground. [SASS/SCSS syntax](http://sass-lang.com) is supported. This will be included after the default stylesheet. (default: none).
* __`--javascript=<file>`__

    A javascript file for the HTML documentation sections of the playground. Each section is rendered independently of another and the script will not have access to the DOM from any other sections (default: none).
* __`--[no-]reset`__

    Allow the playground to be reset to it's original state via "Editor > Reset Playground" in Xcode (default: enabled).
* __`--open`__

    Open the playground in Xcode once it has been created.
* __`--[no-]emoji`__

    Convert emoji aliases (e.g. `:+1:`) into emoji characters (default: enabled).
* __`--[no-]highlighting`__

    Detect non-swift code blocks and add syntax highlighting. Only has an effect if '[github-linguist](https://github.com/github/linguist)' and '[pygments.rb](https://github.com/tmm1/pygments.rb)' gems are installed. (default: enabled).
* __`--highlighting-style=<style>`__

    The name of a pygments (http://pygments.org/) style to apply to syntax highlighted code blocks. Set to 'custom' if providing your own pygments-compatible stylesheet. Ignored if `--no-highlighting` is set. (default: default).

## Ruby Usage

### Constructing a basic playground

```ruby
require 'swift/playground'

playground = Swift::Playground.new

documentation = Swift::Playground::DocumentationSection.new <<-HTML
<h1>Welcome to the Playground!</h1>
<p>
  This is an <em>awesome</em> example playground!
</p>
HTML

code = Swift::Playground::CodeSection.new <<-SWIFT
// Write swiftly!

import UIKit

var str = "This string has contents."
SWIFT

playground.sections << documentation
playground.sections << code

playground.save('~/example.playground')
```

### Generating a playground from markdown

```ruby
require 'swift/playground/generator'

playground = Swift::Playground::Generator.generate(markdown_file)
```

### Sections

There are two section types you can use to construct a playground in Ruby:

#### `DocumentationSection`

These contain HTML that is rendered within the playground. You can construct a `DocumentationSection` with either a path to an HTML file or the raw HTML content itself (either as a String or an IO object):

```ruby
# All of the following are valid values for content:
content = '/path/to/file.html'
content = Pathname.new('/path/to/file.html')
content = File.open('/path/to/file.html')
content = <<-HTML
  <h1>An example HTML fragment</h1>
  <p>
    Note this is a fragment, it does not have a root 'html' or 'body' tag.
  </p>
HTML

# Creating the section:
section = Swift::Playground::DocumentationSection.new(content)

# Adding the section to a playground:
playground.sections << section
# or perhaps:
playground.sections.insert(0, section)
```

The content you provide _must_ be an HTML fragment - if a `<html>`, `<head>` or `<body>` tag is present an exception will be raised.

#### `CodeSection`

These contain the executable swift code, and each playground must contain at least one of these sections. Constructing these sections is the same as `DocumentationSection` - you can use either a path to a swift file, or the raw swift code itself (either as a String or an IO object):

```ruby
# All of the following are valid values for content:
content = '/path/to/file.swift'
content = Pathname.new('/path/to/file.swift')
content = File.open('/path/to/file.swift')
content = <<-SWIFT
  // Write swiftly!

  import UIKit

  var str = "This string has contents."
SWIFT

# Creating the section:
section = Swift::Playground::CodeSection.new(content)

# Set the 'style' of the section. Apple only document 'setup' at the
# moment and this is all that is supported.
#
# 'setup' will wrap the section in a "Setup" label that can be toggled
# (and initially appears minimized):
section.style = 'setup'

# Adding the section to a playground:
playground.sections << section
# or perhaps:
playground.sections.insert(0, section)
```

## Markdown Format

Generating a playground from Markdown supports the [Github Flavoured Markdown](https://help.github.com/articles/github-flavored-markdown/) syntax.

## Default Stylesheet

Each documentation section is generated with a [default stylesheet](lib/swift/playground/template/Documentation/defaults.css.scss) loaded before any custom stylesheet. This default stylesheet aims to provide an improved baseline over what is already provided by the webkit renderer used in the Playground.

It does so in two very specific ways:
  1. The default font size is adjusted so at `1rem` the default Xcode font "Menlo" will render at exactly the same size as it would in the swift code sections of the playground. This is true even if the user has changed the editor font size.
  2. A "gutter" (`body > .gutter`) is added that renders a line where the editor gutter appears in Xcode when line numbers are disabled. When Line numbers are visible it will appear centered with the line numbers.

Both of these features of the default stylesheet rely on aspects of the Xcode interface the could change in future versions, so there are no guarantees that what looks best now will always looks best.

The stylesheet also sets the default font of `<code>` and `<pre>` elements to "Menlo" which matches with the current default Xcode font.

If you wish to override any of this behavior, [take a look at the stylesheet](lib/swift/playground/template/Documentation/defaults.css.scss) (written in SCSS) to see what you will need to aim to override.

## Credits

Initial development by [Mark Haylock](https://github.com/mhaylock). Development sponsored by [Resolve Digital](http://resolve.digital).

This work was originally inspired by the work of [Jason Sandmeyer](https://github.com/jas) (created [Playground](https://github.com/jas/playground) using Node.js) and [Sam Soffes](https://github.com/soffes) (created [Playground](https://github.com/soffes/playground) using Ruby) - thank you to you both!

Thank you to [Amanda Wagener](https://github.com/awagener) for some pair programming assistance at [Rails Camp NZ 5](http://railscamps.com).
