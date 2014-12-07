import Foundation


class ModuleManager {
  var file_manager: NSFileManager;
  var tasks: TaskDispatcher;

  init(file_manager: NSFileManager, tasks: TaskDispatcher) {
    self.file_manager = file_manager;
    self.tasks = tasks;
  }


  func readModuleInfo(dirname: String) -> ModuleInfo? {
    if !self.file_manager.fileExistsAtPath(dirname) {
      return nil;
    }

    let info = ModuleInfo();
    info.directory = dirname;
    if let json = self.readModuleFile_(dirname) {
      self.populateModuleInfo_(info, json: json);
      return info;
    }

    return info;
  }


  func readModuleFile_(dirname: String) -> JSON? {
    let filename = "\(dirname)/swiftmodule.json";
    if let data = String(contentsOfFile: filename) {
      let json = JSON.parse(data);
      return json;
    }
    return nil;
  }


  func populateModuleInfo_(info: ModuleInfo, json: JSON) {
    if json["name"].type == "String" {
      let name = json["name"];
      info.name = "\(name)";
    }
    if json["dependencies"].type == "Dictionary" {
      for (name, path) in json["dependencies"] {
        info.addDependency("\(name)", path: "\(path)");
      }
    }
    if json["directories"].type == "Dictionary" {
      for (name, path) in json["directories"] {
        info.directories["\(name)"] = "\(dirname)/\(path)";
      }
    }
  }


  func downloadModuleDependencies(
      dirname: String, dependencies: [String:DependencyRef])
      -> [String:ModuleInfo?] {
    var results = [String:ModuleInfo?]();
    for (name, ref) in dependencies {
      results[name] = self.downloadModuleDependency(
          dirname, name: name, ref: ref);
    }
    return results;
  }


  func downloadModuleDependency(
      module_dirname: String, name: String, ref: DependencyRef)
      -> ModuleInfo? {
    let dirname = "\(module_dirname)/modules/\(name)";
    if self.file_manager.fileExistsAtPath(dirname) {
      return self.getDependencyInfo_(dirname, name: name, attrs: ref.attrs);
    }

    let init_args = [ "init", dirname ];
    let init_task = self.tasks.exec("git", args: init_args);
    if init_task.code != 0 {
      println("Error: Failed to init the dependency \(name)");
      return nil;
    }

    var fetch_args = [ "fetch", ref.url ];
    if let revision = ref.revision {
      fetch_args.append(revision);
    };
    let fetch_task = self.tasks.exec("git", args: fetch_args, cwd: dirname);
    if fetch_task.code != 0 {
      println("Error: Failed to fetch the dependency \(name)");
      return nil;
    }

    let reset_args = [ "reset", "--hard", "FETCH_HEAD" ];
    let reset_task = self.tasks.exec("git", args: reset_args, cwd: dirname);
    if reset_task.code != 0 {
      println("Error: Failed to update the dependency \(name)");
      return nil;
    }

    let rm_git_args = [ "-rf", "\(dirname)/.git" ];
    let rm_git_task = self.tasks.exec("/bin/rm", args: rm_git_args, cwd: dirname);
    if rm_git_task.code != 0 {
      println("Error: Failed to clean the dependency \(name)");
      return nil;
    }

    return self.getDependencyInfo_(dirname, name: name, attrs: ref.attrs);
  }


  func getDependencyInfo_(
      dirname: String, name: String, attrs: [String:String]) -> ModuleInfo? {
    let info = self.readModuleInfo(dirname);
    if let info = info {
      info.name = name;
      self.applyDependencyAttributes_(info, attrs: attrs);
    }
    return info;
  }


  func applyDependencyAttributes_(info: ModuleInfo, attrs: [String:String]) {
    var source_dirname = info.directories["source"];
    if source_dirname == nil {
      if let dependency_dirname = info.directory {
        if let source_attr = attrs["source"] {
          info.directories["source"] = "\(dependency_dirname)/\(source_attr)";
        } else {
          info.directories["source"] = dependency_dirname;
        }
      }
    }
  }
}
