import { useState } from 'react'
import { supabase } from '../lib/supabase'

export default function PushNotifications() {
  const [title, setTitle] = useState('')
  const [message, setMessage] = useState('')
  const [sending, setSending] = useState(false)
  
  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!title || !message) return
    
    setSending(true)
    
    // Insert into global_notifications (Flutter app should listen to this table via Realtime)
    const { error } = await supabase.from('global_notifications').insert({
      title,
      message
    })

    setSending(false)

    if (error) {
      alert(`Error sending notification: ${error.message}`)
    } else {
      setTitle('')
      setMessage('')
      alert('Push notification dispatched globally! All connected users will receive it instantly.')
    }
  }

  return (
    <div>
      <div className="mb-8">
        <h2 className="text-3xl font-bold text-on-surface">Push Notifications</h2>
        <p className="text-on-surface-variant mt-2">Send global announcements to all users.</p>
      </div>

      <div className="glass-panel p-8 rounded-2xl border border-outline-variant shadow-sm max-w-2xl">
        <h3 className="text-xl font-semibold text-on-surface flex items-center mb-6">
          <span className="material-symbols-outlined text-primary mr-3">campaign</span>
          Compose Notification
        </h3>
        
        <form onSubmit={handleSend} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-on-surface mb-1">Notification Title</label>
            <input 
              required
              value={title}
              onChange={e => setTitle(e.target.value)}
              className="w-full rounded-xl border border-outline px-4 py-3 bg-surface focus:ring-2 focus:ring-primary focus:outline-none" 
              placeholder="e.g. Big Update is Here!" 
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-on-surface mb-1">Message</label>
            <textarea 
              required
              rows={4}
              value={message}
              onChange={e => setMessage(e.target.value)}
              className="w-full rounded-xl border border-outline px-4 py-3 bg-surface focus:ring-2 focus:ring-primary focus:outline-none" 
              placeholder="Enter the notification body..." 
            />
          </div>
          
          <div className="pt-4 flex justify-end">
            <button 
              type="submit" 
              disabled={sending}
              className="bg-primary text-white px-8 py-3 rounded-xl font-medium hover:opacity-90 transition-opacity disabled:opacity-50 flex items-center shadow-md"
            >
              <span className="material-symbols-outlined mr-2">send</span>
              {sending ? 'Sending...' : 'Send to All Users'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
