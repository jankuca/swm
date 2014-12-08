
class CommandResult {
  var success: Bool;

  init(success: Bool) {
    self.success = success;
  }


  func render() -> String {
    var output = "";
    if self.success {
      output += self.escape("0;32") + "ok";
    } else {
      output += self.escape("0;31") + "error";
    }
    output += self.escape("0") + "\n";
    return output;
  }


  func escape(code: String) -> String {
    return "\u{1B}[\(code)m";
  }
}
