import Foundation


class Command: NSObject {
  var directory: String;

  override init() {
    let mgr = NSFileManager();
    self.directory = mgr.currentDirectoryPath;
  }


  func run() {
    println("run command");
  }

  func runInDirectory(directory: String) {
    self.directory = directory;
    return self.run();
  }
}
