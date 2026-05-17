export default function Header() {
  return (
    <header className="bg-secondary-dark text-white shadow-lg">
      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">🚔 Traffic Fine System</h1>
            <p className="text-secondary-medium text-opacity-90 text-sm mt-1">
              Sri Lanka Police Department - Online Payment Portal
            </p>
          </div>
          <div className="text-right">
            <p className="text-sm text-gray-300">Secure Payment Gateway</p>
            <p className="text-xs text-gray-400 mt-1">🔒 SSL Encrypted</p>
          </div>
        </div>
      </div>
    </header>
  )
}
