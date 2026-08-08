import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

type Category = {
  id: string
  name: string
  icon: string
  sort_order: number
  description: string
  is_hidden: boolean
  post_count?: number
}

export default function CategoriesManagement() {
  const [categories, setCategories] = useState<Category[]>([])
  const [loading, setLoading] = useState(true)
  const [editingId, setEditingId] = useState<string | null>(null)
  
  // Edit Form State
  const [editName, setEditName] = useState('')
  const [editDesc, setEditDesc] = useState('')
  const [editIcon, setEditIcon] = useState('')
  const [editHidden, setEditHidden] = useState(false)

  useEffect(() => {
    fetchCategories()

    const channel = supabase
      .channel('categories_changes')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'categories' }, fetchCategories)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'posts' }, fetchCategories) // refetch for post count updates
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  async function fetchCategories() {
    setLoading(true)
    // Fetch categories
    const { data: catData } = await supabase.from('categories').select('*').order('sort_order', { ascending: true })
    
    if (catData) {
      // Fetch post counts per category
      const { data: postData } = await supabase.from('posts').select('category_id')
      
      const counts: Record<string, number> = {}
      postData?.forEach(p => {
        if (p.category_id) counts[p.category_id] = (counts[p.category_id] || 0) + 1
      })

      const enriched = catData.map(c => ({
        ...c,
        post_count: counts[c.id] || 0
      })) as Category[]
      
      setCategories(enriched)
    }
    setLoading(false)
  }

  const startEdit = (cat: Category) => {
    setEditingId(cat.id)
    setEditName(cat.name)
    setEditDesc(cat.description || '')
    setEditIcon(cat.icon)
    setEditHidden(cat.is_hidden || false)
  }

  const saveEdit = async () => {
    if (!editingId) return
    await supabase.from('categories').update({
      name: editName,
      description: editDesc,
      icon: editIcon,
      is_hidden: editHidden
    }).eq('id', editingId)
    
    setEditingId(null)
    fetchCategories()
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Categories</h2>
          <p className="text-on-surface-variant mt-1">Manage discussion spaces, their visibility, and descriptions.</p>
        </div>
      </div>

      <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-black/[0.03] border-b border-outline-variant/30 text-on-surface-variant text-sm">
              <th className="p-4 font-semibold">Category</th>
              <th className="p-4 font-semibold">Description</th>
              <th className="p-4 font-semibold">Live Posts</th>
              <th className="p-4 font-semibold">Visibility</th>
              <th className="p-4 font-semibold text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && categories.length === 0 ? (
              <tr><td colSpan={5} className="p-10 text-center">Loading categories...</td></tr>
            ) : categories.map(cat => (
              <tr key={cat.id} className="border-b border-outline-variant/20 hover:bg-black/[0.02] transition-colors">
                <td className="p-4">
                  {editingId === cat.id ? (
                    <div className="space-y-2">
                      <input value={editName} onChange={e => setEditName(e.target.value)} className="border border-outline px-2 py-1 rounded text-sm w-full" placeholder="Name" />
                      <input value={editIcon} onChange={e => setEditIcon(e.target.value)} className="border border-outline px-2 py-1 rounded text-sm w-full" placeholder="Icon (emoji)" />
                    </div>
                  ) : (
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center text-xl">
                        {cat.icon}
                      </div>
                      <span className="font-semibold text-on-surface">{cat.name}</span>
                    </div>
                  )}
                </td>
                
                <td className="p-4 max-w-xs">
                  {editingId === cat.id ? (
                    <textarea value={editDesc} onChange={e => setEditDesc(e.target.value)} className="border border-outline px-2 py-1 rounded text-sm w-full" rows={2} placeholder="Description..." />
                  ) : (
                    <p className="text-sm text-on-surface-variant line-clamp-2">{cat.description || <span className="italic opacity-50">No description</span>}</p>
                  )}
                </td>

                <td className="p-4">
                  <span className="bg-primary/10 text-primary px-3 py-1 rounded-full text-sm font-semibold">
                    {cat.post_count?.toLocaleString()}
                  </span>
                </td>

                <td className="p-4">
                  {editingId === cat.id ? (
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input type="checkbox" checked={editHidden} onChange={e => setEditHidden(e.target.checked)} className="rounded" />
                      <span className="text-sm">Hidden</span>
                    </label>
                  ) : (
                    cat.is_hidden ? (
                      <span className="flex items-center text-xs text-red-600 bg-red-50 px-2 py-1 rounded-full w-fit">
                        <span className="material-symbols-outlined text-[14px] mr-1">visibility_off</span> Hidden
                      </span>
                    ) : (
                      <span className="flex items-center text-xs text-green-600 bg-green-50 px-2 py-1 rounded-full w-fit">
                        <span className="material-symbols-outlined text-[14px] mr-1">visibility</span> Visible
                      </span>
                    )
                  )}
                </td>

                <td className="p-4 text-right">
                  {editingId === cat.id ? (
                    <div className="flex justify-end gap-2">
                      <button onClick={saveEdit} className="text-primary hover:bg-primary/10 p-2 rounded-lg"><span className="material-symbols-outlined">save</span></button>
                      <button onClick={() => setEditingId(null)} className="text-on-surface-variant hover:bg-black/5 p-2 rounded-lg"><span className="material-symbols-outlined">close</span></button>
                    </div>
                  ) : (
                    <button onClick={() => startEdit(cat)} className="text-on-surface-variant hover:text-primary p-2 rounded-lg transition-colors">
                      <span className="material-symbols-outlined">edit</span>
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
