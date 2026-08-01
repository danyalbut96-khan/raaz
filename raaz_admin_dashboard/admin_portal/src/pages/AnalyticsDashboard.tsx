import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function AnalyticsDashboard() {
  const [events, setEvents] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchAnalytics() {
      setLoading(true)
      const { data, error } = await supabase
        .from('analytics_events')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(100)
      
      if (!error && data) {
        setEvents(data)
      }
      setLoading(false)
    }

    fetchAnalytics()
  }, [])

  return (
    <div>
      <div className="mb-8">
        <h2 className="text-3xl font-bold text-on-surface">Analytics Dashboard</h2>
        <p className="text-on-surface-variant mt-2">Monitor real-time application usage and user events.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm flex flex-col items-center justify-center">
          <span className="material-symbols-outlined text-4xl text-primary mb-2">trending_up</span>
          <p className="text-3xl font-bold text-on-surface">{events.length}</p>
          <p className="text-sm text-on-surface-variant uppercase tracking-widest mt-1">Total Events (24h)</p>
        </div>
        <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm flex flex-col items-center justify-center">
          <span className="material-symbols-outlined text-4xl text-secondary mb-2">person_add</span>
          <p className="text-3xl font-bold text-on-surface">42</p>
          <p className="text-sm text-on-surface-variant uppercase tracking-widest mt-1">New Signups</p>
        </div>
        <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm flex flex-col items-center justify-center">
          <span className="material-symbols-outlined text-4xl text-tertiary mb-2">visibility</span>
          <p className="text-3xl font-bold text-on-surface">1,024</p>
          <p className="text-sm text-on-surface-variant uppercase tracking-widest mt-1">Page Views</p>
        </div>
        <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm flex flex-col items-center justify-center">
          <span className="material-symbols-outlined text-4xl text-error mb-2">warning</span>
          <p className="text-3xl font-bold text-on-surface">3</p>
          <p className="text-sm text-on-surface-variant uppercase tracking-widest mt-1">Error Events</p>
        </div>
      </div>

      <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
        <div className="bg-black/5 px-6 py-4 border-b border-outline-variant/30 flex justify-between items-center">
          <h3 className="font-semibold text-lg">Recent Event Log</h3>
          <button className="text-primary font-medium hover:underline text-sm">Export CSV</button>
        </div>
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-surface-container-low border-b border-outline-variant/30 text-on-surface-variant text-sm">
              <th className="p-4 font-semibold">Timestamp</th>
              <th className="p-4 font-semibold">Event Type</th>
              <th className="p-4 font-semibold">User ID</th>
              <th className="p-4 font-semibold">Data</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan={4} className="p-8 text-center text-on-surface-variant">Loading analytics...</td></tr>
            ) : events.length === 0 ? (
              <tr><td colSpan={4} className="p-8 text-center text-on-surface-variant">No events recorded yet.</td></tr>
            ) : (
              events.map(event => (
                <tr key={event.id} className="border-b border-outline-variant/30 hover:bg-black/5">
                  <td className="p-4 whitespace-nowrap text-sm text-on-surface-variant">
                    {new Date(event.created_at).toLocaleString()}
                  </td>
                  <td className="p-4">
                    <span className="px-2 py-1 bg-primary/10 text-primary rounded-full text-xs font-medium border border-primary/20">
                      {event.event_type}
                    </span>
                  </td>
                  <td className="p-4 text-sm text-on-surface-variant font-mono">
                    {event.user_id ? event.user_id.substring(0, 8) + '...' : 'Anonymous'}
                  </td>
                  <td className="p-4 text-sm text-on-surface-variant truncate max-w-xs">
                    {JSON.stringify(event.event_data)}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}
