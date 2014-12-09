
class ListCommand: Command {
  var module_manager: ModuleManager;
  var compiler: Compiler;

  init(module_manager: ModuleManager, compiler: Compiler) {
    self.module_manager = module_manager;
    self.compiler = compiler;
  }


  override func run(args: [String]) -> ListCommandResult {
    let result = ListCommandResult(success: true);

    let declared_modules = self.listDeclaredModules_();
    let installed_modules = self.listInstalledModules_();
    let built_modules = self.listBuiltModules_();

    var installed_module_names = [String]();
    for dependency_info in installed_modules {
      if let dependency_name = dependency_info.name {
        let is_buildable = (dependency_info.directories["source"] != nil);
        let is_built = contains(built_modules, dependency_name);
        result.addDependency(dependency_name,
            needs_build: is_buildable && !is_built);
        installed_module_names.append(dependency_name);
      }
    }
    for dependency_name in declared_modules {
      if !contains(installed_module_names, dependency_name) {
        result.addDependency(dependency_name,
            needs_install: true);
      }
    }

    return result;
  }


  func listDeclaredModules_() -> [String] {
    if let info = self.module_manager.readModuleInfo(self.directory) {
      return Array(info.dependencies.keys);
    }
    return [String]();
  }


  func listInstalledModules_() -> [ModuleInfo] {
    let dependencies = self.module_manager.getInstalledDependencies(
        self.directory);
    return Array(dependencies.values);
  }


  func listBuiltModules_() -> [String] {
    let modules = self.compiler.getBuiltModules(self.directory);
    return modules;
  }
}
