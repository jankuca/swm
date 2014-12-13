
**Swift Modules**

The Swift Modules manager similar to the JavaScript world's *npm* and *bower*

# Installation


```
$ curl "https://raw.github.com/jankuca/swm/master/install.sh" | bash
```

# Usage

## Dependencies

Module dependencies are declared in a `swiftmodule.json` file in the JSON format:

```
{
  "name": "ModuleName",
  "directories": {
    "source": "src"
  },
  "dependencies": {
    "Dependency": "jankuca/dependecy",
    "MyOtherDependency": "git://github.com/jankuca/other-dependency"
  }
}
```

```
$ swm install
```

The dependencies are then importable via the `import` Swift statement using the names specified in the `dependencies` map of the `swiftmodule.json` file.

### Using packages without a swiftmodule.json file

If a package does not include the `swiftmodule.json` file, the including package can specify the source file directory of the dependency in its `swiftmodule.json`.

```
{
  "name": "ModuleName",
  "dependencies": {
    "Dependency": "jankuca/dependency @source:src"
  }
}
```

## Building

SWM can also build the actual app (the root module). If a `source` directory is specified in the `swiftmodule.json` file, all `.swift` files inside that subtree are compiled into a binary.

```
$ swm build
```

Note that `swm install` also runs this internally.

## Code Signing

Once the app is built, it needs to be code-signed for distribution using a certificate obtained from Apple. SWM makes this dead simple by listing the available certificates and provisioning profiles.

There are two signing modes:

1. `store` – should be used for signing for the App Store or other distribution
2. `device` – should be used for signing for development and testing purposes; this adds a provisioning profile to the app package.

```
$ swm sign store
Certificate:
  1) CF826998D43332…499C595FCE980F20  "iPhone Developer: … (…)"
1
Signature for device
  Certificate: CF826998D43332…499C595FCE980F20
  Provisioning Profile: (none)
ok
```

The command prompts for the certificate number (`1` in the case above).

```
$ swm sign device
Certificate:
  1) CF826998D43332…499C595FCE980F20  "iPhone Developer: … (…)"
1
Provisioning Profile:
  1) 7716db78-0b66-…-9fbf-3a9b653ec84a
1
Signature for device
  Certificate: CF826998D43332…499C595FCE980F20
  Provisioning Profile: 7716db78-0b66-…-9fbf-3a9b653ec84a
ok
```
