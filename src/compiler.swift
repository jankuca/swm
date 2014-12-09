import Foundation


class Compiler {
  var file_manager: NSFileManager;
  var tasks: TaskDispatcher;

  init(file_manager: NSFileManager, tasks: TaskDispatcher) {
    self.file_manager = file_manager;
    self.tasks = tasks;
  }


  func compileModule(name: String, dirname: String, cwd: String? = nil) {
    if let macosx_sdk_path = self.getSdkPath_("macosx") {
      var args = [
        "swiftc",
        "-emit-module",
        "-sdk", macosx_sdk_path,
        "-module-name", name
      ];
      args += self.findSourceFiles_(dirname);

      let build_directory = self.getBuildDirectory_(cwd);
      self.tasks.exec("xcrun", args: args, cwd: build_directory);
    } else {
      println("Error: macosx sdk not found");
    }
  }


  func compileApp(
      output_filename: String, dirname: String, cwd: String? = nil) {
    if let macosx_sdk_path = self.getSdkPath_("macosx") {
      var args = [
        "swiftc",
        "-sdk", macosx_sdk_path,
        "-o", output_filename
      ];
      args += [ "-I", self.getBuildDirectory_(cwd) ];
      args += self.findSourceFiles_(dirname);

      self.tasks.exec("xcrun", args: args, cwd: cwd);
    } else {
      println("Error: macosx sdk not found");
    }
  }


  func getBuiltModules(dirname: String) -> [String] {
    var modules = [String]();
    let build_dirname = self.getBuildDirectory_(dirname);

    if let enumerator = self.file_manager.enumeratorAtPath(build_dirname) {
      while let file = enumerator.nextObject() as? String {
        if file.hasSuffix(".swiftmodule") {
          modules.append(file.substringToIndex(advance(file.endIndex, -12)));
        }
      }
    }

    return modules;
  }


  func getSdkPath_(sdk_name: String) -> String? {
    let args = [
      "--show-sdk-path",
      "--no-cache",
      "--sdk", sdk_name
    ];
    let sdk_task = self.tasks.exec("xcrun", args: args);
    return sdk_task.output;
  }


  func getBuildDirectory_(dirname: String?) -> String {
    var build_dirname = ".modules";
    if let dirname = dirname {
      build_dirname = "\(dirname)/\(build_dirname)";
    }

    self.ensureDirectory_(build_dirname);
    return build_dirname;
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


  func ensureDirectory_(dirname: String) {
    if !self.file_manager.fileExistsAtPath(dirname) {
      self.file_manager.createDirectoryAtPath(
        dirname,
        withIntermediateDirectories: true,
        attributes: nil,
        error: nil
      );
    }
  }
}
