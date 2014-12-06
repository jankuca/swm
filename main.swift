import Foundation


func main() {
  let mgr = NSFileManager.defaultManager();
  let current_directory = mgr.currentDirectoryPath;

  let app_factory = ApplicationFactory();
  let app = app_factory.createApplication(current_directory);

  let args = Array(Process.arguments[1..<Process.arguments.count]);
  app.runWithArgs(args);
}


main();
