
class ModuleManager {
  func readModuleInfo(filename: String) -> JSON? {
    if let data = String(contentsOfFile: filename) {
      let json = JSON.parse(data);
      return json;
    }
    return nil;
  }
}
