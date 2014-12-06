
class DependencyRef {
  var url: String;
  var revision: String?;
  var attrs = [String:String]();

  init(_ rev_url: String) {
    if let revision_range = rev_url.rangeOfString("#.+$",
        options: .RegularExpressionSearch) {
      self.url = rev_url.substringToIndex(revision_range.startIndex);
      self.revision = rev_url.substringFromIndex(
          advance(revision_range.startIndex, 1));
    } else {
      self.url = rev_url;
    }

    if !self.url.hasPrefix("git://") {
      self.url = "git://github.com/\(self.url).git";
    }
  }
}
