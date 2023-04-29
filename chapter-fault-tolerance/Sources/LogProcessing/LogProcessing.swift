import Distributed

@main
public struct LogProcessing {
    public private(set) var text = "Hello, World!"

    public static func main() async throws {
      try await DbStrategy1.main()
    }
}
