import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function AppSettings() {
  const [maintenanceMode, setMaintenanceMode] = useState<boolean>(false)
  const [maintenanceMessage, setMaintenanceMessage] = useState<string>('')
  const [loading, setLoading] = useState<boolean>(true)
  const [saving, setSaving] = useState<boolean>(false)

  // Fetch initial config
  useEffect(() => {
    async function fetchConfig() {
      setLoading(true)
      const { data, error } = await supabase
        .from('app_config')
        .select('key, value')
      
      if (!error && data) {
        const mode = data.find(c => c.key === 'maintenance_mode')
        const msg = data.find(c => c.key === 'maintenance_message')
        
        if (mode) setMaintenanceMode(mode.value === 'true')
        if (msg) setMaintenanceMessage(msg.value)
      }
      setLoading(false)
    }

    fetchConfig()
  }, [])

  const handleSave = async () => {
    setSaving(true)
    
    // Upsert maintenance_mode
    await supabase.from('app_config').upsert({
      key: 'maintenance_mode',
      value: maintenanceMode ? 'true' : 'false'
    }, { onConflict: 'key' })
    
    // Upsert maintenance_message
    await supabase.from('app_config').upsert({
      key: 'maintenance_message',
      value: maintenanceMessage
    }, { onConflict: 'key' })
    
    setSaving(false)
    alert('Settings saved successfully!')
  }

  if (loading) {
    return <div className="p-8 text-on-surface-variant">Loading configuration...</div>
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Configuration Dashboard</h2>
          <p className="text-on-surface-variant mt-2">Manage global application parameters and settings.</p>
        </div>
        <button 
          onClick={handleSave}
          disabled={saving}
          className="bg-primary text-white px-6 py-3 rounded-xl font-medium hover:opacity-90 transition-opacity disabled:opacity-50 shadow-md"
        >
          {saving ? 'Saving...' : 'Save Changes'}
        </button>
      </div>

      <div className="glass-panel p-8 rounded-2xl border border-outline-variant shadow-sm mb-8">
        <h3 className="text-xl font-semibold text-on-surface flex items-center mb-6">
          <span className="material-symbols-outlined text-primary mr-3">tune</span>
          General Application Settings
        </h3>
        
        <div className="space-y-8">
          {/* Maintenance Mode Toggle */}
          <div className="flex items-center justify-between p-6 rounded-xl bg-black/5 border border-outline-variant/30">
            <div>
              <p className="font-semibold text-lg text-on-surface">Maintenance Mode</p>
              <p className="text-on-surface-variant mt-1 text-sm">Redirect all users to a technical downtime page during updates.</p>
            </div>
            
            {/* Simple CSS Toggle Switch */}
            <label className="relative inline-flex items-center cursor-pointer">
              <input 
                type="checkbox" 
                className="sr-only peer"
                checked={maintenanceMode}
                onChange={(e) => setMaintenanceMode(e.target.checked)}
              />
              <div className="w-14 h-7 bg-outline-variant rounded-full peer peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-0.5 after:left-[4px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-primary"></div>
            </label>
          </div>

          {/* Maintenance Message */}
          <div className="p-6 rounded-xl bg-black/5 border border-outline-variant/30">
            <label className="block font-semibold text-lg text-on-surface mb-2">Maintenance Message</label>
            <p className="text-on-surface-variant text-sm mb-4">The message displayed to users when maintenance mode is active.</p>
            <textarea
              rows={3}
              className="w-full rounded-xl border border-outline px-4 py-3 bg-surface focus:ring-2 focus:ring-primary focus:outline-none"
              value={maintenanceMessage}
              onChange={(e) => setMaintenanceMessage(e.target.value)}
              placeholder="We are currently down for maintenance. Please check back later."
            />
          </div>
        </div>
      </div>
    </div>
  )
}
