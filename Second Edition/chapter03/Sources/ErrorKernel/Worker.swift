actor Worker {
  func parse(text: String) -> String {
    let parsed = text.naiveParsing()
    print("\(self) DONE! Parsed result: \(parsed)")
    return parsed
  }
}

private extension String {
  func naiveParsing() -> String {
    self.replacing("-", with: "")
  }
}
