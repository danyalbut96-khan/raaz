import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

type ConfigEntry = { key: string; value: string }

export default function AppSettings() {
  const [configs, setConfigs] = useState<ConfigEntry[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)

  // Maintenance
  const [maintenanceMode, setMaintenanceMode] = useState(false)
  const [maintenanceMessage, setMaintenanceMessage] = useState('')

  // App Identity
  const [appName, setAppName] = useState('')
  const [supportEmail, setSupportEmail] = useState('')
  const [minAppVersion, setMinAppVersion] = useState('')
  const [forceUpdate, setForceUpdate] = useState(false)

  useEffect(() => {
    fetchConfig()

    const channel = supabase
      .channel('app_config_changes')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'app_config' }, fetchConfig)
      .subscribe()

    return () => { supabase.removeChannel(channel) }
  }, [])

  async function fetchConfig() {
    setLoading(true)
    const { data } = await supabase.from('app_config').select('key, value')

    if (data) {
      setConfigs(data)
      data.forEach(item => {
        switch (item.key) {
          case 'maintenance_mode': setMaintenanceMode(item.value === 'true'); break
          case 'maintenance_message': setMaintenanceMessage(item.value); break
          case 'app_name': setAppName(item.value); break
          case 'support_email': setSupportEmail(item.value); break
          case 'min_app_version': setMinAppVersion(item.value); break
          case 'force_update': setForceUpdate(item.value === 'true'); break
        }
      })
    }
    setLoading(false)
  }

  const handleSave = async () => {
    setSaving(true)

    const settings: ConfigEntry[] = [
      { key: 'maintenance_mode', value: maintenanceMode.toString() },
      { key: 'maintenance_message', value: maintenanceMessage },
      { key: 'app_name', value: appName },
      { key: 'support_email', value: supportEmail },
      { key: 'min_app_version', value: minAppVersion },
      { key: 'force_update', value: forceUpdate.toString() },
    ]

    for (const s of settings) {
      await supabase.from('app_config').upsert(s, { onConflict: 'key' })
    }

    setSaving(false)
    alert('All settings saved successfully!')
  }

  if (loading) {
    return <div className="p-8 text-on-surface-variant">Loading configuration...</div>
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">App Settings</h2>
          <p className="text-on-surface-variant mt-1">Global application configuration synced in real-time to all users.</p>
        </div>
        <button
          onClick={handleSave}
          disabled={saving}
          className="bg-primary text-white px-6 py-3 rounded-xl font-medium hover:opacity-90 transition-opacity disabled:opacity-50 shadow-md flex items-center"
        >
          <span className="material-symbols-outlined mr-2">save</span>
          {saving ? 'Saving...' : 'Save All Changes'}
        </button>
      </div>

      {/* Maintenance Mode Section */}
      <div className="glass-panel p-8 rounded-2xl border border-outline-variant shadow-sm">
        <h3 className="text-xl font-semibold text-on-surface flex items-center mb-6 pb-4 border-b border-outline-variant/30">
          <span className="material-symbols-outlined text-red-500 mr-3">warning</span>
          Maintenance Mode
        </h3>

        <div className="space-y-6">
          <div className="flex items-center justify-between p-5 rounded-xl bg-red-500/5 border border-red-500/20">
            <div>
              <p className="font-semibold text-lg text-on-surface">Enable Maintenance Mode</p>
              <p className="text-on-surface-variant mt-1 text-sm">When active, the mobile app will display a downtime screen to all users.</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                className="sr-only peer"
                checked={maintenanceMode}
                onChange={(e) => setMaintenanceMode(e.target.checked)}
              />
              <div className="w-14 h-7 bg-outline-variant rounded-full peer peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-0.5 after:left-[4px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-red-500"></div>
            </label>
          </div>

          <div className="p-5 rounded-xl bg-black/5 border border-outline-variant/30">
            <label className="block font-semibold text-on-surface mb-2">Maintenance Message</label>
            <p className="text-on-surface-variant text-sm mb-3">The message shown to users during downtime.</p>
            <textarea
              rows={3}
              className="w-full rounded-xl border border-outline px-4 py-3 bg-surface focus:ring-2 focus:ring-primary focus:outline-none"
              value={maintenanceMessage}
              onChange={(e) => setMaintenanceMessage(e.target.value)}
              placeholder="We are performing scheduled maintenance. Please check back shortly."
            />
          </div>
        </div>
      </div>

      {/* App Identity Section */}
      <div className="glass-panel p-8 rounded-2xl border border-outline-variant shadow-sm">
        <h3 className="text-xl font-semibold text-on-surface flex items-center mb-6 pb-4 border-b border-outline-variant/30">
          <span className="material-symbols-outlined text-primary mr-3">info</span>
          App Identity &amp; Versioning
        </h3>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-on-surface mb-1">App Display Name</label>
            <input
              value={appName}
              onChange={e => setAppName(e.target.value)}
              className="w-full rounded-xl border border-outline px-4 py-3 bg-surface focus:ring-2 focus:ring-primary focus:outline-none"
              placeholder="Raaz"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-on-surface mb-1">Support Email</label>
            <input
              type="email"
              value={supportEmail}
              onChange={e => setSupportEmail(e.target.value)}
              className="w-full rounded-xl border border-outline px-4 py-3 bg-surface focus:ring-2 focus:ring-primary focus:outline-none"
              placeholder="support@raazapp.com"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-on-surface mb-1">Minimum App Version</label>
            <p className="text-xs text-on-surface-variant mb-2">Users below this version will see an update prompt.</p>
            <input
              value={minAppVersion}
              onChange={e => setMinAppVersion(e.target.value)}
              className="w-full rounded-xl border border-outline px-4 py-3 bg-surface focus:ring-2 focus:ring-primary focus:outline-none"
              placeholder="1.0.0"
            />
          </div>
          <div className="flex items-center p-5 rounded-xl bg-black/5 border border-outline-variant/30">
            <div className="flex-1">
              <p className="font-semibold text-on-surface">Force Update</p>
              <p className="text-on-surface-variant text-sm mt-1">Block app access until the user updates to the minimum version.</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                className="sr-only peer"
                checked={forceUpdate}
                onChange={(e) => setForceUpdate(e.target.checked)}
              />
              <div className="w-14 h-7 bg-outline-variant rounded-full peer peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-0.5 after:left-[4px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-primary"></div>
            </label>
          </div>
        </div>
      </div>

      {/* Raw Config Viewer */}
      <div className="glass-panel p-8 rounded-2xl border border-outline-variant shadow-sm">
        <h3 className="text-xl font-semibold text-on-surface flex items-center mb-6 pb-4 border-b border-outline-variant/30">
          <span className="material-symbols-outlined text-on-surface-variant mr-3">data_object</span>
          All Config Keys (Raw)
        </h3>
        <div className="bg-black/5 rounded-xl p-4 overflow-x-auto">
          <table className="w-full text-left text-sm font-mono">
            <thead>
              <tr className="text-on-surface-variant border-b border-outline-variant/30">
                <th className="pb-2 pr-6">Key</th>
                <th className="pb-2">Value</th>
              </tr>
            </thead>
            <tbody>
              {configs.map(c => (
                <tr key={c.key} className="border-b border-outline-variant/10">
                  <td className="py-2 pr-6 text-primary font-semibold">{c.key}</td>
                  <td className="py-2 text-on-surface">{c.value}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
