
class InstallCommand: Command {
  var module_manager: ModuleManager;

  init(module_manager: ModuleManager) {
    self.module_manager = module_manager;
  }


  override func run() {
    println("run install command");
  }
}
