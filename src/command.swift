import Foundation


class Command: NSObject {
  var directory: String;

  override init() {
    let mgr = NSFileManager();
    self.directory = mgr.currentDirectoryPath;
  }


  func run(args: [String]) -> CommandResult {
    println("run command");
    return CommandResult(success: true);
  }
}
