import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

type Report = {
  id: string
  reason: string
  status: string
  created_at: string
  reporter_id: string
  posts: { body: string; pseudonym: string } | null
}

export default function ReportsManagement() {
  const [reports, setReports] = useState<Report[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<'all' | 'pending' | 'reviewed' | 'dismissed'>('all')

  useEffect(() => { 
    fetchReports() 

    const channel = supabase
      .channel('reported_posts_changes')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'reported_posts' },
        () => {
          fetchReports()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [filter])

  async function fetchReports() {
    setLoading(true)
    let q = supabase
      .from('reported_posts')
      .select('id, reason, status, created_at, reporter_id, posts(body, pseudonym)')
      .order('created_at', { ascending: false })
      .limit(100)

    if (filter !== 'all') q = q.eq('status', filter)

    const { data } = await q
    setReports((data || []) as unknown as Report[])
    setLoading(false)
  }

  const updateStatus = async (id: string, status: string) => {
    await supabase.from('reported_posts').update({ status }).eq('id', id)
    setReports(reports.map(r => r.id === id ? { ...r, status } : r))
  }

  const deletePost = async (postId: string | undefined, reportId: string) => {
    if (!postId || !confirm('Delete the reported post?')) return
    await supabase.from('posts').update({ is_deleted: true }).eq('id', postId)
    await supabase.from('reported_posts').update({ status: 'reviewed' }).eq('id', reportId)
    fetchReports()
  }

  const reasonColor: Record<string, string> = {
    spam: 'bg-orange-100 text-orange-700',
    hate_speech: 'bg-red-100 text-red-800',
    harassment: 'bg-pink-100 text-pink-700',
    misinformation: 'bg-yellow-100 text-yellow-700',
    other: 'bg-gray-100 text-gray-600',
  }

  const statusColor: Record<string, string> = {
    pending: 'bg-orange-100 text-orange-700',
    reviewed: 'bg-blue-100 text-blue-700',
    dismissed: 'bg-green-100 text-green-700',
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Content Reports</h2>
          <p className="text-on-surface-variant mt-1">Review and action on posts flagged by users.</p>
        </div>
        <button onClick={fetchReports} className="flex items-center gap-2 bg-primary/10 text-primary px-4 py-2 rounded-xl font-medium hover:bg-primary/20">
          <span className="material-symbols-outlined text-lg">refresh</span> Refresh
        </button>
      </div>

      <div className="flex gap-2 flex-wrap">
        {(['all', 'pending', 'reviewed', 'dismissed'] as const).map(f => (
          <button key={f} onClick={() => setFilter(f)}
            className={`px-4 py-2 rounded-xl text-sm font-medium capitalize transition-colors ${filter === f ? 'bg-primary text-white' : 'bg-black/5 text-on-surface hover:bg-black/10'}`}>
            {f}
          </button>
        ))}
      </div>

      <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-black/[0.03] border-b border-outline-variant/30 text-on-surface-variant text-sm">
                <th className="p-4 font-semibold">Reported Post</th>
                <th className="p-4 font-semibold">Reason</th>
                <th className="p-4 font-semibold">Status</th>
                <th className="p-4 font-semibold">Date</th>
                <th className="p-4 font-semibold text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array(5).fill(0).map((_, i) => (
                  <tr key={i}><td colSpan={5} className="p-4"><div className="h-4 bg-black/10 rounded animate-pulse" /></td></tr>
                ))
              ) : reports.length === 0 ? (
                <tr><td colSpan={5} className="p-10 text-center text-on-surface-variant">No reports found.</td></tr>
              ) : reports.map(r => (
                <tr key={r.id} className="border-b border-outline-variant/20 hover:bg-black/[0.02] transition-colors">
                  <td className="p-4 max-w-xs">
                    <p className="text-sm font-medium text-on-surface line-clamp-2">{r.posts?.body || '(Post deleted)'}</p>
                    <span className="text-xs text-primary mt-1 inline-block">By: {r.posts?.pseudonym || '—'}</span>
                  </td>
                  <td className="p-4">
                    <span className={`text-xs font-semibold px-2 py-1 rounded-full capitalize ${reasonColor[r.reason] || 'bg-gray-100 text-gray-600'}`}>
                      {r.reason.replace('_', ' ')}
                    </span>
                  </td>
                  <td className="p-4">
                    <span className={`text-xs font-semibold px-2 py-1 rounded-full capitalize ${statusColor[r.status] || 'bg-gray-100'}`}>
                      {r.status}
                    </span>
                  </td>
                  <td className="p-4 text-xs text-on-surface-variant whitespace-nowrap">
                    {new Date(r.created_at).toLocaleDateString()}
                  </td>
                  <td className="p-4">
                    <div className="flex items-center justify-end gap-1">
                      <button onClick={() => updateStatus(r.id, 'reviewed')} title="Mark Reviewed"
                        className="p-2 rounded-lg hover:bg-blue-50 text-blue-500 transition-colors">
                        <span className="material-symbols-outlined text-lg">task_alt</span>
                      </button>
                      <button onClick={() => updateStatus(r.id, 'dismissed')} title="Dismiss"
                        className="p-2 rounded-lg hover:bg-green-50 text-green-500 transition-colors">
                        <span className="material-symbols-outlined text-lg">cancel</span>
                      </button>
                      <button onClick={() => deletePost(r.posts ? undefined : undefined, r.id)} title="Delete Post"
                        className="p-2 rounded-lg hover:bg-red-50 text-red-500 transition-colors">
                        <span className="material-symbols-outlined text-lg">delete_sweep</span>
                      </button>
                    </div>
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
