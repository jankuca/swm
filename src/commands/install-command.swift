import Foundation


class InstallCommand: Command {
  var module_manager: ModuleManager;

  init(module_manager: ModuleManager) {
    self.module_manager = module_manager;
  }


  override func run() {
    println("run install command");

    if let info = self.module_manager.readModuleInfo("./swiftmodule.json") {
      let dependencies = info["dependencies"];
      self.installDependencies_(dependencies);
    } else {
      println("module.json not found");
    }
  }


  func installDependencies_(dependenices: JSON) {
    for (name, path) in dependenices {
      self.installDependency_("\(name)", path: "\(path)");
    }
  }


  func installDependency_(name: String, path: String) {
    let path_parts = path.componentsSeparatedByString(" ");
    let url = self.parseUrl_(path_parts[0]);
    println("Dependency: \(name) from \(url)");
    // TODO: download dependency (or should this be done via bower?)
    if path_parts.count != 1 {
      // TODO: override by dependency's swiftmodule.json, if present
      let path_items = Array(path_parts[1..<path_parts.count]);
      let dep_relative_files = self.parseFiles_(path_items);
      let files = dep_relative_files.map({ (file) in "modules/\(name)/\(file)"; });
      print("Module files: "); println(files);
      self.compileModule_(name, files: files);
    }
  }


  func parseUrl_(url_desc: String) -> String {
    var url = url_desc;
    if !url.hasPrefix("git://") {
      url = "git://github.com/\(url)";
    }
    return url;
  }


  func parseFiles_(items: [String]) -> [String] {
    let file_items = items.filter({ $0.hasPrefix("<") && $0.hasSuffix(">") });
    var files = [String]();
    for file_item in file_items {
      let range = Range(
        start: advance(file_item.startIndex, 1),
        end: advance(file_item.endIndex, -1)
      );
      files.append("\(file_item.substringWithRange(range))");
    }
    return files;
  }


  func compileModule_(name: String, files: [String]) {
    if let macosx_sdk_path = self.getSdkPath_("macosx") {
      let task = NSTask();
      task.currentDirectoryPath = "\(self.directory)/.modules";
      println(".swiftmodule directory location: \(task.currentDirectoryPath)");

      let file_paths = files.map({ (file) in "../\(file)" });
      task.launchPath = "/usr/bin/xcrun";
      task.arguments = [ "swiftc", "-emit-module", "-sdk", macosx_sdk_path, "-module-name", name ] + file_paths;
      task.launch();
      task.waitUntilExit();
      println("-> \(task.currentDirectoryPath)/\(name).swiftmodule");
    }
  }


  func getSdkPath_(sdk_name: String) -> NSString? {
    let sdk_task_output = NSPipe();
    let sdk_task = NSTask();
    sdk_task.launchPath = "/usr/bin/xcrun";
    sdk_task.arguments = [ "--show-sdk-path", "--no-cache", "--sdk", sdk_name ];
    sdk_task.standardOutput = sdk_task_output;
    sdk_task.launch();
    sdk_task.waitUntilExit();

    let data = sdk_task_output.fileHandleForReading.readDataToEndOfFile();
    if let path = NSString(data: data, encoding: NSUTF8StringEncoding) {
      return path.substringToIndex(path.length - 1);
    }
    return nil;
  }
}
