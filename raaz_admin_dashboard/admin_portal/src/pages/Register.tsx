import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { supabase } from '../lib/supabase'

export default function Register() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)
  
  const navigate = useNavigate()

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    
    // In a real production app, this page should be protected or disabled after the first admin is created.
    // For now, it allows registering an admin account in the Supabase auth table.
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          is_admin: true
        }
      }
    })

    if (error) {
      setError(error.message)
      setLoading(false)
    } else {
      // Navigate to login after successful registration as requested
      navigate('/login', { state: { message: 'Registration successful. Please log in.' } })
    }
  }

  return (
    <div className="min-h-screen bg-surface flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 className="mt-6 text-center text-3xl font-bold tracking-tight text-on-surface">
          RAAZ Admin Registration
        </h2>
        <p className="mt-2 text-center text-sm text-on-surface-variant">
          Create your admin account
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="glass-panel py-8 px-4 shadow-lg sm:rounded-2xl sm:px-10 border border-outline-variant">
          <form className="space-y-6" onSubmit={handleRegister}>
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
                {loading ? 'Registering...' : 'Register as Admin'}
              </button>
            </div>
          </form>

          <div className="mt-6 text-center text-sm">
            <Link to="/login" className="font-medium text-primary hover:text-opacity-80">
              Already have an account? Log in
            </Link>
          </div>
        </div>
      </div>
    </div>
  )
}
