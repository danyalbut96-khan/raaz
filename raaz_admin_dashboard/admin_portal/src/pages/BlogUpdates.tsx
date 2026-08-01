import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'

export default function BlogUpdates() {
  const [posts, setPosts] = useState<any[]>([])
  
  useEffect(() => {
    supabase.from('blog_posts').select('*').eq('is_published', true).then(({data}) => {
      if(data) setPosts(data)
    })
  }, [])

  return (
    <div className="py-24 px-6 max-w-7xl mx-auto">
      <h1 className="text-5xl font-bold mb-8">RAAZ Blog</h1>
      <p className="text-lg text-on-surface-variant mb-12">Voices of Privacy & Mental Health</p>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {posts.length === 0 ? (
          <p>No blog posts published yet.</p>
        ) : (
          posts.map(post => (
            <div key={post.id} className="p-6 bg-surface rounded-2xl border border-outline-variant/30">
              <h2 className="text-xl font-bold mb-2">{post.title}</h2>
              <p className="text-on-surface-variant mb-4">{post.content.substring(0, 100)}...</p>
              <button className="text-primary font-medium">Read More</button>
            </div>
          ))
        )}
      </div>
    </div>
  )
}
