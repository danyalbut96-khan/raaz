import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function AdsManagement() {
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  
  const [adsEnabled, setAdsEnabled] = useState(false)
  const [adFrequency, setAdFrequency] = useState(5)
  const [admobAndroid, setAdmobAndroid] = useState('')
  const [admobIos, setAdmobIos] = useState('')
  const [unityId, setUnityId] = useState('')

  useEffect(() => {
    async function fetchAdsConfig() {
      setLoading(true)
      const { data } = await supabase.from('app_config').select('key, value')
      if (data) {
        data.forEach(item => {
          if (item.key === 'ads_enabled') setAdsEnabled(item.value === 'true')
          if (item.key === 'ad_frequency') setAdFrequency(parseInt(item.value, 10) || 5)
          if (item.key === 'admob_android_id') setAdmobAndroid(item.value)
          if (item.key === 'admob_ios_id') setAdmobIos(item.value)
          if (item.key === 'unity_ad_id') setUnityId(item.value)
        })
      }
      setLoading(false)
    }
    fetchAdsConfig()
  }, [])

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)
    
    const settings = [
      { key: 'ads_enabled', value: adsEnabled.toString() },
      { key: 'ad_frequency', value: adFrequency.toString() },
      { key: 'admob_android_id', value: admobAndroid },
      { key: 'admob_ios_id', value: admobIos },
      { key: 'unity_ad_id', value: unityId }
    ]

    for (const setting of settings) {
      await supabase.from('app_config').upsert(setting, { onConflict: 'key' })
    }

    setSaving(false)
    alert('Ad settings saved! The mobile app will sync these values in real-time.')
  }

  if (loading) return <div className="p-8 text-on-surface-variant">Loading ad configuration...</div>

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Ads Manager</h2>
          <p className="text-on-surface-variant mt-2">Configure mobile ad network IDs and placement frequency.</p>
        </div>
      </div>

      <form onSubmit={handleSave} className="glass-panel p-8 rounded-2xl border border-outline-variant shadow-sm max-w-3xl">
        <h3 className="text-xl font-semibold text-on-surface flex items-center mb-6 border-b border-outline-variant/30 pb-4">
          <span className="material-symbols-outlined text-primary mr-3">attach_money</span>
          Monetization Settings
        </h3>
        
        <div className="space-y-6">
          {/* Master Toggle */}
          <div className="flex items-center justify-between p-4 bg-primary/5 border border-primary/20 rounded-xl">
            <div>
              <p className="font-semibold text-lg text-on-surface">Enable Advertisements</p>
              <p className="text-on-surface-variant text-sm mt-1">Master switch to turn all ads on or off globally.</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" className="sr-only peer" checked={adsEnabled} onChange={(e) => setAdsEnabled(e.target.checked)} />
              <div className="w-14 h-7 bg-outline-variant rounded-full peer peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-0.5 after:left-[4px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-primary"></div>
            </label>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-on-surface mb-1">AdMob App ID (Android)</label>
              <input value={admobAndroid} onChange={e => setAdmobAndroid(e.target.value)} placeholder="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy" className="w-full rounded-xl border border-outline px-4 py-3 bg-surface focus:ring-2 focus:ring-primary focus:outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-on-surface mb-1">AdMob App ID (iOS)</label>
              <input value={admobIos} onChange={e => setAdmobIos(e.target.value)} placeholder="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy" className="w-full rounded-xl border border-outline px-4 py-3 bg-surface focus:ring-2 focus:ring-primary focus:outline-none" />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-on-surface mb-1">Unity Ads Game ID</label>
              <input value={unityId} onChange={e => setUnityId(e.target.value)} placeholder="e.g. 1234567" className="w-full rounded-xl border border-outline px-4 py-3 bg-surface focus:ring-2 focus:ring-primary focus:outline-none" />
            </div>
          </div>

          <div className="pt-4 border-t border-outline-variant/30">
            <label className="block text-sm font-medium text-on-surface mb-2">Ad Frequency (In-Feed)</label>
            <p className="text-on-surface-variant text-sm mb-4">Show an advertisement after every X posts.</p>
            <div className="flex items-center gap-4">
              <input type="range" min="1" max="15" value={adFrequency} onChange={e => setAdFrequency(parseInt(e.target.value))} className="flex-1 accent-primary" />
              <div className="bg-black/5 px-4 py-2 rounded-lg font-mono text-lg font-semibold w-24 text-center">
                {adFrequency} posts
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8 flex justify-end">
          <button type="submit" disabled={saving} className="bg-primary text-white px-8 py-3 rounded-xl font-medium hover:opacity-90 transition-opacity disabled:opacity-50 flex items-center shadow-md">
            <span className="material-symbols-outlined mr-2">save</span>
            {saving ? 'Saving...' : 'Save Configuration'}
          </button>
        </div>
      </form>
    </div>
  )
}
