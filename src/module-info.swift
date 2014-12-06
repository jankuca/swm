
class ModuleInfo {
  var directory: String?;

  var name: String?;
  var version: String?;

  var dependencies = [String:DependencyRef]();
  var directories = [String:String]();

  init() {}


  func addDependency(name: String, path: String) -> DependencyRef {
    let path_parts = path.componentsSeparatedByString(" ");

    let ref = DependencyRef(path_parts[0]);
    if path_parts.count > 1 {
      let attrs = self.parseAttributes_(path_parts);
      ref.attrs = attrs;
    }

    self.dependencies[name] = ref;
    return ref;
  }


  func parseAttributes_(attr_list: [String]) -> [String:String] {
    var attrs = [String:String]();
    for attr in attr_list {
      if let key_range = attr.rangeOfString("^@(\\w+):",
          options: .RegularExpressionSearch) {
        let key = attr.substringWithRange(Range(
          start: advance(key_range.startIndex, 1),
          end: advance(key_range.endIndex, -1)
        ));
        attrs[key] = attr.substringFromIndex(key_range.endIndex);
      }
    }
    return attrs;
  }
}
