import { useState } from 'react'
import { supabase } from '../lib/supabase'

export default function ContactUs() {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [subject, setSubject] = useState('')
  const [message, setMessage] = useState('')
  const [sent, setSent] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    const { error } = await supabase.from('contact_messages').insert([{ name, email, subject, message }])
    if (!error) setSent(true)
  }

  if (sent) return <div className="py-24 text-center text-2xl font-bold">Message Sent! We will get back to you soon.</div>

  return (
    <div className="py-24 px-6 max-w-2xl mx-auto">
      <h1 className="text-5xl font-bold mb-8 text-center">Contact Us</h1>
      <form onSubmit={handleSubmit} className="space-y-6 bg-surface p-8 rounded-2xl border border-outline-variant/30">
        <div><label className="block mb-2 font-medium">Name</label><input required className="w-full p-3 rounded-xl border border-outline" value={name} onChange={e=>setName(e.target.value)} /></div>
        <div><label className="block mb-2 font-medium">Email</label><input required type="email" className="w-full p-3 rounded-xl border border-outline" value={email} onChange={e=>setEmail(e.target.value)} /></div>
        <div><label className="block mb-2 font-medium">Subject</label><input required className="w-full p-3 rounded-xl border border-outline" value={subject} onChange={e=>setSubject(e.target.value)} /></div>
        <div><label className="block mb-2 font-medium">Message</label><textarea required rows={5} className="w-full p-3 rounded-xl border border-outline" value={message} onChange={e=>setMessage(e.target.value)} /></div>
        <button type="submit" className="w-full bg-primary text-white p-3 rounded-xl font-bold">Send Message</button>
      </form>
    </div>
  )
}
