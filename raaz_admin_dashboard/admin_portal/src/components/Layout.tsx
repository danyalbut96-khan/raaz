import { Navigate, Outlet, Link } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { supabase } from '../lib/supabase'
import { LogOut, LayoutDashboard, FileText } from 'lucide-react'

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
          <Link to="/admin" className="flex items-center space-x-3 px-4 py-3 rounded-xl hover:bg-black/5 text-on-surface transition-colors">
            <LayoutDashboard size={20} />
            <span>Dashboard</span>
          </Link>
          <Link to="/admin/analytics" className="flex items-center space-x-3 px-4 py-3 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-lg">trending_up</span>
            <span>Analytics</span>
          </Link>
          <Link to="/admin/posts" className="flex items-center space-x-3 px-4 py-3 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <FileText size={20} />
            <span>Posts</span>
          </Link>
          <Link to="/admin/featured-stories" className="flex items-center space-x-3 px-4 py-3 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-lg">star</span>
            <span>Featured Stories</span>
          </Link>
          <Link to="/admin/categories" className="flex items-center space-x-3 px-4 py-3 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-lg">category</span>
            <span>Categories</span>
          </Link>
          <Link to="/admin/challenges" className="flex items-center space-x-3 px-4 py-3 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-lg">assignment</span>
            <span>Challenges</span>
          </Link>
          <Link to="/admin/ads" className="flex items-center space-x-3 px-4 py-3 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-lg">campaign</span>
            <span>Ads Manager</span>
          </Link>
          <Link to="/admin/notifications" className="flex items-center space-x-3 px-4 py-3 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-lg">notifications</span>
            <span>Push Notifications</span>
          </Link>
          <Link to="/admin/settings" className="flex items-center space-x-3 px-4 py-3 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-lg">settings</span>
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
