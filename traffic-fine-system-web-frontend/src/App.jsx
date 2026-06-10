import { useEffect, useState } from 'react'
import axios from 'axios'
import PaymentForm from './components/PaymentForm'
import Header from './components/Header'
import Footer from './components/Footer'

const AUTH_STORAGE_KEY = 'traffic-fine-auth-session'
const REGISTERED_ACCOUNTS_KEY = 'traffic-fine-registered-accounts'

function readStorageJson(key, fallback) {
  try {
    const value = window.localStorage.getItem(key)
    return value ? JSON.parse(value) : fallback
  } catch {
    return fallback
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

  const persistAuth = (nextUser) => {
    window.localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(nextUser))
    onAuthChange(nextUser)
  }

  const handleSignIn = async (event) => {
    event.preventDefault()

    if (!signinData.username.trim() || !signinData.password) {
      setMessage({ type: 'error', text: 'Username and password are required.' })
      return
    }

    setLoading(true)
    setMessage({ type: '', text: '' })

    try {
      const registeredAccounts = readStorageJson(REGISTERED_ACCOUNTS_KEY, [])
      const localAccount = registeredAccounts.find(
        (account) => account.username === signinData.username,
      )

      if (localAccount && localAccount.password === signinData.password) {
        persistAuth({
          username: localAccount.username,
          name: localAccount.name,
          email: localAccount.email,
          source: 'local',
        })
        setMessage({
          type: 'success',
          text: `Signed in as ${localAccount.username}.`,
        })
        return
      }

      const response = await axios.post('/api/auth/login', {
        username: signinData.username,
        password: signinData.password,
      })

      persistAuth({
        username: signinData.username,
        token: response.data.access_token,
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

  const handleSignUp = (event) => {
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

    const registeredAccounts = readStorageJson(REGISTERED_ACCOUNTS_KEY, [])
    const duplicateAccount = registeredAccounts.find(
      (account) => account.username === signupData.username,
    )

    if (duplicateAccount) {
      setMessage({ type: 'error', text: 'That username is already registered.' })
      return
    }

    const nextAccount = {
      name: signupData.name.trim(),
      username: signupData.username.trim(),
      email: signupData.email.trim(),
      password: signupData.password,
    }

    const nextAccounts = [...registeredAccounts, nextAccount]
    window.localStorage.setItem(REGISTERED_ACCOUNTS_KEY, JSON.stringify(nextAccounts))
    persistAuth({
      username: nextAccount.username,
      name: nextAccount.name,
      email: nextAccount.email,
      source: 'local',
    })
    setMessage({
      type: 'success',
      text: 'Account created and signed in. You can now unlock the payment form.',
    })
    setMode('signin')
    setSigninData({ username: nextAccount.username, password: '' })
    setSignupData({
      name: '',
      username: '',
      email: '',
      password: '',
      confirmPassword: '',
    })
  }

  if (authUser) {
    return (
      <section className="w-full card border border-secondary-medium border-opacity-20">
        <div className="rounded-xl bg-green-50 border border-green-200 px-4 py-4 text-sm text-green-800 flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <p className="font-semibold">Signed in as {authUser.username}</p>
          <button
            type="button"
            onClick={onSignOut}
            className="text-sm font-semibold text-green-900 underline underline-offset-2 w-fit"
          >
            Sign out
          </button>
        </div>
      </section>
    )
  }

  return (
    <section className="w-full card border border-secondary-medium border-opacity-20">
      <div className="flex flex-col gap-4 mb-6">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary-orange">
            Access required
          </p>
          <h2 className="text-2xl font-bold text-secondary-dark mt-2">Sign in or create an account</h2>
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
              onChange={(event) =>
                setSigninData((current) => ({ ...current, username: event.target.value }))
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
              onChange={(event) =>
                setSigninData((current) => ({ ...current, password: event.target.value }))
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
              onChange={(event) =>
                setSignupData((current) => ({ ...current, name: event.target.value }))
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
              onChange={(event) =>
                setSignupData((current) => ({ ...current, username: event.target.value }))
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
              onChange={(event) =>
                setSignupData((current) => ({ ...current, email: event.target.value }))
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
              onChange={(event) =>
                setSignupData((current) => ({ ...current, password: event.target.value }))
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
              onChange={(event) =>
                setSignupData((current) => ({ ...current, confirmPassword: event.target.value }))
              }
              className="input-field"
              placeholder="Repeat the password"
              autoComplete="new-password"
            />
          </div>
          <div className="md:col-span-2 flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
            <button type="submit" className="btn-primary md:w-auto w-full">
              Create account
            </button>
          </div>
        </form>
      )}
    </section>
  )
}

function App() {
  const [authUser, setAuthUser] = useState(null)

  useEffect(() => {
    try {
      const storedAuth = window.localStorage.getItem(AUTH_STORAGE_KEY)
      if (storedAuth) {
        setAuthUser(JSON.parse(storedAuth))
      }
    } catch {
      setAuthUser(null)
    }
  }, [])

  const handleAuthChange = (nextUser) => {
    setAuthUser(nextUser)
  }

  const handleSignOut = () => {
    window.localStorage.removeItem(AUTH_STORAGE_KEY)
    setAuthUser(null)
  }

  return (
    <div className="min-h-screen flex flex-col bg-neutral-bg">
      <Header />
      <main className="flex-grow px-4 py-8">
        <div className="mx-auto w-full max-w-6xl space-y-6">
          <AuthPanel
            authUser={authUser}
            onAuthChange={handleAuthChange}
            onSignOut={handleSignOut}
          />
          <PaymentForm isAuthenticated={Boolean(authUser)} />
        </div>
      </main>
      <Footer />
    </div>
  )
}

export default App
