export default function Header({ adminActive = false, onAdminAccess }) {
  return (
    <header className="bg-slate-950 text-white shadow-[0_18px_60px_rgba(15,23,42,0.28)]">
      <div className="mx-auto max-w-7xl px-4 py-6 md:px-6 lg:px-8">
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Traffic Fine System</h1>
            <p className="mt-1 text-sm text-slate-300">
              Unified payment portal and admin monitoring console
            </p>
          </div>
          <button
            type="button"
            onClick={onAdminAccess}
            className={`inline-flex w-fit items-center gap-2 rounded-full border px-4 py-2 text-xs font-semibold uppercase tracking-[0.22em] transition ${
              adminActive
                ? 'border-white bg-white text-slate-950'
                : 'border-white/10 bg-white/5 text-slate-200 hover:bg-white/10 hover:text-white'
            }`}
            aria-label="Open admin portal"
          >
            <span aria-hidden="true">🔒</span>
            Admin
          </button>
        </div>
      </div>
    </header>
  )
}
