
**Swift Modules**

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
  "directories": {
    "source": "src"
  },
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

If a package does not include the `swiftmodule.json` file, the including package can specify the source file directory of the dependency in its `swiftmodule.json`.

```
{
  "name": "ModuleName",
  "dependencies": {
    "Dependency": "jankuca/dependency @source:src"
  }
}
```
