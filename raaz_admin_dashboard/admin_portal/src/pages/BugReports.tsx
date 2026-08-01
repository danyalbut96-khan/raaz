import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

type BugReport = {
  id: string
  description: string
  status: string
  device_info: string | null
  app_version: string | null
  created_at: string
  user_id: string | null
}

export default function BugReports() {
  const [reports, setReports] = useState<BugReport[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<'all' | 'open' | 'resolved'>('all')
  const [selected, setSelected] = useState<BugReport | null>(null)

  useEffect(() => { fetchReports() }, [filter])

  async function fetchReports() {
    setLoading(true)
    let q = supabase
      .from('bug_reports')
      .select('*')
      .order('created_at', { ascending: false })

    if (filter === 'resolved') q = q.eq('status', 'resolved')
    else if (filter === 'open') q = q.neq('status', 'resolved')

    const { data } = await q
    setReports((data || []) as BugReport[])
    setLoading(false)
  }

  async function updateStatus(id: string, status: string) {
    await supabase.from('bug_reports').update({ status }).eq('id', id)
    setReports(reports.map(r => r.id === id ? { ...r, status } : r))
    if (selected?.id === id) setSelected(prev => prev ? { ...prev, status } : null)
  }

  const statusColor: Record<string, string> = {
    open: 'bg-red-100 text-red-700',
    in_progress: 'bg-yellow-100 text-yellow-700',
    resolved: 'bg-green-100 text-green-700',
    wont_fix: 'bg-gray-100 text-gray-600',
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Bug Reports</h2>
          <p className="text-on-surface-variant mt-1">Issues submitted by app users.</p>
        </div>
        <button onClick={fetchReports} className="flex items-center gap-2 bg-primary/10 text-primary px-4 py-2 rounded-xl font-medium hover:bg-primary/20">
          <span className="material-symbols-outlined text-lg">refresh</span> Refresh
        </button>
      </div>

      <div className="flex gap-2">
        {(['all', 'open', 'resolved'] as const).map(f => (
          <button key={f} onClick={() => setFilter(f)}
            className={`px-4 py-2 rounded-xl text-sm font-medium capitalize transition-colors ${filter === f ? 'bg-primary text-white' : 'bg-black/5 text-on-surface hover:bg-black/10'}`}>
            {f}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* List */}
        <div className="lg:col-span-2 glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-black/[0.03] border-b border-outline-variant/30 text-on-surface-variant text-sm">
                <th className="p-4 font-semibold">Description</th>
                <th className="p-4 font-semibold">Status</th>
                <th className="p-4 font-semibold">Date</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array(5).fill(0).map((_, i) => (
                  <tr key={i}><td colSpan={3} className="p-4"><div className="h-4 bg-black/10 rounded animate-pulse" /></td></tr>
                ))
              ) : reports.length === 0 ? (
                <tr><td colSpan={3} className="p-10 text-center text-on-surface-variant">No bug reports found.</td></tr>
              ) : reports.map(r => (
                <tr key={r.id}
                  onClick={() => setSelected(r)}
                  className={`border-b border-outline-variant/20 cursor-pointer transition-colors hover:bg-primary/5 ${selected?.id === r.id ? 'bg-primary/10' : ''}`}>
                  <td className="p-4">
                    <p className="text-sm font-medium text-on-surface line-clamp-2">{r.description}</p>
                    <p className="text-xs text-on-surface-variant mt-0.5">
                      {r.user_id ? `User: ${r.user_id.substring(0, 8)}...` : 'Anonymous'}
                    </p>
                  </td>
                  <td className="p-4">
                    <span className={`text-xs font-semibold px-2 py-1 rounded-full capitalize ${statusColor[r.status] || 'bg-gray-100 text-gray-600'}`}>
                      {r.status?.replace('_', ' ') || 'open'}
                    </span>
                  </td>
                  <td className="p-4 text-xs text-on-surface-variant whitespace-nowrap">
                    {new Date(r.created_at).toLocaleDateString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Detail Panel */}
        <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm p-6">
          {!selected ? (
            <div className="h-full flex flex-col items-center justify-center text-center text-on-surface-variant py-16">
              <span className="material-symbols-outlined text-5xl text-outline mb-4">bug_report</span>
              <p className="font-medium">Select a bug report</p>
              <p className="text-sm mt-1">Click any row to view details</p>
            </div>
          ) : (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="font-bold text-lg text-on-surface">Bug Detail</h3>
                <button onClick={() => setSelected(null)} className="text-on-surface-variant hover:text-on-surface">
                  <span className="material-symbols-outlined">close</span>
                </button>
              </div>
              <div className="bg-black/5 rounded-xl p-4 text-sm text-on-surface leading-relaxed">
                {selected.description}
              </div>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-on-surface-variant">User ID</span>
                  <span className="font-mono text-xs">{selected.user_id?.substring(0, 12) || 'Anonymous'}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-on-surface-variant">Submitted</span>
                  <span>{new Date(selected.created_at).toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-on-surface-variant">Status</span>
                  <span className={`text-xs font-semibold px-2 py-0.5 rounded-full capitalize ${statusColor[selected.status] || 'bg-gray-100 text-gray-600'}`}>
                    {selected.status?.replace('_', ' ') || 'open'}
                  </span>
                </div>
              </div>
              <div className="pt-2 border-t border-outline-variant/30">
                <p className="text-xs text-on-surface-variant font-semibold mb-2 uppercase tracking-wider">Update Status</p>
                <div className="grid grid-cols-2 gap-2">
                  {['open', 'in_progress', 'resolved', 'wont_fix'].map(s => (
                    <button key={s} onClick={() => updateStatus(selected.id, s)}
                      className={`px-3 py-2 rounded-lg text-xs font-medium capitalize transition-colors ${selected.status === s ? 'bg-primary text-white' : 'bg-black/5 hover:bg-black/10'}`}>
                      {s.replace('_', ' ')}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
