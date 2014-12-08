
class InstallCommand: Command {
  var module_manager: ModuleManager;
  var compiler: Compiler;

  init(module_manager: ModuleManager, compiler: Compiler) {
    self.module_manager = module_manager;
    self.compiler = compiler;
  }


  override func run() {
    if let info = self.module_manager.readModuleInfo(self.directory) {
      self.installDependencies_(info);
      self.buildCurrentPackage_(info);
    }
  }


  func installDependencies_(info: ModuleInfo) {
    for (name, ref) in info.dependencies {
      if let dependency_info = self.installDependency_(name, ref: ref) {
        self.buildDependency_(dependency_info);
      }
    }
  }


  func installDependency_(name: String, ref: DependencyRef) -> ModuleInfo? {
    if let revision = ref.revision {
      println("\(name) <- \(ref.url)#\(revision)");
    } else {
      println("\(name) <- \(ref.url)");
    }

    if let dependency_info = self.module_manager.downloadModuleDependency(
        self.directory, name: name, ref: ref) {
      if let dependency_dirname = dependency_info.directory {
        let sub_install_cmd = InstallCommand(
          module_manager: self.module_manager,
          compiler: compiler
        );
        sub_install_cmd.directory = dependency_dirname;
        sub_install_cmd.run();
        return dependency_info;
      }
    }
    return nil;
  }


  func buildDependency_(info: ModuleInfo) {
    if let name = info.name {
      if let source_dirname = info.directories["source"] {
        self.compiler.compileModule(
          name,
          dirname: source_dirname,
          cwd: self.directory
        );
        println("\(name) -> \(name).swiftmodule");
      }
    }
  }


  func buildCurrentPackage_(info: ModuleInfo) {
    if let source_dirname = info.directories["source"] {
      let build_filename = "\(self.directory)/build/app";
      self.compiler.compileApp(
        build_filename,
        dirname: source_dirname,
        cwd: self.directory
      );
    }
  }
}
