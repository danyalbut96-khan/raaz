import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function AdsManagement() {
  const [adsEnabled, setAdsEnabled] = useState<boolean>(true)
  const [adFrequency, setAdFrequency] = useState<number>(3)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    async function fetchConfig() {
      setLoading(true)
      const { data, error } = await supabase
        .from('app_config')
        .select('key, value')
      
      if (!error && data) {
        const enabled = data.find(c => c.key === 'ads_enabled')
        const freq = data.find(c => c.key === 'ad_frequency')
        
        if (enabled) setAdsEnabled(enabled.value === 'true')
        if (freq) setAdFrequency(parseInt(freq.value, 10))
      }
      setLoading(false)
    }

    fetchConfig()
  }, [])

  const handleSave = async () => {
    setSaving(true)
    
    await supabase.from('app_config').upsert({
      key: 'ads_enabled',
      value: adsEnabled ? 'true' : 'false'
    }, { onConflict: 'key' })
    
    await supabase.from('app_config').upsert({
      key: 'ad_frequency',
      value: adFrequency.toString()
    }, { onConflict: 'key' })
    
    setSaving(false)
    alert('Ad settings saved successfully!')
  }

  if (loading) return <div className="p-8 text-on-surface-variant">Loading configuration...</div>

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Advertisements Management</h2>
          <p className="text-on-surface-variant mt-2">Configure ad delivery across the RAAZ app.</p>
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
          <span className="material-symbols-outlined text-primary mr-3">campaign</span>
          AdMob Settings
        </h3>
        
        <div className="space-y-8">
          {/* Ads Master Toggle */}
          <div className="flex items-center justify-between p-6 rounded-xl bg-black/5 border border-outline-variant/30">
            <div>
              <p className="font-semibold text-lg text-on-surface">Global Ad Delivery</p>
              <p className="text-on-surface-variant mt-1 text-sm">Enable or disable all ads across the app instantly.</p>
            </div>
            
            <label className="relative inline-flex items-center cursor-pointer">
              <input 
                type="checkbox" 
                className="sr-only peer"
                checked={adsEnabled}
                onChange={(e) => setAdsEnabled(e.target.checked)}
              />
              <div className="w-14 h-7 bg-outline-variant rounded-full peer peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-0.5 after:left-[4px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-primary"></div>
            </label>
          </div>

          {/* Ad Frequency */}
          <div className="p-6 rounded-xl bg-black/5 border border-outline-variant/30">
            <label className="block font-semibold text-lg text-on-surface mb-2">Interstitial Ad Frequency</label>
            <p className="text-on-surface-variant text-sm mb-4">Show an interstitial ad every X posts/actions.</p>
            <input
              type="number"
              min="1"
              max="20"
              className="w-full md:w-1/3 rounded-xl border border-outline px-4 py-3 bg-surface focus:ring-2 focus:ring-primary focus:outline-none"
              value={adFrequency}
              onChange={(e) => setAdFrequency(parseInt(e.target.value, 10))}
            />
          </div>
        </div>
      </div>
    </div>
  )
}
