
**swift module manager**

The Swift Modules manager similar to the JavaScript world's *npm* and *bower*

# Installation

```
$ npm install -g swm
```

or without node.js:

```
$ curl "https://raw.github.com/jankuca/swm/master/install.sh" | sh
```

# Usage

Module dependencies are declared in a `swiftmodule.json` file in the JSON format:

```
{
  "name": "ModuleName",
  "dependencies": {
    "Dependency": "jankuca/dependecy,
    "MyOtherDependency": "git://github.com/jankuca/other-dependency"
  }
}
```

```
$ swm install
```

## Using packages without a swiftmodule.json file

If a package does not include the `swiftmodule.json` file, the including package needs to list the paths to the source files in its `swiftmodule.json`.

```
{
  "name": "ModuleName",
  "dependencies": {
    "Dependency": "jankuca/dependency <src/something.swift> <src/main.swift>"
  }
}
```

As of right now, the all files need to be listed; pattern matching is not possible.
