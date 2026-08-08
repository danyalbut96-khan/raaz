import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

type Post = {
  id: string
  body: string
  pseudonym: string
  mood: string | null
  is_featured: boolean
  is_ghost_mode: boolean
  is_deleted: boolean
  created_at: string
  categories: { name: string } | null
}


export default function PostsManagement() {
  const [posts, setPosts] = useState<Post[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState('All')
  const [page, setPage] = useState(0)
  const PAGE_SIZE = 20

  useEffect(() => { 
    fetchPosts() 

    const channel = supabase
      .channel('posts_changes')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'posts' },
        () => {
          fetchPosts()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [page, filter])

  async function fetchPosts() {
    setLoading(true)
    let query = supabase
      .from('posts')
      .select('id, body, pseudonym, mood, is_featured, is_ghost_mode, is_deleted, created_at, categories(name)')
      .order('created_at', { ascending: false })
      .range(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1)

    if (filter !== 'All') {
      query = query.eq('is_deleted', filter === 'deleted')
    }

    const { data, error } = await query
    if (!error && data) setPosts(data as unknown as Post[])
    setLoading(false)
  }

  const handleDelete = async (id: string, permanent = false) => {
    const msg = permanent ? 'Permanently DELETE this post? This cannot be undone.' : 'Soft-delete this post?'
    if (!confirm(msg)) return
    if (permanent) {
      await supabase.from('posts').delete().eq('id', id)
      setPosts(posts.filter(p => p.id !== id))
    } else {
      await supabase.from('posts').update({ is_deleted: true }).eq('id', id)
      setPosts(posts.map(p => p.id === id ? { ...p, is_deleted: true } : p))
    }
  }

  const handleRestore = async (id: string) => {
    await supabase.from('posts').update({ is_deleted: false }).eq('id', id)
    setPosts(posts.map(p => p.id === id ? { ...p, is_deleted: false } : p))
  }

  const handleFeature = async (id: string, current: boolean) => {
    await supabase.from('posts').update({ is_featured: !current }).eq('id', id)
    setPosts(posts.map(p => p.id === id ? { ...p, is_featured: !current } : p))
  }

  const filtered = posts.filter(p =>
    p.body.toLowerCase().includes(search.toLowerCase()) ||
    p.pseudonym.toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Posts Management</h2>
          <p className="text-on-surface-variant mt-1">Moderate, feature, or remove community posts.</p>
        </div>
        <button onClick={fetchPosts} className="flex items-center gap-2 bg-primary/10 text-primary px-4 py-2 rounded-xl font-medium hover:bg-primary/20 transition-colors self-start">
          <span className="material-symbols-outlined text-lg">refresh</span> Refresh
        </button>
      </div>

      {/* Search & Filter Bar */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant text-lg">search</span>
          <input
            type="text"
            placeholder="Search by content or pseudonym..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-outline bg-surface focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>
        <div className="flex gap-2 flex-wrap">
          {['All', 'active', 'deleted'].map(f => (
            <button
              key={f}
              onClick={() => { setFilter(f); setPage(0) }}
              className={`px-4 py-2 rounded-xl text-sm font-medium capitalize transition-colors ${
                filter === f ? 'bg-primary text-white' : 'bg-black/5 text-on-surface hover:bg-black/10'
              }`}
            >
              {f}
            </button>
          ))}
        </div>
      </div>

      <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-black/[0.03] border-b border-outline-variant/30 text-on-surface-variant text-sm">
                <th className="p-4 font-semibold">Content</th>
                <th className="p-4 font-semibold">Category</th>
                <th className="p-4 font-semibold">Mood</th>
                <th className="p-4 font-semibold">Flags</th>
                <th className="p-4 font-semibold">Date</th>
                <th className="p-4 font-semibold text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array(5).fill(0).map((_, i) => (
                  <tr key={i} className="border-b border-outline-variant/20">
                    <td colSpan={6} className="p-4">
                      <div className="h-4 bg-black/10 rounded animate-pulse" />
                    </td>
                  </tr>
                ))
              ) : filtered.length === 0 ? (
                <tr><td colSpan={6} className="p-10 text-center text-on-surface-variant">No posts found.</td></tr>
              ) : (
                filtered.map(post => (
                  <tr key={post.id} className={`border-b border-outline-variant/20 transition-colors hover:bg-black/[0.02] ${post.is_deleted ? 'opacity-50 bg-red-50/30' : ''}`}>
                    <td className="p-4 max-w-xs">
                      <p className="text-on-surface text-sm font-medium line-clamp-2">{post.body}</p>
                      <span className="text-xs text-primary bg-primary/10 px-2 py-0.5 rounded-full font-medium mt-1 inline-block">
                        {post.pseudonym}
                      </span>
                    </td>
                    <td className="p-4 text-sm text-on-surface-variant whitespace-nowrap">
                      {post.categories?.name || '—'}
                    </td>
                    <td className="p-4 text-sm text-on-surface-variant capitalize">
                      {post.mood || '—'}
                    </td>
                    <td className="p-4">
                      <div className="flex gap-1 flex-wrap">
                        {post.is_featured && <span className="text-xs bg-yellow-100 text-yellow-700 px-2 py-0.5 rounded-full font-medium">Featured</span>}
                        {post.is_ghost_mode && <span className="text-xs bg-purple-100 text-purple-700 px-2 py-0.5 rounded-full font-medium">Ghost</span>}
                        {post.is_deleted && <span className="text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded-full font-medium">Deleted</span>}
                      </div>
                    </td>
                    <td className="p-4 text-sm text-on-surface-variant whitespace-nowrap">
                      {new Date(post.created_at).toLocaleDateString()}
                    </td>
                    <td className="p-4">
                      <div className="flex items-center justify-end gap-1">
                        <button
                          onClick={() => handleFeature(post.id, post.is_featured)}
                          title={post.is_featured ? 'Unfeature' : 'Feature'}
                          className="p-2 rounded-lg hover:bg-yellow-50 text-yellow-500 hover:text-yellow-700 transition-colors"
                        >
                          <span className="material-symbols-outlined text-lg">{post.is_featured ? 'star' : 'star_border'}</span>
                        </button>
                        {post.is_deleted ? (
                          <button
                            onClick={() => handleRestore(post.id)}
                            title="Restore"
                            className="p-2 rounded-lg hover:bg-green-50 text-green-500 hover:text-green-700 transition-colors"
                          >
                            <span className="material-symbols-outlined text-lg">restore</span>
                          </button>
                        ) : (
                          <button
                            onClick={() => handleDelete(post.id)}
                            title="Soft Delete"
                            className="p-2 rounded-lg hover:bg-red-50 text-red-400 hover:text-red-700 transition-colors"
                          >
                            <span className="material-symbols-outlined text-lg">delete</span>
                          </button>
                        )}
                        <button
                          onClick={() => handleDelete(post.id, true)}
                          title="Permanent Delete"
                          className="p-2 rounded-lg hover:bg-red-100 text-red-600 hover:text-red-900 transition-colors"
                        >
                          <span className="material-symbols-outlined text-lg">delete_forever</span>
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
        {/* Pagination */}
        <div className="flex items-center justify-between px-6 py-3 border-t border-outline-variant/30 bg-black/[0.02]">
          <span className="text-sm text-on-surface-variant">Page {page + 1}</span>
          <div className="flex gap-2">
            <button disabled={page === 0} onClick={() => setPage(p => p - 1)} className="px-4 py-1.5 rounded-lg border border-outline-variant text-sm disabled:opacity-40 hover:bg-black/5 transition-colors">← Prev</button>
            <button disabled={posts.length < PAGE_SIZE} onClick={() => setPage(p => p + 1)} className="px-4 py-1.5 rounded-lg border border-outline-variant text-sm disabled:opacity-40 hover:bg-black/5 transition-colors">Next →</button>
          </div>
        </div>
      </div>
    </div>
  )
}
