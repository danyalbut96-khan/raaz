import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

type Challenge = {
  id: number
  title: string
  description: string
  date: string
  xp_reward: number
  difficulty: 'easy' | 'medium' | 'hard'
  is_active: boolean
  completions?: number
}

export default function DailyChallenges() {
  const [challenges, setChallenges] = useState<Challenge[]>([])
  const [loading, setLoading] = useState(true)
  const [isModalOpen, setIsModalOpen] = useState(false)
  
  // Form State
  const [editId, setEditId] = useState<number | null>(null)
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [date, setDate] = useState('')
  const [xp, setXp] = useState(50)
  const [difficulty, setDifficulty] = useState<'easy'|'medium'|'hard'>('easy')
  const [isActive, setIsActive] = useState(true)

  useEffect(() => {
    fetchChallenges()
    const channel = supabase
      .channel('challenges_changes')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'daily_challenges' }, fetchChallenges)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'user_challenges' }, fetchChallenges)
      .subscribe()
    return () => { supabase.removeChannel(channel) }
  }, [])

  async function fetchChallenges() {
    setLoading(true)
    const { data } = await supabase.from('daily_challenges').select('*').order('date', { ascending: false })
    
    if (data) {
      // Fetch completions
      const { data: compData } = await supabase.from('user_challenges').select('challenge_title')
      const counts: Record<string, number> = {}
      compData?.forEach(c => counts[c.challenge_title] = (counts[c.challenge_title] || 0) + 1)
      
      const enriched = data.map(d => ({
        ...d,
        completions: counts[d.title] || 0
      })) as Challenge[]
      setChallenges(enriched)
    }
    setLoading(false)
  }

  const openNew = () => {
    setEditId(null)
    setTitle('')
    setDescription('')
    setDate(new Date().toISOString().split('T')[0])
    setXp(50)
    setDifficulty('easy')
    setIsActive(true)
    setIsModalOpen(true)
  }

  const openEdit = (c: Challenge) => {
    setEditId(c.id)
    setTitle(c.title)
    setDescription(c.description)
    setDate(c.date)
    setXp(c.xp_reward)
    setDifficulty(c.difficulty)
    setIsActive(c.is_active)
    setIsModalOpen(true)
  }

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    const payload = { title, description, date, xp_reward: xp, difficulty, is_active: isActive }
    
    if (editId) {
      await supabase.from('daily_challenges').update(payload).eq('id', editId)
    } else {
      await supabase.from('daily_challenges').insert([payload])
    }
    setIsModalOpen(false)
    fetchChallenges()
  }

  const difficultyColors = {
    easy: 'bg-green-100 text-green-700',
    medium: 'bg-yellow-100 text-yellow-700',
    hard: 'bg-red-100 text-red-700'
  }

  return (
    <div className="space-y-6 relative">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Daily Challenges</h2>
          <p className="text-on-surface-variant mt-1">Create and manage daily engagement tasks for users.</p>
        </div>
        <button onClick={openNew} className="bg-primary text-white px-5 py-2.5 rounded-xl font-medium shadow-md flex items-center hover:opacity-90">
          <span className="material-symbols-outlined mr-2">add</span> New Challenge
        </button>
      </div>

      <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-black/[0.03] border-b border-outline-variant/30 text-on-surface-variant text-sm">
              <th className="p-4 font-semibold">Date</th>
              <th className="p-4 font-semibold">Challenge</th>
              <th className="p-4 font-semibold">Difficulty / XP</th>
              <th className="p-4 font-semibold text-center">Completions</th>
              <th className="p-4 font-semibold text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && challenges.length === 0 ? (
              <tr><td colSpan={5} className="p-10 text-center">Loading challenges...</td></tr>
            ) : challenges.map(c => (
              <tr key={c.id} className={`border-b border-outline-variant/20 hover:bg-black/[0.02] transition-colors ${!c.is_active ? 'opacity-50' : ''}`}>
                <td className="p-4 whitespace-nowrap text-sm font-medium">{c.date}</td>
                <td className="p-4 max-w-sm">
                  <p className="font-semibold text-on-surface">{c.title}</p>
                  <p className="text-sm text-on-surface-variant line-clamp-1">{c.description}</p>
                </td>
                <td className="p-4">
                  <div className="flex gap-2 items-center">
                    <span className={`text-xs font-semibold px-2 py-1 rounded-full uppercase ${difficultyColors[c.difficulty]}`}>
                      {c.difficulty}
                    </span>
                    <span className="text-sm font-bold text-amber-500">+{c.xp_reward} XP</span>
                  </div>
                </td>
                <td className="p-4 text-center">
                  <span className="inline-flex items-center justify-center bg-primary/10 text-primary w-8 h-8 rounded-full font-bold text-sm">
                    {c.completions}
                  </span>
                </td>
                <td className="p-4 text-right">
                  <button onClick={() => openEdit(c)} className="p-2 text-on-surface-variant hover:text-primary transition-colors">
                    <span className="material-symbols-outlined">edit</span>
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
          <div className="bg-surface rounded-2xl p-6 w-full max-w-lg shadow-xl">
            <h3 className="text-xl font-bold mb-4">{editId ? 'Edit Challenge' : 'New Challenge'}</h3>
            <form onSubmit={handleSave} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Title</label>
                <input required value={title} onChange={e=>setTitle(e.target.value)} className="w-full border rounded-lg p-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Description</label>
                <textarea required rows={3} value={description} onChange={e=>setDescription(e.target.value)} className="w-full border rounded-lg p-2" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Date</label>
                  <input type="date" required value={date} onChange={e=>setDate(e.target.value)} className="w-full border rounded-lg p-2" />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">XP Reward</label>
                  <input type="number" required value={xp} onChange={e=>setXp(parseInt(e.target.value))} className="w-full border rounded-lg p-2" />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Difficulty</label>
                  <select value={difficulty} onChange={e=>setDifficulty(e.target.value as any)} className="w-full border rounded-lg p-2 bg-white">
                    <option value="easy">Easy</option>
                    <option value="medium">Medium</option>
                    <option value="hard">Hard</option>
                  </select>
                </div>
                <div className="flex items-center mt-6">
                  <label className="flex items-center cursor-pointer">
                    <input type="checkbox" checked={isActive} onChange={e=>setIsActive(e.target.checked)} className="mr-2 rounded" />
                    <span className="text-sm font-medium">Active</span>
                  </label>
                </div>
              </div>
              <div className="flex justify-end gap-2 pt-4">
                <button type="button" onClick={() => setIsModalOpen(false)} className="px-4 py-2 rounded-lg bg-black/5 hover:bg-black/10">Cancel</button>
                <button type="submit" className="px-4 py-2 rounded-lg bg-primary text-white hover:opacity-90">Save</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
