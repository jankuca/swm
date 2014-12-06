import Foundation


class ApplicationFactory {
  func createApplication(directory: String) -> Application {
    let app = Application(directory: directory);
    let app_delegate = ApplicationDelegate();

    app_delegate.addCommand("install", {
      let file_manager = NSFileManager.defaultManager();
      let tasks = TaskDispatcher();

      let compiler = Compiler(
        file_manager: file_manager,
        tasks: tasks
      );
      let module_manager = ModuleManager(
        file_manager: file_manager,
        tasks: tasks
      );

      return InstallCommand(
        module_manager: module_manager,
        compiler: compiler
      );
    });

    app.delegate = app_delegate;
    return app;
  }
}
