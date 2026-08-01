import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

type User = {
  user_id: string
  reputation_score: number
  member_since: string
  updated_at: string
}

export default function UsersManagement() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [sortBy, setSortBy] = useState<'member_since' | 'reputation_score'>('member_since')
  const [page, setPage] = useState(0)
  const PAGE_SIZE = 25

  useEffect(() => { fetchUsers() }, [sortBy, page])

  async function fetchUsers() {
    setLoading(true)
    const { data } = await supabase
      .from('profiles')
      .select('user_id, reputation_score, member_since, updated_at')
      .order(sortBy, { ascending: false })
      .range(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1)

    setUsers((data || []) as User[])
    setLoading(false)
  }

  const filtered = users.filter(u =>
    u.user_id.toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Users Management</h2>
          <p className="text-on-surface-variant mt-1">Browse and manage app users (auto-created on sign up).</p>
        </div>
        <button onClick={fetchUsers} className="flex items-center gap-2 bg-primary/10 text-primary px-4 py-2 rounded-xl font-medium hover:bg-primary/20">
          <span className="material-symbols-outlined text-lg">refresh</span> Refresh
        </button>
      </div>

      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant text-lg">search</span>
          <input
            type="text"
            placeholder="Search by User ID..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-outline bg-surface focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>
        <select
          value={sortBy}
          onChange={e => setSortBy(e.target.value as typeof sortBy)}
          className="px-4 py-2.5 rounded-xl border border-outline bg-surface text-sm focus:outline-none focus:ring-2 focus:ring-primary"
        >
          <option value="member_since">Sort: Newest First</option>
          <option value="reputation_score">Sort: Highest Reputation</option>
        </select>
      </div>

      <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-black/[0.03] border-b border-outline-variant/30 text-on-surface-variant text-sm">
                <th className="p-4 font-semibold">#</th>
                <th className="p-4 font-semibold">User ID</th>
                <th className="p-4 font-semibold">Reputation</th>
                <th className="p-4 font-semibold">Joined</th>
                <th className="p-4 font-semibold">Last Active</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array(8).fill(0).map((_, i) => (
                  <tr key={i}><td colSpan={5} className="p-4"><div className="h-4 bg-black/10 rounded animate-pulse" /></td></tr>
                ))
              ) : filtered.length === 0 ? (
                <tr><td colSpan={5} className="p-10 text-center text-on-surface-variant">No users found.</td></tr>
              ) : filtered.map((user, i) => (
                <tr key={user.user_id} className="border-b border-outline-variant/20 hover:bg-black/[0.02] transition-colors">
                  <td className="p-4 text-sm text-on-surface-variant font-mono">{page * PAGE_SIZE + i + 1}</td>
                  <td className="p-4">
                    <span className="font-mono text-sm text-on-surface bg-black/5 px-2 py-1 rounded">{user.user_id}</span>
                  </td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      <div className="h-2 bg-primary/20 rounded-full w-24 overflow-hidden">
                        <div
                          className="h-full bg-primary rounded-full"
                          style={{ width: `${Math.min((user.reputation_score / 1000) * 100, 100)}%` }}
                        />
                      </div>
                      <span className="text-sm font-semibold text-primary">{user.reputation_score}</span>
                    </div>
                  </td>
                  <td className="p-4 text-sm text-on-surface-variant whitespace-nowrap">
                    {new Date(user.member_since).toLocaleDateString()}
                  </td>
                  <td className="p-4 text-sm text-on-surface-variant whitespace-nowrap">
                    {new Date(user.updated_at).toLocaleDateString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="flex items-center justify-between px-6 py-3 border-t border-outline-variant/30 bg-black/[0.02]">
          <span className="text-sm text-on-surface-variant">Page {page + 1} · Showing {PAGE_SIZE} per page</span>
          <div className="flex gap-2">
            <button disabled={page === 0} onClick={() => setPage(p => p - 1)} className="px-4 py-1.5 rounded-lg border border-outline-variant text-sm disabled:opacity-40 hover:bg-black/5">← Prev</button>
            <button disabled={users.length < PAGE_SIZE} onClick={() => setPage(p => p + 1)} className="px-4 py-1.5 rounded-lg border border-outline-variant text-sm disabled:opacity-40 hover:bg-black/5">Next →</button>
          </div>
        </div>
      </div>
    </div>
  )
}
