import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

type Post = {
  id: string
  body: string
  pseudonym: string
  created_at: string
  category_id: string | null
  categories: { name: string, icon: string } | null
  comment_count: number
  upvotes: number
}

export default function FeaturedStoriesManagement() {
  const [posts, setPosts] = useState<Post[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchFeaturedPosts()

    const channel = supabase
      .channel('featured_posts_changes')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'posts', filter: 'is_featured=eq.true' }, fetchFeaturedPosts)
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  async function fetchFeaturedPosts() {
    setLoading(true)
    const { data } = await supabase
      .from('posts')
      .select('id, body, pseudonym, created_at, category_id, categories(name, icon), comment_count, upvotes')
      .eq('is_featured', true)
      .eq('is_deleted', false)
      .order('created_at', { ascending: false })

    setPosts((data || []) as unknown as Post[])
    setLoading(false)
  }

  const unfeaturePost = async (id: string) => {
    await supabase.from('posts').update({ is_featured: false }).eq('id', id)
    fetchFeaturedPosts()
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold text-on-surface flex items-center">
            <span className="material-symbols-outlined text-amber-400 text-3xl mr-3">star</span>
            Featured Stories
          </h2>
          <p className="text-on-surface-variant mt-1">Manage the top pinned posts shown in the Featured tab.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {loading ? (
          Array(3).fill(0).map((_, i) => (
            <div key={i} className="glass-panel p-6 rounded-2xl h-48 animate-pulse bg-black/5" />
          ))
        ) : posts.length === 0 ? (
          <div className="col-span-full py-16 text-center text-on-surface-variant glass-panel rounded-2xl">
            <span className="material-symbols-outlined text-5xl opacity-50 mb-3">auto_awesome</span>
            <p>No featured stories right now.</p>
            <p className="text-sm mt-1">Feature a story from the Posts Management page.</p>
          </div>
        ) : (
          posts.map(post => (
            <div key={post.id} className="glass-panel p-6 rounded-2xl border border-amber-500/30 shadow-sm flex flex-col relative overflow-hidden group">
              <div className="absolute top-0 right-0 w-24 h-24 bg-gradient-to-bl from-amber-400/20 to-transparent pointer-events-none" />
              
              <div className="flex justify-between items-start mb-4">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 rounded-full bg-black/5 flex items-center justify-center text-sm font-bold">
                    {post.pseudonym[0].toUpperCase()}
                  </div>
                  <span className="font-semibold text-sm">{post.pseudonym}</span>
                </div>
                {post.categories && (
                  <span className="text-xs font-medium bg-black/5 px-2 py-1 rounded-full flex items-center">
                    <span className="mr-1">{post.categories.icon}</span> {post.categories.name}
                  </span>
                )}
              </div>

              <p className="text-sm text-on-surface mb-6 flex-1 line-clamp-4 leading-relaxed">
                {post.body}
              </p>

              <div className="flex items-center justify-between pt-4 border-t border-outline-variant/30">
                <div className="flex items-center gap-4 text-on-surface-variant text-sm">
                  <span className="flex items-center"><span className="material-symbols-outlined text-[16px] mr-1">thumb_up</span> {post.upvotes}</span>
                  <span className="flex items-center"><span className="material-symbols-outlined text-[16px] mr-1">chat</span> {post.comment_count}</span>
                </div>
                
                <button 
                  onClick={() => unfeaturePost(post.id)}
                  className="text-xs font-semibold text-red-500 hover:bg-red-50 px-3 py-1.5 rounded-lg transition-colors"
                >
                  Unfeature
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  )
}
