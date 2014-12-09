import Foundation


class ApplicationFactory {
  func createApplication(directory: String) -> Application {
    let app = Application(directory: directory);
    let app_delegate = ApplicationDelegate();

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

    app_delegate.addCommand("install", {
      return InstallCommand(
        module_manager: module_manager,
        compiler: compiler
      );
    });
    app_delegate.addCommand("list", {
      return ListCommand(
        module_manager: module_manager,
        compiler: compiler
      );
    });

    app.delegate = app_delegate;
    return app;
  }
}
