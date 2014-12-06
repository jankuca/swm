
class ModuleManager {
  func readModuleInfo(dirname: String) -> JSON? {
    let filename = "\(dirname)/swiftmodule.json";
    if let data = String(contentsOfFile: filename) {
      let json = JSON.parse(data);
      return json;
    }
    return nil;
  }
}
