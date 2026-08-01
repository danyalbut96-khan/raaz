import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function PostsManagement() {
  const [posts, setPosts] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchPosts()
  }, [])

  async function fetchPosts() {
    setLoading(true)
    const { data, error } = await supabase
      .from('posts')
      .select('*, categories(name)')
      .order('created_at', { ascending: false })
      .limit(50)
      
    if (!error && data) {
      setPosts(data)
    }
    setLoading(false)
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this post?')) return
    
    const { error } = await supabase
      .from('posts')
      .delete()
      .eq('id', id)
      
    if (!error) {
      setPosts(posts.filter(p => p.id !== id))
    } else {
      alert('Failed to delete post: ' + error.message)
    }
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Posts Management</h2>
          <p className="text-on-surface-variant mt-2">View and moderate community posts.</p>
        </div>
        <button 
          onClick={fetchPosts}
          className="bg-primary/10 text-primary px-4 py-2 rounded-xl font-medium hover:bg-primary/20 transition-colors flex items-center"
        >
          <span className="material-symbols-outlined mr-2">refresh</span>
          Refresh
        </button>
      </div>

      <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-black/5 border-b border-outline-variant/30 text-on-surface-variant text-sm">
                <th className="p-4 font-semibold">Content</th>
                <th className="p-4 font-semibold">Category</th>
                <th className="p-4 font-semibold">Date</th>
                <th className="p-4 font-semibold text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={4} className="p-8 text-center text-on-surface-variant">
                    Loading posts...
                  </td>
                </tr>
              ) : posts.length === 0 ? (
                <tr>
                  <td colSpan={4} className="p-8 text-center text-on-surface-variant">
                    No posts found.
                  </td>
                </tr>
              ) : (
                posts.map(post => (
                  <tr key={post.id} className="border-b border-outline-variant/30 hover:bg-black/5 transition-colors">
                    <td className="p-4">
                      <div className="max-w-md truncate text-on-surface font-medium">
                        {post.content}
                      </div>
                      <div className="text-xs text-on-surface-variant mt-1">
                        By: {post.author_id}
                      </div>
                    </td>
                    <td className="p-4 text-sm text-on-surface-variant">
                      {post.categories?.name || 'Unknown'}
                    </td>
                    <td className="p-4 text-sm text-on-surface-variant whitespace-nowrap">
                      {new Date(post.created_at).toLocaleDateString()}
                    </td>
                    <td className="p-4 text-right">
                      <button 
                        onClick={() => handleDelete(post.id)}
                        className="text-red-500 hover:text-red-700 p-2 rounded-lg hover:bg-red-50 transition-colors"
                        title="Delete Post"
                      >
                        <span className="material-symbols-outlined text-lg">delete</span>
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
