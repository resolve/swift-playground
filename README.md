# Swift Playground

Create and modify Xcode Swift Playgrounds from Ruby. Includes both a Ruby API and a CLI.

## Installation

Install via RubyGems:
```
$ gem install playground
```

## CLI Usage

### Creating an empty playground

The playground created is the same as as Xcode would via "File > New >
Playground…":
```
$ swift-playground new [options] example.playground
```

This command supports these options (see `swift-playground help new`):

* __`--platform=[ios|osx]`__
<br /> The target platform for the generated playground (default: ios).
* __`--[no-]reset`__
<br /> Allow the playground to be reset to it's original state via "Editor >
Reset Playground" in Xcode (default: enabled).
* __`--open`__
<br /> Open the playground in Xcode once it has been created.

### Generate a playground from markdown

```
$ swift-playground generate [options] example.md
```

This command supports the following options (see `swift-playground help
generate`) in addition to the options supported by the `new` command that are
detailed above:

* __`--stylesheet=<file>`__
<br /> CSS stylesheet for the HTML documentation sections of the playground. If one is not supplied then a default stylesheet will be used (default: none).
* __`--javascript=<file>`__
<br /> A javascript file for the HTML documentation sections of the playground. Each section is rendered independently of another and the script will not have access to the DOM from any other sections (default: none).
* __`--resources=<directory>`__
<br /> A directory of resources to be bundled with the playground (default: none).
* __`--[no-]reset`__
<br /> Allow the playground to be reset to it's original state via "Editor > Reset Playground" in Xcode (default: enabled).
* __`--open`__
<br /> Open the playground in Xcode once it has been created.
* __`--[no-]emoji`__
<br /> Convert emoji aliases (e.g. ':+1:') into emoji characters (default: enabled).

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

code = Swift::Playground::CodeSection.new <<-CODE
// Write swiftly!

import UIKit

var str = "This string has contents."
CODE

playground.sections << documentation
playground.sections << code

playground.save('~/example.playground')
```

### Generating a playground from markdown

```ruby
require 'swift/playground/generator'

playground = Swift::Playground::Generator.generate(markdown_file)
```

## Credits

Initial development by [Mark Haylock](https://github.com/mhaylock).

This work was originally inspired by the work of [Jason Sandmeyer](https://github.com/jas) (created [Playground](https://github.com/jas/playground) using Node.js) and [Sam Soffes](https://github.com/soffes) (created [Playground](https://github.com/soffes/playground) using Ruby) - thank you to you both!

Thank you to [Amanda Wagener](https://github.com/awagener) for some pair programming assistance at [Rails Camp NZ 5](http://railscamps.com).
