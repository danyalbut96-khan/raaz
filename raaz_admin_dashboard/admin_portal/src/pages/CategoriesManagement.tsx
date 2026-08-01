import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function CategoriesManagement() {
  const [categories, setCategories] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [isAdding, setIsAdding] = useState(false)
  const [newCatName, setNewCatName] = useState('')
  const [newCatDesc, setNewCatDesc] = useState('')

  useEffect(() => {
    fetchCategories()
  }, [])

  async function fetchCategories() {
    setLoading(true)
    const { data, error } = await supabase
      .from('categories')
      .select('*')
      .order('created_at', { ascending: false })
      
    if (!error && data) {
      setCategories(data)
    }
    setLoading(false)
  }

  const handleAddCategory = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newCatName) return

    const { error } = await supabase
      .from('categories')
      .insert([{ 
        name: newCatName, 
        description: newCatDesc, 
        is_active: true,
        icon_url: 'forum' // Default icon
      }])

    if (!error) {
      setNewCatName('')
      setNewCatDesc('')
      setIsAdding(false)
      fetchCategories()
    } else {
      alert('Failed to add category: ' + error.message)
    }
  }

  const toggleStatus = async (id: string, currentStatus: boolean) => {
    const { error } = await supabase
      .from('categories')
      .update({ is_active: !currentStatus })
      .eq('id', id)

    if (!error) {
      setCategories(categories.map(c => 
        c.id === id ? { ...c, is_active: !currentStatus } : c
      ))
    }
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Categories Management</h2>
          <p className="text-on-surface-variant mt-2">Manage confession categories and topics.</p>
        </div>
        <button 
          onClick={() => setIsAdding(!isAdding)}
          className="bg-primary text-white px-4 py-2 rounded-xl font-medium hover:opacity-90 transition-opacity flex items-center shadow-sm"
        >
          <span className="material-symbols-outlined mr-2">{isAdding ? 'close' : 'add'}</span>
          {isAdding ? 'Cancel' : 'Add Category'}
        </button>
      </div>

      {isAdding && (
        <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm mb-6 animate-in fade-in slide-in-from-top-4">
          <h3 className="font-semibold text-lg mb-4">Create New Category</h3>
          <form onSubmit={handleAddCategory} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-on-surface mb-1">Name</label>
              <input 
                required
                value={newCatName}
                onChange={e => setNewCatName(e.target.value)}
                className="w-full rounded-xl border border-outline px-4 py-2 bg-surface focus:ring-2 focus:ring-primary focus:outline-none" 
                placeholder="e.g. Work Life" 
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-on-surface mb-1">Description</label>
              <input 
                value={newCatDesc}
                onChange={e => setNewCatDesc(e.target.value)}
                className="w-full rounded-xl border border-outline px-4 py-2 bg-surface focus:ring-2 focus:ring-primary focus:outline-none" 
                placeholder="e.g. Confessions from the office..." 
              />
            </div>
            <button type="submit" className="bg-primary text-white px-6 py-2 rounded-xl font-medium hover:opacity-90">
              Save Category
            </button>
          </form>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {loading ? (
          <div className="col-span-full text-center p-8 text-on-surface-variant">Loading categories...</div>
        ) : categories.length === 0 ? (
          <div className="col-span-full text-center p-8 text-on-surface-variant">No categories found.</div>
        ) : (
          categories.map(category => (
            <div key={category.id} className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm flex flex-col">
              <div className="flex justify-between items-start mb-4">
                <div className="flex items-center">
                  <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary mr-3">
                    <span className="material-symbols-outlined">{category.icon_url || 'forum'}</span>
                  </div>
                  <h3 className="font-bold text-lg text-on-surface">{category.name}</h3>
                </div>
                <button 
                  onClick={() => toggleStatus(category.id, category.is_active)}
                  className={`px-3 py-1 rounded-full text-xs font-medium ${
                    category.is_active 
                      ? 'bg-green-100 text-green-700 hover:bg-red-100 hover:text-red-700' 
                      : 'bg-red-100 text-red-700 hover:bg-green-100 hover:text-green-700'
                  } transition-colors`}
                >
                  {category.is_active ? 'Active' : 'Hidden'}
                </button>
              </div>
              <p className="text-on-surface-variant text-sm flex-1">{category.description || 'No description provided.'}</p>
              <div className="mt-4 pt-4 border-t border-outline-variant/30 text-xs text-on-surface-variant flex justify-between">
                <span>Created {new Date(category.created_at).toLocaleDateString()}</span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  )
}
