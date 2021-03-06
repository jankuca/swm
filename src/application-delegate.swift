
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
      let cmd_args = Array(app.args[1..<app.args.count]);
      let result: CommandResult = command.run(cmd_args);
      print(result.render());
    } else {
      println("no such command: " + command_key);
    }
  }


  func addCommand(command_key: String, factory: ()->Command) {
    self.commands_[command_key] = factory;
  }
}
