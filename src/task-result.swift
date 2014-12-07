import Foundation


class TaskResult {
  var code: Int32 = 0;
  var output = "";
  var error = "";

  init() {}
  init(task: NSTask) {
    self.code = task.terminationStatus;

    let output = task.standardOutput as NSPipe;
    let out_data = output.fileHandleForReading.readDataToEndOfFile();
    if let result = NSString(data: out_data, encoding: NSUTF8StringEncoding) {
      if result.length > 0 {
        self.output = result.substringToIndex(result.length - 1);
      }
    }

    let error = task.standardError as NSPipe;
    let err_data = error.fileHandleForReading.readDataToEndOfFile();
    if let result = NSString(data: err_data, encoding: NSUTF8StringEncoding) {
      if result.length > 0 {
        self.error = result.substringToIndex(result.length - 1);
      }
    }
  }
}
