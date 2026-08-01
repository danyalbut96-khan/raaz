import { useState, useEffect } from 'react'
import { useNavigate, Link, useLocation } from 'react-router-dom'
import { supabase } from '../lib/supabase'

export default function Login() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState<string | null>(null)
  
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => {
    // Check if there's a success message from the register page
    if (location.state?.message) {
      setMessage(location.state.message)
      // Clean up the state so it doesn't persist on refresh
      window.history.replaceState({}, document.title)
    }
  }, [location])

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    setMessage(null)

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      setError(error.message)
      setLoading(false)
    } else {
      navigate('/')
    }
  }

  return (
    <div className="min-h-screen bg-surface flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 className="mt-6 text-center text-3xl font-bold tracking-tight text-on-surface">
          RAAZ Admin Login
        </h2>
        <p className="mt-2 text-center text-sm text-on-surface-variant">
          Sign in to access the control panel
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="glass-panel py-8 px-4 shadow-lg sm:rounded-2xl sm:px-10 border border-outline-variant">
          <form className="space-y-6" onSubmit={handleLogin}>
            {message && (
              <div className="bg-green-50 text-green-600 p-3 rounded-xl text-sm border border-green-100">
                {message}
              </div>
            )}
            
            {error && (
              <div className="bg-red-50 text-red-500 p-3 rounded-xl text-sm border border-red-100">
                {error}
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-on-surface">Email address</label>
              <div className="mt-1">
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="block w-full appearance-none rounded-xl border border-outline px-3 py-2 placeholder-outline-variant shadow-sm focus:border-primary focus:outline-none focus:ring-primary sm:text-sm bg-surface"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-on-surface">Password</label>
              <div className="mt-1">
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="block w-full appearance-none rounded-xl border border-outline px-3 py-2 placeholder-outline-variant shadow-sm focus:border-primary focus:outline-none focus:ring-primary sm:text-sm bg-surface"
                />
              </div>
            </div>

            <div>
              <button
                type="submit"
                disabled={loading}
                className="flex w-full justify-center rounded-xl bg-primary px-4 py-2 text-sm font-medium text-white shadow-sm hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 disabled:opacity-50"
              >
                {loading ? 'Signing in...' : 'Sign in'}
              </button>
            </div>
          </form>

          <div className="mt-6 text-center text-sm">
            <Link to="/admin/registration" className="font-medium text-primary hover:text-opacity-80">
              First time? Register admin account
            </Link>
          </div>
        </div>
      </div>
    </div>
  )
}
