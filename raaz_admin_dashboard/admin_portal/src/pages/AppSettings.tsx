import { useState, useEffect, useRef } from 'react'
import { supabase } from '../lib/supabase'

type ConfigEntry = { key: string; value: string }

async function upsertConfig(key: string, value: string) {
  const { error } = await supabase
    .from('app_config')
    .upsert({ key, value, updated_at: new Date().toISOString() }, { onConflict: 'key' })
  if (error) console.error('Config upsert error:', key, error)
}

export default function AppSettings() {
  const [configs, setConfigs] = useState<ConfigEntry[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [savedMsg, setSavedMsg] = useState('')

  // Maintenance
  const [maintenanceMode, setMaintenanceMode] = useState(false)
  const [maintenanceMessage, setMaintenanceMessage] = useState('')
  const maintenanceSaveRef = useRef<ReturnType<typeof setTimeout>>()

  // App Identity
  const [appName, setAppName] = useState('RAAZ')
  const [appVersion, setAppVersion] = useState('1.0.0')
  const [supportEmail, setSupportEmail] = useState('')
  const [minAppVersion, setMinAppVersion] = useState('')
  const [forceUpdate, setForceUpdate] = useState(false)

  // Ads
  const [adsEnabled, setAdsEnabled] = useState(true)
  const [adFrequency, setAdFrequency] = useState('5')
  const [admobAndroidId, setAdmobAndroidId] = useState('')
  const [admobIosId, setAdmobIosId] = useState('')

  // Landing page copy
  const [heroHeadline, setHeroHeadline] = useState('')
  const [heroSub, setHeroSub] = useState('')

  useEffect(() => {
    fetchConfig()

    // Realtime subscription — update local state immediately when DB changes
    const channel = supabase
      .channel('app_config_admin')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'app_config' },
        (payload) => {
          const { new: row } = payload as { new: ConfigEntry }
          if (!row?.key) return
          applyRow(row.key, row.value)
          // Update raw list
          setConfigs((prev) => {
            const exists = prev.findIndex((c) => c.key === row.key)
            if (exists >= 0) {
              const updated = [...prev]
              updated[exists] = row
              return updated
            }
            return [...prev, row]
          })
        }
      )
      .subscribe()

    return () => { supabase.removeChannel(channel) }
  }, [])

  function applyRow(key: string, value: string) {
    switch (key) {
      case 'maintenance_mode': setMaintenanceMode(value === 'true'); break
      case 'maintenance_message': setMaintenanceMessage(value); break
      case 'app_name': setAppName(value); break
      case 'app_version': setAppVersion(value); break
      case 'support_email': setSupportEmail(value); break
      case 'min_app_version': setMinAppVersion(value); break
      case 'force_update': setForceUpdate(value === 'true'); break
      case 'ads_enabled': setAdsEnabled(value === 'true'); break
      case 'ad_frequency': setAdFrequency(value); break
      case 'admob_android_id': setAdmobAndroidId(value); break
      case 'admob_ios_id': setAdmobIosId(value); break
      case 'landing_hero_headline': setHeroHeadline(value); break
      case 'landing_hero_subheadline': setHeroSub(value); break
    }
  }

  async function fetchConfig() {
    setLoading(true)
    const { data, error } = await supabase.from('app_config').select('key, value')
    if (error) console.error('fetch config error', error)
    if (data) {
      setConfigs(data)
      data.forEach((item: ConfigEntry) => applyRow(item.key, item.value))
    }
    setLoading(false)
  }

  // ── Instant save for toggles ──────────────────────────────────
  async function handleMaintenanceToggle(enabled: boolean) {
    setMaintenanceMode(enabled)
    await upsertConfig('maintenance_mode', enabled.toString())
    showSaved('Maintenance mode ' + (enabled ? 'ENABLED' : 'disabled'))
  }

  async function handleForceUpdateToggle(enabled: boolean) {
    setForceUpdate(enabled)
    await upsertConfig('force_update', enabled.toString())
    showSaved('Force update ' + (enabled ? 'enabled' : 'disabled'))
  }

  async function handleAdsToggle(enabled: boolean) {
    setAdsEnabled(enabled)
    await upsertConfig('ads_enabled', enabled.toString())
    showSaved('Ads ' + (enabled ? 'enabled' : 'disabled'))
  }

  function showSaved(msg = 'Saved!') {
    setSavedMsg(msg)
    setTimeout(() => setSavedMsg(''), 3000)
  }

  // ── Save all text fields ──────────────────────────────────────
  const handleSaveAll = async () => {
    setSaving(true)
    const entries: ConfigEntry[] = [
      { key: 'maintenance_message', value: maintenanceMessage },
      { key: 'app_name', value: appName },
      { key: 'app_version', value: appVersion },
      { key: 'support_email', value: supportEmail },
      { key: 'min_app_version', value: minAppVersion },
      { key: 'ad_frequency', value: adFrequency },
      { key: 'admob_android_id', value: admobAndroidId },
      { key: 'admob_ios_id', value: admobIosId },
      { key: 'landing_hero_headline', value: heroHeadline },
      { key: 'landing_hero_subheadline', value: heroSub },
    ]
    for (const e of entries) {
      await upsertConfig(e.key, e.value)
    }
    setSaving(false)
    showSaved('All settings saved and synced to app!')
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64 text-slate-400">
        <div className="flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-indigo-600 border-t-transparent rounded-full animate-spin" />
          Loading configuration...
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6 max-w-5xl">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold text-slate-800">App Settings</h2>
          <p className="text-slate-500 mt-1 text-sm">Changes sync in real-time to all users via Supabase Realtime.</p>
        </div>
        <div className="flex items-center gap-3">
          {savedMsg && (
            <span className="text-sm text-emerald-600 font-medium bg-emerald-50 px-3 py-1.5 rounded-full border border-emerald-200">
              ✓ {savedMsg}
            </span>
          )}
          <button
            onClick={handleSaveAll}
            disabled={saving}
            className="bg-indigo-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-indigo-700 transition disabled:opacity-50 shadow flex items-center gap-2"
          >
            <span className="material-symbols-outlined text-sm">save</span>
            {saving ? 'Saving...' : 'Save Text Fields'}
          </button>
        </div>
      </div>

      {/* ── MAINTENANCE MODE ── */}
      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
        <div className="px-8 py-5 border-b border-slate-100 bg-red-50 flex items-center gap-3">
          <span className="material-symbols-outlined text-red-500">warning</span>
          <h3 className="text-lg font-semibold text-slate-800">Maintenance Mode</h3>
          <span className={`ml-auto text-xs font-bold px-2.5 py-1 rounded-full ${maintenanceMode ? 'bg-red-100 text-red-700' : 'bg-slate-100 text-slate-500'}`}>
            {maintenanceMode ? '🔴 ACTIVE' : '🟢 OFF'}
          </span>
        </div>
        <div className="p-8 space-y-6">
          <div className="flex items-center justify-between p-5 rounded-xl bg-red-50/50 border border-red-100">
            <div>
              <p className="font-semibold text-slate-800">Enable Maintenance Mode</p>
              <p className="text-slate-500 mt-1 text-sm">Instantly shows downtime screen to ALL mobile app users.</p>
            </div>
            <button
              onClick={() => handleMaintenanceToggle(!maintenanceMode)}
              className={`relative w-14 h-7 rounded-full transition-colors ${maintenanceMode ? 'bg-red-500' : 'bg-slate-300'}`}
            >
              <span className={`absolute top-0.5 left-0.5 w-6 h-6 bg-white rounded-full shadow transition-transform ${maintenanceMode ? 'translate-x-7' : 'translate-x-0'}`} />
            </button>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-2">Maintenance Message</label>
            <textarea
              rows={3}
              className="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:ring-2 focus:ring-indigo-500 outline-none"
              value={maintenanceMessage}
              onChange={(e) => setMaintenanceMessage(e.target.value)}
              placeholder="We are performing scheduled maintenance. Please check back shortly."
            />
            <p className="text-xs text-slate-400 mt-1">Save with "Save Text Fields" button above.</p>
          </div>
        </div>
      </div>

      {/* ── APP IDENTITY ── */}
      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
        <div className="px-8 py-5 border-b border-slate-100 flex items-center gap-3">
          <span className="material-symbols-outlined text-indigo-600">info</span>
          <h3 className="text-lg font-semibold text-slate-800">App Identity &amp; Versioning</h3>
        </div>
        <div className="p-8 grid grid-cols-1 md:grid-cols-2 gap-6">
          {[
            { label: 'App Display Name', value: appName, onChange: setAppName, placeholder: 'RAAZ' },
            { label: 'App Version', value: appVersion, onChange: setAppVersion, placeholder: '1.0.0' },
            { label: 'Support Email', value: supportEmail, onChange: setSupportEmail, placeholder: 'support@raazapp.com' },
            { label: 'Minimum App Version (force update)', value: minAppVersion, onChange: setMinAppVersion, placeholder: '1.0.0' },
          ].map((f) => (
            <div key={f.label}>
              <label className="block text-sm font-medium text-slate-700 mb-1">{f.label}</label>
              <input
                value={f.value}
                onChange={(e) => f.onChange(e.target.value)}
                className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm focus:ring-2 focus:ring-indigo-500 outline-none"
                placeholder={f.placeholder}
              />
            </div>
          ))}
          <div className="flex items-center justify-between p-4 rounded-xl bg-slate-50 border border-slate-200 col-span-full md:col-span-1">
            <div>
              <p className="font-semibold text-slate-800">Force Update</p>
              <p className="text-slate-500 text-sm mt-1">Block app until user updates to min version.</p>
            </div>
            <button
              onClick={() => handleForceUpdateToggle(!forceUpdate)}
              className={`relative w-14 h-7 rounded-full transition-colors ${forceUpdate ? 'bg-indigo-600' : 'bg-slate-300'}`}
            >
              <span className={`absolute top-0.5 left-0.5 w-6 h-6 bg-white rounded-full shadow transition-transform ${forceUpdate ? 'translate-x-7' : 'translate-x-0'}`} />
            </button>
          </div>
        </div>
      </div>

      {/* ── ADS ── */}
      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
        <div className="px-8 py-5 border-b border-slate-100 flex items-center gap-3">
          <span className="material-symbols-outlined text-amber-500">campaign</span>
          <h3 className="text-lg font-semibold text-slate-800">AdMob / Ads</h3>
        </div>
        <div className="p-8 space-y-6">
          <div className="flex items-center justify-between p-4 rounded-xl bg-slate-50 border border-slate-200">
            <div>
              <p className="font-semibold text-slate-800">Ads Enabled</p>
              <p className="text-slate-500 text-sm mt-1">Show banner ads in the feed. Syncs instantly.</p>
            </div>
            <button
              onClick={() => handleAdsToggle(!adsEnabled)}
              className={`relative w-14 h-7 rounded-full transition-colors ${adsEnabled ? 'bg-indigo-600' : 'bg-slate-300'}`}
            >
              <span className={`absolute top-0.5 left-0.5 w-6 h-6 bg-white rounded-full shadow transition-transform ${adsEnabled ? 'translate-x-7' : 'translate-x-0'}`} />
            </button>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {[
              { label: 'Ad Frequency (every N posts)', value: adFrequency, onChange: setAdFrequency, placeholder: '5' },
              { label: 'AdMob Android Unit ID', value: admobAndroidId, onChange: setAdmobAndroidId, placeholder: 'ca-app-pub-xxx/yyy' },
              { label: 'AdMob iOS Unit ID', value: admobIosId, onChange: setAdmobIosId, placeholder: 'ca-app-pub-xxx/yyy' },
            ].map((f) => (
              <div key={f.label}>
                <label className="block text-sm font-medium text-slate-700 mb-1">{f.label}</label>
                <input
                  value={f.value}
                  onChange={(e) => f.onChange(e.target.value)}
                  className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm focus:ring-2 focus:ring-indigo-500 outline-none font-mono"
                  placeholder={f.placeholder}
                />
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* ── LANDING PAGE COPY ── */}
      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
        <div className="px-8 py-5 border-b border-slate-100 flex items-center gap-3">
          <span className="material-symbols-outlined text-violet-600">language</span>
          <h3 className="text-lg font-semibold text-slate-800">Landing Page Copy</h3>
        </div>
        <div className="p-8 space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Hero Headline</label>
            <input
              value={heroHeadline}
              onChange={(e) => setHeroHeadline(e.target.value)}
              className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm focus:ring-2 focus:ring-indigo-500 outline-none"
              placeholder="Share Secrets. Stay 100% Anonymous."
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Hero Subheadline</label>
            <textarea
              rows={2}
              value={heroSub}
              onChange={(e) => setHeroSub(e.target.value)}
              className="w-full rounded-xl border border-slate-200 px-4 py-2.5 text-sm focus:ring-2 focus:ring-indigo-500 outline-none"
              placeholder="The premier anonymous confession and support network..."
            />
          </div>
        </div>
      </div>

      {/* ── RAW CONFIG VIEWER ── */}
      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
        <div className="px-8 py-5 border-b border-slate-100 flex items-center gap-3">
          <span className="material-symbols-outlined text-slate-400">data_object</span>
          <h3 className="text-lg font-semibold text-slate-800">All Config Keys (Live)</h3>
        </div>
        <div className="p-8">
          <div className="bg-slate-950 rounded-xl p-5 overflow-x-auto">
            <table className="w-full text-left text-sm font-mono">
              <thead>
                <tr className="text-slate-500 border-b border-slate-700">
                  <th className="pb-2 pr-8">Key</th>
                  <th className="pb-2">Value</th>
                </tr>
              </thead>
              <tbody>
                {configs.map((c) => (
                  <tr key={c.key} className="border-b border-slate-800">
                    <td className="py-2 pr-8 text-indigo-400 font-semibold">{c.key}</td>
                    <td className="py-2 text-emerald-400">{c.value}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  )
}
