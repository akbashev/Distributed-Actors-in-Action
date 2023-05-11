@main
public struct ErrorKernelApp {
  public static func main() async {
    let guardian = Guardian()
    await guardian.start(texts: ["-one-", "--two--"])
    print("Press anything to terminate:")
    _ = readLine()
  }
}
