import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

type EventLog = {
  id: string
  event_name: string
  created_at: string
  user_id: string | null
}

export default function AnalyticsDashboard() {
  const [stats, setStats] = useState({
    activeUsers: 0,
    newSignups: 0,
    totalErrors: 0,
    totalEvents: 0
  })
  
  const [eventLogs, setEventLogs] = useState<EventLog[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchAnalytics()

    const channel = supabase
      .channel('analytics_changes')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'event_logs' }, fetchAnalytics)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'bug_reports' }, fetchAnalytics)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'profiles' }, fetchAnalytics)
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  async function fetchAnalytics() {
    // We don't block the UI with loading after the first load
    
    // 1. New Signups (Today)
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const { count: signupsCount } = await supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true })
      .gte('member_since', today.toISOString())
      
    // 2. Active Users (Active in last 1 hour)
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000)
    const { count: activeCount } = await supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true })
      .gte('updated_at', oneHourAgo.toISOString())

    // 3. Total Errors
    const { count: errorsCount } = await supabase
      .from('bug_reports')
      .select('*', { count: 'exact', head: true })
      
    // 4. Total Events & Recent Event Logs
    const { count: eventsCount } = await supabase
      .from('event_logs')
      .select('*', { count: 'exact', head: true })
      
    const { data: logsData } = await supabase
      .from('event_logs')
      .select('id, event_name, created_at, user_id')
      .order('created_at', { ascending: false })
      .limit(50)

    setStats({
      activeUsers: activeCount || 0,
      newSignups: signupsCount || 0,
      totalErrors: errorsCount || 0,
      totalEvents: eventsCount || 0
    })
    
    if (logsData) {
      setEventLogs(logsData as EventLog[])
    }
    setLoading(false)
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Live Analytics</h2>
          <p className="text-on-surface-variant mt-1">Real-time application telemetry and usage data.</p>
        </div>
        <div className="flex items-center gap-2 bg-green-500/10 text-green-600 px-4 py-2 rounded-full font-medium text-sm border border-green-500/20 shadow-sm animate-pulse">
          <div className="w-2 h-2 rounded-full bg-green-500" /> Live Updates Active
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard title="Active Users (1hr)" value={stats.activeUsers.toLocaleString()} icon="groups" color="text-blue-500" />
        <StatCard title="New Signups Today" value={stats.newSignups.toLocaleString()} icon="person_add" color="text-green-500" />
        <StatCard title="Total Errors (All Time)" value={stats.totalErrors.toLocaleString()} icon="bug_report" color="text-red-500" />
        <StatCard title="Total Events (All Time)" value={stats.totalEvents.toLocaleString()} icon="bolt" color="text-amber-500" />
      </div>

      <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm mt-8">
        <h3 className="text-xl font-bold text-on-surface mb-6 flex items-center">
          <span className="material-symbols-outlined mr-2">receipt_long</span>
          Live Event Log
        </h3>
        
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-black/[0.03] border-b border-outline-variant/30 text-on-surface-variant text-sm">
                <th className="p-4 font-semibold">Time</th>
                <th className="p-4 font-semibold">Event Name</th>
                <th className="p-4 font-semibold">User ID</th>
              </tr>
            </thead>
            <tbody>
              {loading && eventLogs.length === 0 ? (
                <tr><td colSpan={3} className="p-10 text-center text-on-surface-variant">Listening for events...</td></tr>
              ) : eventLogs.length === 0 ? (
                <tr><td colSpan={3} className="p-10 text-center text-on-surface-variant">No events logged yet.</td></tr>
              ) : eventLogs.map(log => (
                <tr key={log.id} className="border-b border-outline-variant/20 hover:bg-black/[0.02] transition-colors font-mono text-sm">
                  <td className="p-4 text-on-surface-variant">
                    {new Date(log.created_at).toLocaleTimeString()}
                  </td>
                  <td className="p-4">
                    <span className="bg-primary/10 text-primary px-2 py-1 rounded font-semibold">{log.event_name}</span>
                  </td>
                  <td className="p-4 text-on-surface-variant">
                    {log.user_id ? log.user_id.substring(0, 12) + '...' : 'Anonymous'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

function StatCard({ title, value, icon, color }: { title: string, value: string | number, icon: string, color: string }) {
  return (
    <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm flex items-center justify-between transition-transform hover:-translate-y-1">
      <div>
        <p className="text-sm font-semibold text-on-surface-variant uppercase tracking-wider mb-2">{title}</p>
        <p className={`text-4xl font-bold ${color}`}>{value}</p>
      </div>
      <div className={`w-12 h-12 rounded-full bg-black/5 flex items-center justify-center ${color}`}>
        <span className="material-symbols-outlined text-3xl">{icon}</span>
      </div>
    </div>
  )
}
