
class InstallCommand: Command {
  var module_manager: ModuleManager;
  var compiler: Compiler;

  init(module_manager: ModuleManager, compiler: Compiler) {
    self.module_manager = module_manager;
    self.compiler = compiler;
  }


  override func run() -> InstallCommandResult {
    let result = InstallCommandResult(success: true);

    if let info = self.module_manager.readModuleInfo(self.directory) {
      if (result.success) {
        let (install_success, install_tree) = self.installDependencies_(info);
        result.success = result.success && install_success;
        result.setDependencyTree(install_tree);
      }
      if (result.success) {
        let build_success = self.buildCurrentPackage_(info);
        result.success = result.success && build_success;
      }
    }

    return result;
  }


  func installDependencies_(info: ModuleInfo) -> (Bool, [String:[String]]) {
    var install_success = true;
    var install_list = [String:[String]]();

    for (name, ref) in info.dependencies {
      if let (result, dependency_info) = self.installDependency_(name, ref: ref) {
        install_success = result.success && result.success;
        var children = [String]();
        for (dependency_name, dependency_children) in result.dependency_tree {
          install_list[dependency_name] = dependency_children;
        }
        install_list[name] = children;

        let build_success = self.buildDependency_(dependency_info);
        install_success = result.success && build_success;
      }
    }

    return (install_success, install_list);
  }


  func installDependency_(name: String, ref: DependencyRef)
      -> (InstallCommandResult, ModuleInfo)? {
    if let dependency_info = self.module_manager.downloadModuleDependency(
        self.directory, name: name, ref: ref) {
      if let dependency_dirname = dependency_info.directory {
        let sub_install_cmd = InstallCommand(
          module_manager: self.module_manager,
          compiler: compiler
        );
        sub_install_cmd.directory = dependency_dirname;
        let sub_result = sub_install_cmd.run();
        return (sub_result, dependency_info);
      }
    }
    return nil;
  }


  func buildDependency_(info: ModuleInfo) -> Bool {
    if let name = info.name {
      if let source_dirname = info.directories["source"] {
        self.compiler.compileModule(
          name,
          dirname: source_dirname,
          cwd: self.directory
        );
      }
    }
    return true;
  }


  func buildCurrentPackage_(info: ModuleInfo) -> Bool {
    if let source_dirname = info.directories["source"] {
      let build_filename = "\(self.directory)/build/app";
      self.compiler.compileApp(
        build_filename,
        dirname: source_dirname,
        cwd: self.directory
      );
    }
    return true;
  }
}
