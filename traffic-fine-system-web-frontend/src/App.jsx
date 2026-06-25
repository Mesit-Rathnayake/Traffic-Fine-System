import { useEffect, useState } from 'react'
import PaymentForm from './components/PaymentForm'
import Header from './components/Header'
import Footer from './components/Footer'
import AdminDashboard from './components/AdminDashboard'
import { loginUser, registerUser } from './services/trafficFineApi'

const AUTH_STORAGE_KEY = 'traffic-fine-auth-session'

function decodeJwtPayload(token) {
  if (!token || typeof token !== 'string' || token.split('.').length < 2) {
    return null
  }

  try {
    const payload = token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')
    const paddedPayload = payload.padEnd(payload.length + ((4 - (payload.length % 4)) % 4), '=')
    return JSON.parse(window.atob(paddedPayload))
  } catch {
    return null
  }
}

function hydrateAuthSession(session) {
  if (!session) {
    return null
  }

  const tokenPayload = decodeJwtPayload(session.token)

  return {
    ...session,
    role: session.role || tokenPayload?.role || 'DRIVER',
    username: session.username || tokenPayload?.username || '',
  }
}

function AuthPanel({ authUser, onAuthChange, onSignOut }) {
  const [mode, setMode] = useState('signin')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState({ type: '', text: '' })
  const [signinData, setSigninData] = useState({ username: '', password: '' })
  const [signupData, setSignupData] = useState({
    name: '',
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
  })

  const persistAuth = nextUser => {
    const hydratedUser = hydrateAuthSession(nextUser)
    window.localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(hydratedUser))
    onAuthChange(hydratedUser)
  }

  const handleSignIn = async event => {
    event.preventDefault()

    if (!signinData.username.trim() || !signinData.password) {
      setMessage({ type: 'error', text: 'Username and password are required.' })
      return
    }

    setLoading(true)
    setMessage({ type: '', text: '' })

    try {
      const response = await loginUser({
        username: signinData.username,
        password: signinData.password,
      })

      persistAuth({
        username: signinData.username,
        token: response.access_token,
        role: decodeJwtPayload(response.access_token)?.role || 'DRIVER',
        source: 'backend',
      })
      setMessage({
        type: 'success',
        text: `Signed in as ${signinData.username}.`,
      })
    } catch (error) {
      setMessage({
        type: 'error',
        text: error.response?.data?.message || 'Sign in failed. Check your credentials.',
      })
    } finally {
      setLoading(false)
    }
  }

  const handleSignUp = async event => {
    event.preventDefault()

    if (
      !signupData.name.trim() ||
      !signupData.username.trim() ||
      !signupData.email.trim() ||
      !signupData.password ||
      !signupData.confirmPassword
    ) {
      setMessage({ type: 'error', text: 'Complete every sign up field first.' })
      return
    }

    if (!signupData.email.includes('@')) {
      setMessage({ type: 'error', text: 'Enter a valid email address.' })
      return
    }

    if (signupData.password.length < 6) {
      setMessage({ type: 'error', text: 'Password must be at least 6 characters.' })
      return
    }

    if (signupData.password !== signupData.confirmPassword) {
      setMessage({ type: 'error', text: 'Passwords do not match.' })
      return
    }

    const payload = {
      name: signupData.name.trim(),
      username: signupData.username.trim(),
      email: signupData.email.trim(),
      password: signupData.password,
    }

    setLoading(true)
    setMessage({ type: '', text: '' })

    try {
      await registerUser(payload)
      const loginResponse = await loginUser({
        username: payload.username,
        password: payload.password,
      })

      persistAuth({
        username: payload.username,
        name: payload.name,
        email: payload.email,
        token: loginResponse.access_token,
        role: decodeJwtPayload(loginResponse.access_token)?.role || 'DRIVER',
        source: 'backend',
      })
      setMessage({
        type: 'success',
        text: 'Account created and signed in successfully.',
      })
      setMode('signin')
      setSigninData({ username: payload.username, password: '' })
      setSignupData({
        name: '',
        username: '',
        email: '',
        password: '',
        confirmPassword: '',
      })
    } catch (error) {
      setMessage({
        type: 'error',
        text: error.response?.data?.message || 'Sign up failed. Please try again.',
      })
    } finally {
      setLoading(false)
    }
  }

  if (authUser) {
    return (
      <section className="w-full rounded-[2rem] border border-emerald-200 bg-emerald-50/80 p-5 shadow-sm">
        <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.25em] text-emerald-700">
              Active session
            </p>
            <p className="mt-2 font-semibold text-emerald-950">Signed in as {authUser.username}</p>
            <p className="mt-1 text-sm text-emerald-900/80">Role: {authUser.role || 'DRIVER'}</p>
          </div>
          <button
            type="button"
            onClick={onSignOut}
            className="w-fit rounded-full border border-emerald-300 bg-white px-4 py-2 text-sm font-semibold text-emerald-900 transition hover:bg-emerald-100"
          >
            Sign out
          </button>
        </div>
      </section>
    )
  }

  return (
    <section className="w-full rounded-[2rem] border border-slate-200 bg-white p-6 shadow-sm md:p-8">
      <div className="flex flex-col gap-4 mb-6">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary-orange">
            Driver access
          </p>
          <h2 className="text-2xl font-bold text-secondary-dark mt-2">
            Sign in or create an account
          </h2>
        </div>
      </div>

      {message.text ? (
        <div
          className={`mb-5 p-4 rounded-lg border ${
            message.type === 'success'
              ? 'bg-green-100 text-green-800 border-green-300'
              : 'bg-red-100 text-red-800 border-red-300'
          }`}
        >
          {message.text}
        </div>
      ) : null}

      <div className="flex gap-3 mb-6">
        <button
          type="button"
          onClick={() => setMode('signin')}
          className={`px-4 py-2 rounded-full text-sm font-semibold transition ${
            mode === 'signin'
              ? 'bg-secondary-dark text-white'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          Sign In
        </button>
        <button
          type="button"
          onClick={() => setMode('signup')}
          className={`px-4 py-2 rounded-full text-sm font-semibold transition ${
            mode === 'signup'
              ? 'bg-secondary-dark text-white'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          Sign Up
        </button>
      </div>

      {mode === 'signin' ? (
        <form onSubmit={handleSignIn} className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Username</label>
            <input
              type="text"
              value={signinData.username}
              onChange={event =>
                setSigninData(current => ({ ...current, username: event.target.value }))
              }
              className="input-field"
              placeholder="Enter username"
              autoComplete="username"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Password</label>
            <input
              type="password"
              value={signinData.password}
              onChange={event =>
                setSigninData(current => ({ ...current, password: event.target.value }))
              }
              className="input-field"
              placeholder="Enter password"
              autoComplete="current-password"
            />
          </div>
          <div className="md:col-span-2 flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
            <button type="submit" className="btn-primary md:w-auto w-full" disabled={loading}>
              {loading ? 'Signing in...' : 'Sign In'}
            </button>
          </div>
        </form>
      ) : (
        <form onSubmit={handleSignUp} className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Full name</label>
            <input
              type="text"
              value={signupData.name}
              onChange={event =>
                setSignupData(current => ({ ...current, name: event.target.value }))
              }
              className="input-field"
              placeholder="Enter your full name"
              autoComplete="name"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Username</label>
            <input
              type="text"
              value={signupData.username}
              onChange={event =>
                setSignupData(current => ({ ...current, username: event.target.value }))
              }
              className="input-field"
              placeholder="Choose a username"
              autoComplete="username"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
            <input
              type="email"
              value={signupData.email}
              onChange={event =>
                setSignupData(current => ({ ...current, email: event.target.value }))
              }
              className="input-field"
              placeholder="Enter your email"
              autoComplete="email"
            />
          </div>
          <div />
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Password</label>
            <input
              type="password"
              value={signupData.password}
              onChange={event =>
                setSignupData(current => ({ ...current, password: event.target.value }))
              }
              className="input-field"
              placeholder="Create a password"
              autoComplete="new-password"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Confirm password</label>
            <input
              type="password"
              value={signupData.confirmPassword}
              onChange={event =>
                setSignupData(current => ({ ...current, confirmPassword: event.target.value }))
              }
              className="input-field"
              placeholder="Repeat the password"
              autoComplete="new-password"
            />
          </div>
          <div className="md:col-span-2 flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
            <button type="submit" className="btn-primary md:w-auto w-full" disabled={loading}>
              {loading ? 'Creating account...' : 'Create account'}
            </button>
          </div>
        </form>
      )}
    </section>
  )
}

function AdminAccessPanel({ authUser, onAuthChange, onBackToPayments }) {
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState({ type: '', text: '' })
  const [credentials, setCredentials] = useState({ username: '', password: '' })

  const persistAuth = nextUser => {
    const hydratedUser = hydrateAuthSession(nextUser)
    window.localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(hydratedUser))
    onAuthChange(hydratedUser)
  }

  const handleAdminSignIn = async event => {
    event.preventDefault()

    if (!credentials.username.trim() || !credentials.password) {
      setMessage({ type: 'error', text: 'Admin username and password are required.' })
      return
    }

    setLoading(true)
    setMessage({ type: '', text: '' })

    try {
      const response = await loginUser({
        username: credentials.username,
        password: credentials.password,
      })

      const tokenPayload = decodeJwtPayload(response.access_token)

      if (tokenPayload?.role !== 'ADMIN') {
        setMessage({
          type: 'error',
          text: 'This access panel only accepts ADMIN accounts.',
        })
        return
      }

      persistAuth({
        username: credentials.username,
        token: response.access_token,
        role: tokenPayload.role,
        source: 'backend-admin',
      })
      setMessage({
        type: 'success',
        text: 'Admin access granted.',
      })
    } catch (error) {
      setMessage({
        type: 'error',
        text: error.response?.data?.message || 'Admin sign in failed. Check your credentials.',
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <section className="w-full rounded-[2rem] border border-slate-200 bg-white p-6 shadow-sm md:p-8">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">
            Admin access
          </p>
          <h2 className="mt-2 text-2xl font-bold text-slate-900">Locked admin portal</h2>
          <p className="mt-2 text-sm leading-6 text-slate-600">
            This area is separate from driver sign-up. Admin accounts are provisioned by the backend
            and should only be used for monitoring and operations.
          </p>
        </div>
        <button
          type="button"
          onClick={onBackToPayments}
          className="rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm font-semibold text-slate-700 transition hover:bg-slate-100"
        >
          Back
        </button>
      </div>

      {message.text ? (
        <div
          className={`mt-5 p-4 rounded-lg border ${
            message.type === 'success'
              ? 'bg-green-100 text-green-800 border-green-300'
              : 'bg-red-100 text-red-800 border-red-300'
          }`}
        >
          {message.text}
        </div>
      ) : null}

      <form onSubmit={handleAdminSignIn} className="mt-6 grid grid-cols-1 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Admin username</label>
          <input
            type="text"
            value={credentials.username}
            onChange={event =>
              setCredentials(current => ({ ...current, username: event.target.value }))
            }
            className="input-field"
            placeholder="Enter admin username"
            autoComplete="username"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Password</label>
          <input
            type="password"
            value={credentials.password}
            onChange={event =>
              setCredentials(current => ({ ...current, password: event.target.value }))
            }
            className="input-field"
            placeholder="Enter admin password"
            autoComplete="current-password"
          />
        </div>
        <button type="submit" className="btn-primary w-full" disabled={loading}>
          {loading ? 'Opening admin portal...' : 'Open admin portal'}
        </button>
        <p className="text-xs leading-5 text-slate-500">
          If you need a new admin account, create it in the backend or seed it directly in the
          database.
        </p>
      </form>

      {authUser?.role === 'ADMIN' ? (
        <div className="mt-6 rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-900">
          You are already signed in as an ADMIN user. Use the header lock icon or go back to open
          the dashboard.
        </div>
      ) : null}
    </section>
  )
}

function App() {
  const [authUser, setAuthUser] = useState(null)
  const [activePortal, setActivePortal] = useState('payment')

  useEffect(() => {
    try {
      const storedAuth = window.localStorage.getItem(AUTH_STORAGE_KEY)
      if (storedAuth) {
        const parsedAuth = hydrateAuthSession(JSON.parse(storedAuth))
        setAuthUser(parsedAuth)
        if (parsedAuth?.role === 'ADMIN') {
          setActivePortal('admin')
        }
      }
    } catch {
      setAuthUser(null)
    }
  }, [])

  const isAdmin = authUser?.role === 'ADMIN'
  const canAccessAdmin = !authUser || isAdmin

  const handleAuthChange = nextUser => {
    setAuthUser(nextUser)
    if (nextUser?.role === 'ADMIN') {
      setActivePortal('admin')
    }
  }

  const handleSignOut = () => {
    window.localStorage.removeItem(AUTH_STORAGE_KEY)
    setAuthUser(null)
    setActivePortal('payment')
  }

  const handleAdminAccess = () => {
    if (!canAccessAdmin) {
      return
    }

    setActivePortal(current => (current === 'admin' ? 'payment' : 'admin'))
  }

  return (
    <div className="min-h-screen flex flex-col bg-neutral-bg app-shell">
      <Header adminActive={activePortal === 'admin'} onAdminAccess={handleAdminAccess} disabled={!canAccessAdmin} />
      <main className="flex-grow px-4 py-8 md:px-6 lg:px-8">
        <div className="mx-auto w-full max-w-7xl space-y-6">
          <section className="overflow-hidden rounded-[2rem] border border-slate-200 bg-[radial-gradient(circle_at_top_left,_rgba(255,183,107,0.24),_transparent_30%),linear-gradient(135deg,rgba(11,79,108,0.06),rgba(27,133,184,0.08))] p-6 shadow-[0_24px_70px_rgba(15,23,42,0.08)] md:p-8">
            <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
              <div className="max-w-3xl space-y-4">
                <p className="text-xs font-semibold uppercase tracking-[0.28em] text-primary-orange">
                  Unified traffic fine portal
                </p>
                <h2 className="text-3xl font-bold leading-tight text-slate-900 md:text-5xl">
                  Driver payments first.
                </h2>
                <p className="max-w-2xl text-sm leading-6 text-slate-600 md:text-base">
                  Use the public sign-in and sign-up flow for drivers.
                </p>
              </div>

              <div className="grid gap-3 sm:grid-cols-2 lg:min-w-[24rem] lg:grid-cols-2">
                <div className="rounded-2xl border border-white/60 bg-white/80 p-4 shadow-sm">
                  <p className="text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">
                    Role
                  </p>
                  <p className="mt-2 text-lg font-semibold text-slate-900">
                    {authUser?.role || 'Guest'}
                  </p>
                </div>
                <div className="rounded-2xl border border-white/60 bg-white/80 p-4 shadow-sm">
                  <p className="text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">
                    Portal
                  </p>
                  <p className="mt-2 text-lg font-semibold text-slate-900">
                    {activePortal === 'admin' ? 'Admin portal' : 'Payment portal'}
                  </p>
                </div>
              </div>
            </div>
          </section>

          <div className="grid grid-cols-1 gap-6 xl:grid-cols-[1fr_1.05fr]">
            {/* Left Column */}
            <div className="space-y-6">
              <AuthPanel
                authUser={authUser}
                onAuthChange={handleAuthChange}
                onSignOut={handleSignOut}
              />
            </div>

            {/* Right Column */}
            <div className="space-y-6">
              {activePortal === 'payment' ? (
                <PaymentForm isAuthenticated={Boolean(authUser)} />
              ) : null}

              {activePortal === 'admin' ? (
                isAdmin ? (
                  <AdminDashboard authUser={authUser} />
                ) : (
                  <AdminAccessPanel
                    authUser={authUser}
                    onAuthChange={handleAuthChange}
                    onBackToPayments={() => setActivePortal('payment')}
                  />
                )
              ) : null}
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  )
}

export default App
