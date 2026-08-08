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
        
        <nav className="flex-1 p-4 space-y-1 overflow-y-auto" id="side-nav">
          {/* Main */}
          <p className="text-xs text-on-surface-variant font-semibold uppercase tracking-wider px-4 py-2 mt-1">Main</p>
          <Link to="/admin" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl hover:bg-black/5 text-on-surface transition-colors">
            <LayoutDashboard size={18} />
            <span className="text-sm">Dashboard</span>
          </Link>
          <Link to="/admin/analytics" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-[18px]">trending_up</span>
            <span className="text-sm">Analytics</span>
          </Link>

          {/* Community */}
          <p className="text-xs text-on-surface-variant font-semibold uppercase tracking-wider px-4 py-2 mt-3">Community</p>
          <Link to="/admin/users" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-[18px]">group</span>
            <span className="text-sm">Users</span>
          </Link>
          <Link to="/admin/posts" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <FileText size={18} />
            <span className="text-sm">Posts</span>
          </Link>
          <Link to="/admin/featured-stories" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-[18px]">star</span>
            <span className="text-sm">Featured Stories</span>
          </Link>
          <Link to="/admin/categories" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-[18px]">category</span>
            <span className="text-sm">Categories</span>
          </Link>
          <Link to="/admin/challenges" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-[18px]">assignment</span>
            <span className="text-sm">Challenges</span>
          </Link>

          {/* Moderation */}
          <p className="text-xs text-on-surface-variant font-semibold uppercase tracking-wider px-4 py-2 mt-3">Moderation</p>
          <Link to="/admin/reports" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-[18px]">flag</span>
            <span className="text-sm">Content Reports</span>
          </Link>
          <Link to="/admin/bugs" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-[18px]">bug_report</span>
            <span className="text-sm">Bug Reports</span>
          </Link>

          {/* Platform */}
          <p className="text-xs text-on-surface-variant font-semibold uppercase tracking-wider px-4 py-2 mt-3">Platform</p>
          <Link to="/admin/ads" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-[18px]">campaign</span>
            <span className="text-sm">Ads Manager</span>
          </Link>
          <Link to="/admin/notifications" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-[18px]">notifications</span>
            <span className="text-sm">Push Notifications</span>
          </Link>
          <Link to="/admin/blog" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-[18px]">article</span>
            <span className="text-sm">Blog Posts</span>
          </Link>
          <Link to="/admin/settings" className="flex items-center space-x-3 px-4 py-2.5 rounded-xl text-on-surface hover:bg-black/5 transition-colors">
            <span className="material-symbols-outlined text-[18px]">settings</span>
            <span className="text-sm">App Settings</span>
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
