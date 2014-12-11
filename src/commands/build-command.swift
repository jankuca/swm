
class BuildCommand: Command {
  var module_manager: ModuleManager;
  var compiler: Compiler;

  init(module_manager: ModuleManager, compiler: Compiler) {
    self.module_manager = module_manager;
    self.compiler = compiler;
  }


  override func run(args: [String]) -> CommandResult {
    let result = CommandResult(success: false);

    if let info = self.module_manager.readModuleInfo(self.directory) {
      let build_success = self.buildCurrentPackage_(info);
      result.success = build_success;
    }

    return result;
  }


  func buildCurrentPackage_(info: ModuleInfo) -> Bool {
    if let source_dirname = info.directories["source"] {
      // TODO: extract path
      let build_filename = "\(self.directory)/build/app.app/Contents/app";
      self.compiler.compileApp(
        build_filename,
        dirname: source_dirname,
        cwd: self.directory
      );
    }
    return true;
  }
}
