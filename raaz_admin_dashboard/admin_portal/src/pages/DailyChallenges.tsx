import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function DailyChallenges() {
  const [challenges, setChallenges] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [isAdding, setIsAdding] = useState(false)
  const [newTitle, setNewTitle] = useState('')
  const [newDesc, setNewDesc] = useState('')
  const [newDate, setNewDate] = useState('')

  useEffect(() => {
    fetchChallenges()
  }, [])

  async function fetchChallenges() {
    setLoading(true)
    const { data, error } = await supabase
      .from('daily_challenges')
      .select('*')
      .order('date', { ascending: false })
      
    if (!error && data) {
      setChallenges(data)
    }
    setLoading(false)
  }

  const handleAddChallenge = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newTitle || !newDate) return

    const { error } = await supabase
      .from('daily_challenges')
      .insert([{ 
        title: newTitle, 
        description: newDesc, 
        date: newDate,
        is_active: true
      }])

    if (!error) {
      setNewTitle('')
      setNewDesc('')
      setNewDate('')
      setIsAdding(false)
      fetchChallenges()
    } else {
      alert('Failed to add challenge: ' + error.message)
    }
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Daily Challenges</h2>
          <p className="text-on-surface-variant mt-2">Manage daily writing prompts and reflections.</p>
        </div>
        <button 
          onClick={() => setIsAdding(!isAdding)}
          className="bg-primary text-white px-4 py-2 rounded-xl font-medium hover:opacity-90 transition-opacity flex items-center shadow-sm"
        >
          <span className="material-symbols-outlined mr-2">{isAdding ? 'close' : 'add'}</span>
          {isAdding ? 'Cancel' : 'New Challenge'}
        </button>
      </div>

      {isAdding && (
        <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm mb-6 animate-in fade-in slide-in-from-top-4">
          <h3 className="font-semibold text-lg mb-4">Create New Challenge</h3>
          <form onSubmit={handleAddChallenge} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-on-surface mb-1">Date</label>
              <input 
                type="date"
                required
                value={newDate}
                onChange={e => setNewDate(e.target.value)}
                className="w-full rounded-xl border border-outline px-4 py-2 bg-surface focus:ring-2 focus:ring-primary focus:outline-none" 
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-on-surface mb-1">Title / Prompt</label>
              <input 
                required
                value={newTitle}
                onChange={e => setNewTitle(e.target.value)}
                className="w-full rounded-xl border border-outline px-4 py-2 bg-surface focus:ring-2 focus:ring-primary focus:outline-none" 
                placeholder="e.g. Share a childhood memory..." 
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-on-surface mb-1">Description (Optional)</label>
              <textarea 
                value={newDesc}
                onChange={e => setNewDesc(e.target.value)}
                className="w-full rounded-xl border border-outline px-4 py-2 bg-surface focus:ring-2 focus:ring-primary focus:outline-none" 
                placeholder="Detailed instructions or thoughts..." 
                rows={3}
              />
            </div>
            <button type="submit" className="bg-primary text-white px-6 py-2 rounded-xl font-medium hover:opacity-90">
              Save Challenge
            </button>
          </form>
        </div>
      )}

      <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-black/5 border-b border-outline-variant/30 text-on-surface-variant text-sm">
              <th className="p-4 font-semibold">Date</th>
              <th className="p-4 font-semibold">Prompt</th>
              <th className="p-4 font-semibold">Status</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={3} className="p-8 text-center text-on-surface-variant">Loading...</td>
              </tr>
            ) : challenges.length === 0 ? (
              <tr>
                <td colSpan={3} className="p-8 text-center text-on-surface-variant">No challenges found.</td>
              </tr>
            ) : (
              challenges.map(challenge => (
                <tr key={challenge.id} className="border-b border-outline-variant/30 hover:bg-black/5">
                  <td className="p-4 whitespace-nowrap font-medium text-on-surface">
                    {new Date(challenge.date).toLocaleDateString()}
                  </td>
                  <td className="p-4">
                    <div className="font-semibold text-on-surface">{challenge.title}</div>
                    <div className="text-sm text-on-surface-variant mt-1">{challenge.description}</div>
                  </td>
                  <td className="p-4">
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${challenge.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-700'}`}>
                      {challenge.is_active ? 'Active' : 'Inactive'}
                    </span>
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
