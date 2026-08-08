import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

type BlogPost = {
  id: string
  title: string
  slug: string
  summary: string
  content: string
  cover_image_url: string
  author_name: string
  tags: string[]
  published_at: string
}

export default function BlogUpdates() {
  const [posts, setPosts] = useState<BlogPost[]>([])
  const [loading, setLoading] = useState(true)
  const [selected, setSelected] = useState<BlogPost | null>(null)
  const [search, setSearch] = useState('')

  useEffect(() => {
    fetchPosts()
    const sub = supabase
      .channel('blog_updates_public')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'blog_posts' }, fetchPosts)
      .subscribe()
    return () => { supabase.removeChannel(sub) }
  }, [])

  async function fetchPosts() {
    setLoading(true)
    const { data } = await supabase
      .from('blog_posts')
      .select('*')
      .eq('is_published', true)
      .order('published_at', { ascending: false })
    if (data) setPosts(data)
    setLoading(false)
  }

  const filtered = posts.filter(
    (p) =>
      p.title.toLowerCase().includes(search.toLowerCase()) ||
      (p.summary || '').toLowerCase().includes(search.toLowerCase()) ||
      (p.tags || []).some((t) => t.toLowerCase().includes(search.toLowerCase()))
  )

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <section className="py-20 px-6 bg-gradient-to-br from-slate-950 via-indigo-950 to-slate-900 text-center relative overflow-hidden">
        <div className="absolute -top-20 left-1/4 w-96 h-96 bg-indigo-600/20 rounded-full blur-3xl pointer-events-none" />
        <div className="relative z-10">
          <span className="inline-block px-4 py-1.5 bg-indigo-500/20 text-indigo-300 rounded-full text-sm font-semibold mb-4 border border-indigo-500/30">
            RAAZ Blog
          </span>
          <h1 className="text-5xl font-extrabold text-white mb-4">Announcements &amp; Updates</h1>
          <p className="text-indigo-200 text-lg max-w-xl mx-auto">
            Latest news, feature releases, community stories and insights from the RAAZ team.
          </p>
          {/* Search */}
          <div className="mt-8 max-w-md mx-auto">
            <div className="relative">
              <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">search</span>
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search posts..."
                className="w-full pl-12 pr-4 py-3 rounded-2xl bg-white/10 border border-white/20 text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 backdrop-blur"
              />
            </div>
          </div>
        </div>
      </section>

      {/* Posts Grid */}
      <section className="py-20 px-6">
        <div className="max-w-6xl mx-auto">
          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {[1, 2, 3].map((i) => (
                <div key={i} className="bg-slate-100 rounded-2xl h-80 animate-pulse" />
              ))}
            </div>
          ) : filtered.length === 0 ? (
            <div className="text-center py-24 text-slate-400">
              <span className="material-symbols-outlined text-5xl mb-4 block">article</span>
              <p className="text-lg">No blog posts found{search ? ` for "${search}"` : ''}.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filtered.map((post) => (
                <div
                  key={post.id}
                  onClick={() => setSelected(post)}
                  className="group cursor-pointer bg-white border border-slate-100 rounded-2xl shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 overflow-hidden flex flex-col"
                >
                  <img
                    src={post.cover_image_url || 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80'}
                    alt={post.title}
                    className="w-full h-48 object-cover group-hover:scale-105 transition-transform duration-500"
                  />
                  <div className="p-6 flex-1 flex flex-col justify-between">
                    <div>
                      <div className="flex flex-wrap gap-2 mb-3">
                        {(post.tags || []).slice(0, 3).map((tag, j) => (
                          <span key={j} className="text-xs px-2.5 py-1 rounded-full bg-indigo-50 text-indigo-600 font-medium">{tag}</span>
                        ))}
                      </div>
                      <h3 className="text-lg font-bold text-slate-900 mb-2 line-clamp-2">{post.title}</h3>
                      <p className="text-slate-500 text-sm line-clamp-3">{post.summary || post.content}</p>
                    </div>
                    <div className="flex items-center justify-between mt-5 pt-4 border-t border-slate-100">
                      <div className="flex items-center gap-2">
                        <div className="w-6 h-6 rounded-full bg-indigo-100 flex items-center justify-center">
                          <span className="material-symbols-outlined text-indigo-600 text-xs">person</span>
                        </div>
                        <span className="text-xs text-slate-500 font-medium">{post.author_name}</span>
                      </div>
                      <span className="text-xs text-slate-400">{new Date(post.published_at).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </section>

      {/* Post Reader Modal */}
      {selected && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4"
          onClick={() => setSelected(null)}
        >
          <div
            className="bg-white rounded-3xl max-w-3xl w-full max-h-[90vh] overflow-y-auto shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <img
              src={selected.cover_image_url || 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80'}
              alt={selected.title}
              className="w-full h-64 object-cover rounded-t-3xl"
            />
            <div className="p-8">
              <div className="flex flex-wrap gap-2 mb-4">
                {(selected.tags || []).map((tag, j) => (
                  <span key={j} className="text-xs px-2.5 py-1 rounded-full bg-indigo-50 text-indigo-600 font-medium">{tag}</span>
                ))}
              </div>
              <h2 className="text-3xl font-extrabold text-slate-900 mb-2">{selected.title}</h2>
              <div className="flex items-center gap-3 text-sm text-slate-400 mb-6 pb-6 border-b border-slate-100">
                <span>{selected.author_name}</span>
                <span>•</span>
                <span>{new Date(selected.published_at).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</span>
              </div>
              <div className="text-slate-700 leading-loose whitespace-pre-wrap text-base">
                {selected.content}
              </div>
              <div className="mt-8 flex justify-end">
                <button
                  onClick={() => setSelected(null)}
                  className="px-6 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl font-medium transition-colors"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
