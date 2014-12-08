import Foundation


class Command: NSObject {
  var directory: String;

  override init() {
    let mgr = NSFileManager();
    self.directory = mgr.currentDirectoryPath;
  }


  func run() -> CommandResult {
    println("run command");
    return CommandResult(success: true);
  }
}
