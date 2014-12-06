import Foundation


class InstallCommand: Command {
  var file_manager: NSFileManager;
  var module_manager: ModuleManager;

  init(module_manager: ModuleManager) {
    self.file_manager = NSFileManager.defaultManager();
    self.module_manager = module_manager;
  }


  override func run() {
    if let info = self.module_manager.readModuleInfo(self.directory) {
      self.installDependencies_(info["dependencies"]);
      self.buildCurrentPackage_(info["directories"]);
    }
  }


  func installDependencies_(dependenices: JSON) {
    for (name, path) in dependenices {
      self.installDependency_("\(name)", path: "\(path)");
    }
  }


  func buildCurrentPackage_(directories: JSON) {
    let source_directory = directories["source"];
    if source_directory.type == "String" {
      let source_dirname = "\(self.directory)/\(source_directory)";
      self.buildDirectory_(source_dirname);
    }
  }


  func installDependency_(name: String, path: String) {
    let path_parts = path.componentsSeparatedByString(" ");
    let attrs = self.parseAttributes_(path_parts);

    var url = self.parseUrl_(path_parts[0]);
    var rev = "master";
    if let rev_range = url.rangeOfString("#.+$",
        options: .RegularExpressionSearch) {
      rev = url.substringFromIndex(advance(rev_range.startIndex, 1));
      url = url.substringToIndex(rev_range.startIndex);
    }
    println("\(name) <- \(url)#\(rev)");

    self.downloadDependency_(name, url: url, rev: rev);
    self.buildDependency_(name, attrs: attrs);
  }


  func downloadDependency_(name: String, url: String, rev: String?)
      -> String? {
    let dirname = "\(self.directory)/modules/\(name)";
    if self.file_manager.fileExistsAtPath(dirname) {
      return dirname;
    }

    let init_task = NSTask();
    init_task.currentDirectoryPath = self.directory;
    init_task.launchPath = "/usr/bin/git";
    init_task.arguments = [ "init", dirname ];
    init_task.launch();
    init_task.waitUntilExit();
    if init_task.terminationStatus != 0 {
      println("Error: Failed to init the dependency \(name)");
      return nil;
    }

    let fetch_task = NSTask();
    fetch_task.currentDirectoryPath = dirname;
    fetch_task.launchPath = "/usr/bin/git";
    fetch_task.arguments = [ "fetch", url ];
    if let rev = rev {
      fetch_task.arguments.append(rev);
    };
    fetch_task.launch();
    fetch_task.waitUntilExit();
    if fetch_task.terminationStatus != 0 {
      println("Error: Failed to fetch the dependency \(name)");
      return nil;
    }

    let reset_task = NSTask();
    reset_task.currentDirectoryPath = dirname;
    reset_task.launchPath = "/usr/bin/git";
    reset_task.arguments = [ "reset", "--hard", "FETCH_HEAD" ];
    reset_task.launch();
    reset_task.waitUntilExit();
    if reset_task.terminationStatus != 0 {
      println("Error: Failed to update the dependency \(name)");
      return nil;
    }

    return dirname;
  }


  func buildDependency_(name: String, attrs: [String:String]) {
    let dependency_dirname = "\(self.directory)/modules/\(name)";
    let sub_install_cmd = InstallCommand(module_manager: self.module_manager);
    sub_install_cmd.runInDirectory(dependency_dirname);

    // TODO: override by dependency's swiftmodule.json, if present
    var source_dirname = dependency_dirname;
    if let source_directory = attrs["source"] {
      source_dirname = "\(dependency_dirname)/\(source_directory)";
    }

    let filenames = self.findSourceFiles_(source_dirname);
    self.compileModule_(name, filenames: filenames);
  }


  func parseUrl_(url_desc: String) -> String {
    var url = url_desc;
    if !url.hasPrefix("git://") {
      url = "git://github.com/\(url)";
      if let rev_range = url.rangeOfString("#.+$",
          options: .RegularExpressionSearch) {
        let rev = url.substringFromIndex(advance(rev_range.startIndex, 1));
        url = url.substringToIndex(rev_range.startIndex);
        url = "\(url).git#\(rev)";
      }
    }
    return url;
  }


  func parseAttributes_(attr_list: [String]) -> [String:String] {
    var attrs = [String:String]();
    for attr in attr_list {
      if let key_range = attr.rangeOfString("^@(\\w+):",
          options: .RegularExpressionSearch) {
        let key = attr.substringWithRange(Range(
          start: advance(key_range.startIndex, 1),
          end: advance(key_range.endIndex, -1)
        ));
        attrs[key] = attr.substringFromIndex(key_range.endIndex);
      }
    }
    return attrs;
  }


  func compileModule_(name: String, filenames: [String]) {
    if let macosx_sdk_path = self.getSdkPath_("macosx") {
      let build_directory = "\(self.directory)/.modules";
      self.ensureDirectory_(build_directory);

      let task = NSTask();
      task.currentDirectoryPath = build_directory;
      task.launchPath = "/usr/bin/xcrun";
      task.arguments = [
        "swiftc",
        "-emit-module",
        "-sdk", macosx_sdk_path,
        "-module-name", name
      ] + filenames;
      task.launch();
      task.waitUntilExit();
      println("\(name) -> \(task.currentDirectoryPath)/\(name).swiftmodule");
    } else {
      println("Error: macosx sdk not found");
    }
  }


  func getSdkPath_(sdk_name: String) -> NSString? {
    let sdk_task_output = NSPipe();
    let sdk_task = NSTask();
    sdk_task.launchPath = "/usr/bin/xcrun";
    sdk_task.arguments = [
      "--show-sdk-path",
      "--no-cache",
      "--sdk", sdk_name
    ];
    sdk_task.standardOutput = sdk_task_output;
    sdk_task.launch();
    sdk_task.waitUntilExit();

    let data = sdk_task_output.fileHandleForReading.readDataToEndOfFile();
    if let path = NSString(data: data, encoding: NSUTF8StringEncoding) {
      return path.substringToIndex(path.length - 1);
    }
    return nil;
  }


  func ensureDirectory_(dirname: String) {
    if !self.file_manager.fileExistsAtPath(dirname) {
      self.file_manager.createDirectoryAtPath(dirname,
          withIntermediateDirectories: false,
          attributes: nil,
          error: nil);
    }
  }


  func findSourceFiles_(dirname: String) -> [String] {
    var files = [String]();

    if let enumerator = self.file_manager.enumeratorAtPath(dirname) {
      while let file = enumerator.nextObject() as? String {
        if file.hasSuffix(".swift") {
          files.append("\(dirname)/\(file)");
        }
      }
    }

    return files;
  }


  func buildDirectory_(dirname: String) {
    let files = self.findSourceFiles_(dirname);
    let filenames = files.map({ file in "\(dirname)/\(file)" });
    self.buildFiles_(filenames);
  }


  func buildFiles_(filenames: [String]) {
    var build_task = NSTask();
    build_task.launchPath = "/usr/bin/xcrun";
    build_task.currentDirectoryPath = self.directory;
    build_task.arguments = [
      "swiftc",
      "-o", "\(self.directory)/build/app",
      "-I", "\(self.directory)/.modules"
    ] + filenames;
    build_task.launch();
    build_task.waitUntilExit();
  }
}
