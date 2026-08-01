import { Navigate, Outlet, Link } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { supabase } from '../lib/supabase'
import { LogOut, LayoutDashboard, Settings, Users, FileText } from 'lucide-react'

export default function Layout() {
  const { user } = useAuth()

  if (!user) {
    return <Navigate to="/login" replace />
  }

  const handleLogout = async () => {
    await supabase.auth.signOut()
  }

  return (
    <div className="min-h-screen bg-surface flex">
      {/* Sidebar */}
      <aside className="w-64 glass-panel border-r border-outline-variant flex flex-col h-screen fixed">
        <div className="p-6 border-b border-outline-variant">
          <h1 className="text-2xl font-bold text-primary font-sans">RAAZ Admin</h1>
          <p className="text-xs text-on-surface-variant mt-1">{user.email}</p>
        </div>
        
        <nav className="flex-1 p-4 space-y-2 overflow-y-auto" id="side-nav">
          <Link to="/" className="flex items-center space-x-3 px-4 py-3 rounded-xl bg-primary/10 text-primary font-medium">
            <LayoutDashboard size={20} />
            <span>Dashboard</span>
          </Link>
          <Link to="/" className="flex items-center space-x-3 px-4 py-3 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <FileText size={20} />
            <span>Posts</span>
          </Link>
          <Link to="/" className="flex items-center space-x-3 px-4 py-3 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <Users size={20} />
            <span>Users</span>
          </Link>
          <Link to="/" className="flex items-center space-x-3 px-4 py-3 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <Settings size={20} />
            <span>Settings</span>
          </Link>
        </nav>

        <div className="p-4 border-t border-outline-variant">
          <button 
            onClick={handleLogout}
            className="flex items-center space-x-3 w-full px-4 py-3 rounded-xl text-red-500 hover:bg-red-50 transition-colors"
          >
            <LogOut size={20} />
            <span>Sign Out</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="flex-1 ml-64 p-8">
        <div className="max-w-7xl mx-auto">
          <Outlet />
        </div>
      </main>
    </div>
  )
}
