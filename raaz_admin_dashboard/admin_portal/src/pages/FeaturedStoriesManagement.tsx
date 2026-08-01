import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function FeaturedStoriesManagement() {
  const [featuredStories, setFeaturedStories] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchStories()
  }, [])

  async function fetchStories() {
    setLoading(true)
    const { data, error } = await supabase
      .from('featured_stories')
      .select('*, posts(content, author_id)')
      .order('created_at', { ascending: false })
      
    if (!error && data) {
      setFeaturedStories(data)
    }
    setLoading(false)
  }

  const toggleStatus = async (id: string, currentStatus: boolean) => {
    const { error } = await supabase
      .from('featured_stories')
      .update({ is_active: !currentStatus })
      .eq('id', id)

    if (!error) {
      setFeaturedStories(featuredStories.map(c => 
        c.id === id ? { ...c, is_active: !currentStatus } : c
      ))
    }
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Featured Stories</h2>
          <p className="text-on-surface-variant mt-2">Manage posts highlighted on the home feed.</p>
        </div>
      </div>

      <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-black/5 border-b border-outline-variant/30 text-on-surface-variant text-sm">
              <th className="p-4 font-semibold">Post Content</th>
              <th className="p-4 font-semibold">Featured Date</th>
              <th className="p-4 font-semibold">Status</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan={3} className="p-8 text-center text-on-surface-variant">Loading stories...</td></tr>
            ) : featuredStories.length === 0 ? (
              <tr><td colSpan={3} className="p-8 text-center text-on-surface-variant">No featured stories yet. Go to Posts to feature one.</td></tr>
            ) : (
              featuredStories.map(story => (
                <tr key={story.id} className="border-b border-outline-variant/30 hover:bg-black/5">
                  <td className="p-4">
                    <div className="max-w-md truncate font-medium text-on-surface">{story.posts?.content || 'Post deleted'}</div>
                    <div className="text-xs text-on-surface-variant mt-1">By: {story.posts?.author_id || 'Unknown'}</div>
                  </td>
                  <td className="p-4 text-sm text-on-surface-variant whitespace-nowrap">
                    {new Date(story.created_at).toLocaleDateString()}
                  </td>
                  <td className="p-4">
                    <button 
                      onClick={() => toggleStatus(story.id, story.is_active)}
                      className={`px-3 py-1 rounded-full text-xs font-medium ${
                        story.is_active 
                          ? 'bg-green-100 text-green-700 hover:bg-red-100 hover:text-red-700' 
                          : 'bg-red-100 text-red-700 hover:bg-green-100 hover:text-green-700'
                      } transition-colors`}
                    >
                      {story.is_active ? 'Active' : 'Hidden'}
                    </button>
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
