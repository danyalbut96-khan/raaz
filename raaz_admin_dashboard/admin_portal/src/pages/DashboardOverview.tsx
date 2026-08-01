import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function DashboardOverview() {
  const [stats, setStats] = useState({
    users: 0,
    posts: 0,
    reports: 0
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchStats() {
      setLoading(true)
      
      try {
        // We might not have direct permissions to count auth.users from client 
        // without an edge function, but we can query public profiles if they exist,
        // or just set a placeholder for now if auth.users is blocked by RLS.
        // Let's attempt to count from public tables.
        
        // Count posts
        const { count: postsCount } = await supabase
          .from('posts')
          .select('*', { count: 'exact', head: true })
          
        // Count pending reports
        const { count: reportsCount } = await supabase
          .from('reported_posts')
          .select('*', { count: 'exact', head: true })
          .eq('status', 'pending')

        setStats({
          users: 0, // Placeholder until users table or RPC is available
          posts: postsCount || 0,
          reports: reportsCount || 0
        })
      } catch (err) {
        console.error('Error fetching stats:', err)
      }
      
      setLoading(false)
    }

    fetchStats()
  }, [])

  return (
    <div>
      <h2 className="text-3xl font-bold text-on-surface mb-2">Dashboard Overview</h2>
      <p className="text-on-surface-variant mb-8">Welcome back, Admin. Here is what is happening today.</p>
      
      {loading ? (
        <div className="text-on-surface-variant">Loading statistics...</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm hover:shadow-md transition-shadow">
            <p className="text-on-surface-variant font-medium flex items-center">
              <span className="material-symbols-outlined mr-2">group</span>
              Total Users
            </p>
            <p className="text-4xl font-bold text-primary mt-4">{stats.users} <span className="text-sm font-normal text-on-surface-variant">(Requires RPC)</span></p>
          </div>
          <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm hover:shadow-md transition-shadow">
            <p className="text-on-surface-variant font-medium flex items-center">
              <span className="material-symbols-outlined mr-2">dynamic_feed</span>
              Total Posts
            </p>
            <p className="text-4xl font-bold text-primary mt-4">{stats.posts}</p>
          </div>
          <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm hover:shadow-md transition-shadow">
            <p className="text-on-surface-variant font-medium flex items-center text-red-500">
              <span className="material-symbols-outlined mr-2">flag</span>
              Pending Reports
            </p>
            <p className="text-4xl font-bold text-red-500 mt-4">{stats.reports}</p>
          </div>
        </div>
      )}
    </div>
  )
}
