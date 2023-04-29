import Distributed

@main
public struct LogProcessing {
    public private(set) var text = "Hello, World!"

    public static func main() throws {
      try DbStrategy1.main()
    }
}
