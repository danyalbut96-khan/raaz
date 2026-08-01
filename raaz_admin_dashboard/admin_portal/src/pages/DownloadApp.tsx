export default function DownloadApp() {
  return (
    <div className="py-24 px-6 max-w-7xl mx-auto text-center">
      <h1 className="text-5xl font-bold mb-6">Get RAAZ Today</h1>
      <p className="text-lg text-on-surface-variant mb-12 max-w-2xl mx-auto">
        Available on iOS and Android. Start your journey of honest socializing in complete anonymity.
      </p>
      <div className="flex flex-col md:flex-row justify-center gap-6">
        <button className="bg-black text-white px-8 py-4 rounded-xl flex items-center justify-center gap-4 hover:opacity-80">
          <span className="material-symbols-outlined text-3xl">phone_iphone</span>
          <div className="text-left">
            <div className="text-xs">Download on the</div>
            <div className="text-xl font-bold">App Store</div>
          </div>
        </button>
        <button className="bg-black text-white px-8 py-4 rounded-xl flex items-center justify-center gap-4 hover:opacity-80">
          <span className="material-symbols-outlined text-3xl">android</span>
          <div className="text-left">
            <div className="text-xs">GET IT ON</div>
            <div className="text-xl font-bold">Google Play</div>
          </div>
        </button>
      </div>
    </div>
  )
}
