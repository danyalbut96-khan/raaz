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
  is_published: boolean
  published_at: string
}

export default function BlogManagement() {
  const [blogs, setBlogs] = useState<BlogPost[]>([])
  const [loading, setLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [editingBlog, setEditingBlog] = useState<BlogPost | null>(null)

  // Form states
  const [title, setTitle] = useState('')
  const [summary, setSummary] = useState('')
  const [content, setContent] = useState('')
  const [coverUrl, setCoverUrl] = useState('')
  const [author, setAuthor] = useState('RAAZ Team')
  const [tagsStr, setTagsStr] = useState('')
  const [isPublished, setIsPublished] = useState(true)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    fetchBlogs()
  }, [])

  async function fetchBlogs() {
    setLoading(true)
    const { data } = await supabase
      .from('blog_posts')
      .select('*')
      .order('published_at', { ascending: false })
    if (data) setBlogs(data)
    setLoading(false)
  }

  function openCreateModal() {
    setEditingBlog(null)
    setTitle('')
    setSummary('')
    setContent('')
    setCoverUrl('')
    setAuthor('RAAZ Team')
    setTagsStr('Announcements, Privacy')
    setIsPublished(true)
    setShowModal(true)
  }

  function openEditModal(b: BlogPost) {
    setEditingBlog(b)
    setTitle(b.title)
    setSummary(b.summary || '')
    setContent(b.content)
    setCoverUrl(b.cover_image_url || '')
    setAuthor(b.author_name || 'RAAZ Team')
    setTagsStr((b.tags || []).join(', '))
    setIsPublished(b.is_published)
    setShowModal(true)
  }

  async function handleSave(e: React.FormEvent) {
    e.preventDefault()
    if (!title.trim() || !content.trim()) return
    setSaving(true)

    const slug = title
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)+/g, '')

    const tags = tagsStr.split(',').map((t) => t.trim()).filter(Boolean)

    const payload = {
      title,
      slug,
      summary,
      content,
      cover_image_url: coverUrl || 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80',
      author_name: author,
      tags,
      is_published: isPublished,
    }

    if (editingBlog) {
      await supabase.from('blog_posts').update(payload).eq('id', editingBlog.id)
    } else {
      await supabase.from('blog_posts').insert([payload])
    }

    setSaving(false)
    setShowModal(false)
    fetchBlogs()
  }

  async function handleDelete(id: string) {
    if (!confirm('Are you sure you want to delete this blog post?')) return
    await supabase.from('blog_posts').delete().eq('id', id)
    fetchBlogs()
  }

  async function togglePublish(b: BlogPost) {
    await supabase
      .from('blog_posts')
      .update({ is_published: !b.is_published })
      .eq('id', b.id)
    fetchBlogs()
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Blog Management</h1>
          <p className="text-slate-500 text-sm">Create and publish announcements or articles to the public landing page</p>
        </div>
        <button
          onClick={openCreateModal}
          className="bg-indigo-600 hover:bg-indigo-700 text-white font-medium px-4 py-2 rounded-lg text-sm transition shadow"
        >
          + Create New Post
        </button>
      </div>

      {loading ? (
        <div className="p-8 text-center text-slate-400">Loading blog posts...</div>
      ) : blogs.length === 0 ? (
        <div className="bg-white rounded-xl p-12 text-center border border-slate-200">
          <p className="text-slate-500">No blog posts found. Create your first post!</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {blogs.map((b) => (
            <div key={b.id} className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden flex flex-col">
              <img src={b.cover_image_url} alt={b.title} className="h-44 w-full object-cover" />
              <div className="p-5 flex-1 flex flex-col justify-between space-y-4">
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className={`text-xs px-2.5 py-1 rounded-full font-medium ${b.is_published ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'}`}>
                      {b.is_published ? 'Published' : 'Draft'}
                    </span>
                    <span className="text-xs text-slate-400">{new Date(b.published_at).toLocaleDateString()}</span>
                  </div>
                  <h3 className="font-bold text-slate-800 text-lg leading-snug line-clamp-2">{b.title}</h3>
                  <p className="text-slate-500 text-sm mt-2 line-clamp-3">{b.summary || b.content}</p>
                </div>

                <div className="pt-4 border-t border-slate-100 flex items-center justify-between">
                  <div className="flex gap-2">
                    <button
                      onClick={() => openEditModal(b)}
                      className="text-indigo-600 hover:text-indigo-800 text-xs font-semibold"
                    >
                      Edit
                    </button>
                    <button
                      onClick={() => togglePublish(b)}
                      className="text-slate-600 hover:text-slate-800 text-xs font-semibold"
                    >
                      {b.is_published ? 'Unpublish' : 'Publish'}
                    </button>
                  </div>
                  <button
                    onClick={() => handleDelete(b.id)}
                    className="text-rose-600 hover:text-rose-800 text-xs font-semibold"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-6 space-y-4 max-h-[90vh] overflow-y-auto shadow-2xl">
            <h2 className="text-xl font-bold text-slate-800">
              {editingBlog ? 'Edit Blog Post' : 'Create Blog Post'}
            </h2>

            <form onSubmit={handleSave} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-600 uppercase mb-1">Title</label>
                <input
                  type="text"
                  required
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 outline-none"
                  placeholder="e.g. Introducing Enhanced Encryption Features"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-600 uppercase mb-1">Summary / Excerpt</label>
                <input
                  type="text"
                  value={summary}
                  onChange={(e) => setSummary(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 outline-none"
                  placeholder="Short overview of the article"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-600 uppercase mb-1">Cover Image URL</label>
                <input
                  type="url"
                  value={coverUrl}
                  onChange={(e) => setCoverUrl(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 outline-none"
                  placeholder="https://..."
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-slate-600 uppercase mb-1">Author Name</label>
                  <input
                    type="text"
                    value={author}
                    onChange={(e) => setAuthor(e.target.value)}
                    className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-600 uppercase mb-1">Tags (Comma Separated)</label>
                  <input
                    type="text"
                    value={tagsStr}
                    onChange={(e) => setTagsStr(e.target.value)}
                    className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-600 uppercase mb-1">Content (Markdown / Text)</label>
                <textarea
                  rows={6}
                  required
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 outline-none font-mono"
                  placeholder="Write post content here..."
                />
              </div>

              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="pubCheck"
                  checked={isPublished}
                  onChange={(e) => setIsPublished(e.target.checked)}
                  className="rounded text-indigo-600"
                />
                <label htmlFor="pubCheck" className="text-sm font-medium text-slate-700">Publish immediately to Landing Page</label>
              </div>

              <div className="flex justify-end gap-3 pt-4 border-t">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2 text-sm text-slate-600 hover:text-slate-800"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={saving}
                  className="px-5 py-2 text-sm bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 disabled:opacity-50"
                >
                  {saving ? 'Saving...' : 'Save Post'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
