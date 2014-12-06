import Foundation


class TaskDispatcher {
  init() {}

  func exec(bin: String, args: [String] = [String](), cwd: String? = nil)
      -> TaskResult {
    let task = self.create(bin, args: args, cwd: cwd);

    let output_pipe = NSPipe();
    let error_pipe = NSPipe();
    task.standardOutput = output_pipe;
    task.standardError = error_pipe;

    task.launch();
    task.waitUntilExit();

    return TaskResult(task: task);
  }


  func create(bin: String, args: [String] = [String](), cwd: String? = nil)
      -> NSTask {
    let task = NSTask();

    if let cwd = cwd {
      task.currentDirectoryPath = cwd;
    }
    if bin.hasPrefix("/") {
      task.launchPath = bin;
    } else {
      task.launchPath = "/usr/bin/\(bin)";
    }
    task.arguments = args;

    return task;
  }
}
