# store

A simple key-value pair database for your shell functions.

And by "database" I mean a plain json file in a directory somewhere in your system. This is basically a helper that does some CRUD operations to a json file.

## Getting started

### Installation

* Easiest:

Go to the [release page](https://github.com/VonHeikemen/store.v/releases) and download the zip file that corresponds to your operating system. Then put the executable somewhere in your PATH.

* From source:

You'll need to install [v-lang](https://vlang.io/)'s compiler (at least version `0.2.2 commit: 90292ce`). After that follow these steps:

```sh
git clone https://github.com/VonHeikemen/store.v.git
cd store.v
v -prod store.v
```

You'll end up with a `store` executable in the root directory. Add that to your PATH.

## Usage

```sh
store [document] [command] [args]
```

### Commands

#### `store help [command]`
Prints help information. If `command` is provided it will you a more detailed usage of a command.

#### `store version`
Prints version information.

#### `store [document] create`
Creates an empty json file in your "data folder."

#### `store [document] query <entry>`
Extract the value of an entry.

#### `store [document] list`
Show all the entries of a document.

#### `store [document] add <entry> <value>`
Creates a new entry in the document.

#### `store [document] update <entry> <value>`
Change the value of an entry.

#### `store [document] remove <entry>`
Deletes an entry from the document.

#### `store [document] location`
Show the file path to the document.

### Environment
Set the `STORE_V_FOLDER` environment variable to specify the path to the "data folder" where documents will be saved.


### Examples

All this examples use a document called `bookmark` but this of course could be anything you want.

Create a document:
```sh
store bookmark create
```

Add an entry to a document:
```sh
store bookmark add ddg "https://duckduckgo.com/"
```

Extract the value of an entry:
```sh
 store bookmark query ddg
```

List all entries in a document:
```sh
store bookmark list
```

Change the value of an entry:
```sh
store bookmark update ddg "https://lite.duckduckgo.com/lite/"
```

Delete an entry from a document:
```sh
store bookmark remove ddg
```

show path to the document:
```sh
store bookmark location
```

## Prior work

If your interested there is version of this tool which is a script written in POSIX compliant shell syntax (mostly): [store-json](https://github.com/VonHeikemen/dotfiles/blob/876342c8e7f9e73c1a3e5083b6c4f9405aabe5ba/my-configs/bin/store-json).

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)
