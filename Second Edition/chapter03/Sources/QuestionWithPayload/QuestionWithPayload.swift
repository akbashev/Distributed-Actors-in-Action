@main
public struct ErrorKernelApp {
  public static func main() async {
    let guardian = Guardian()
    await guardian.start()
    print("Press anything to terminate:")
    _ = readLine()
  }
}
