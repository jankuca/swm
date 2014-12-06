
class ApplicationFactory {
  func createApplication(directory: String) -> Application {
    let app = Application(directory: directory);
    let app_delegate = ApplicationDelegate();

    app_delegate.addCommand("install", {
      let module_manager = ModuleManager();
      return InstallCommand(module_manager: module_manager);
    });

    app.delegate = app_delegate;
    return app;
  }
}
