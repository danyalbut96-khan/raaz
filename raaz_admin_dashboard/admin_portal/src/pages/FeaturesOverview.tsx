export default function FeaturesOverview() {
  return (
    <div className="py-24 px-6 max-w-7xl mx-auto">
      <h1 className="text-5xl font-bold mb-16 text-center">App Features</h1>
      <div className="space-y-24">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          <div className="bg-primary/10 rounded-[3rem] aspect-square flex items-center justify-center">
            <span className="material-symbols-outlined text-9xl text-primary">masks</span>
          </div>
          <div>
            <h2 className="text-4xl font-bold mb-4">True Anonymity</h2>
            <p className="text-lg text-on-surface-variant">No names. No handles. No tracing. Every post is entirely decoupled from your identity using advanced Zero-Knowledge Proof architecture.</p>
          </div>
        </div>
        <div className="grid md:grid-cols-2 gap-12 items-center flex-row-reverse">
          <div className="bg-secondary/10 rounded-[3rem] aspect-square flex items-center justify-center md:order-last">
            <span className="material-symbols-outlined text-9xl text-secondary">self_improvement</span>
          </div>
          <div>
            <h2 className="text-4xl font-bold mb-4">Daily Reflections</h2>
            <p className="text-lg text-on-surface-variant">Guided prompts to help you unpack your day, process emotions, and build a healthy mental routine.</p>
          </div>
        </div>
      </div>
    </div>
  )
}
