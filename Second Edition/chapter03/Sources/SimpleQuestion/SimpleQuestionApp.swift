@main
public struct ErrorKernelApp {
  public static func main() async {
    let guardian = Guardian()
    await guardian.start(texts: ["text-a", "text-b", "text-c"])
    print("Press anything to terminate:")
    _ = readLine()
  }
}
