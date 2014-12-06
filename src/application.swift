
class Application {
  var delegate: ApplicationDelegate?;
  var directory: String?;
  var args = [String]();

  init() {}
  init(directory: String) {
    self.directory = directory;
  }


  func run() {
    if let delegate = self.delegate {
      delegate.run(self);
    }
  }


  func runWithArgs(args: [String]) {
    self.args = args;
    self.run();
  }
}
