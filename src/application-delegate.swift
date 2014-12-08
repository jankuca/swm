
class ApplicationDelegate {
  var commands_ = Dictionary<String, ()->Command>();


  func run(app: Application) {
    if app.args.isEmpty {
      println("no command specified");
      return;
    }

    let command_key = app.args[0];
    if let factory = self.commands_[command_key] {
      let command = factory();
      if let directory = app.directory {
        command.directory = directory;
      }
      command.run();
    } else {
      println("no such command: " + command_key);
    }
  }


  func addCommand(command_key: String, factory: ()->Command) {
    self.commands_[command_key] = factory;
  }
}
