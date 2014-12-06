import Foundation


class TaskResult {
  var code: Int32 = 0;
  var output = "";
  var error = "";

  init() {}
  init(task: NSTask) {
    self.code = task.terminationStatus;

    let output = task.standardOutput as NSPipe;
    let output_data = output.fileHandleForReading.readDataToEndOfFile();
    if let result = NSString(data: output_data, encoding: NSUTF8StringEncoding) {
      self.output = "\(result)";
    }

    let error = task.standardError as NSPipe;
    let error_data = error.fileHandleForReading.readDataToEndOfFile();
    if let result = NSString(data: error_data, encoding: NSUTF8StringEncoding) {
      self.error = "\(result)";
    }
  }
}
