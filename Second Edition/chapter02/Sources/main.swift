let wallet = Wallet()
await wallet.increase(1)
try await wallet.deactivate(3)
