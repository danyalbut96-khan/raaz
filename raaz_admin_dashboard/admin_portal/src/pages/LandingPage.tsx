export default function LandingPage() {
  return (
    <div>
      {/* Hero Section */}
      <section className="relative min-h-[70vh] flex items-center justify-center px-6">
        <div className="absolute inset-0 bg-primary/5 rounded-full blur-3xl -z-10" />
        <div className="max-w-7xl mx-auto w-full grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          <div className="flex flex-col gap-6 z-10">
            <span className="inline-flex items-center px-4 py-1 bg-primary/10 text-primary rounded-full font-medium w-fit text-sm">
              The Future of Honest Socializing
            </span>
            <h1 className="text-5xl md:text-7xl font-bold text-on-surface leading-tight">
              Speak your truth, <span className="text-primary">stay unknown.</span>
            </h1>
            <p className="text-lg text-on-surface-variant max-w-lg">
              RAAZ is a sanctuary for authentic connection. Share your deepest thoughts, join global challenges, and reflect daily—all without the pressure of an identity.
            </p>
            <div className="flex flex-wrap gap-4 mt-4">
              <button className="bg-primary text-white px-8 py-3 rounded-xl font-medium shadow-lg hover:opacity-90 transition-opacity">
                Download App
              </button>
              <button className="border border-outline-variant text-on-surface-variant px-8 py-3 rounded-xl font-medium hover:bg-surface-container-low transition-colors">
                Learn More
              </button>
            </div>
            <p className="text-sm text-on-surface-variant font-medium mt-4">Trusted by 2M+ anonymous explorers</p>
          </div>
          <div className="relative flex justify-center lg:justify-end hidden lg:flex">
            <div className="relative w-full max-w-sm aspect-[9/16] bg-primary rounded-[3rem] border-[12px] border-on-surface shadow-2xl transform lg:rotate-6 overflow-hidden">
              <div className="absolute inset-0 bg-white p-6 flex flex-col gap-6">
                <div className="font-bold text-2xl text-primary">RAAZ</div>
                <div className="p-4 bg-primary/10 rounded-xl">
                  <span className="text-xs uppercase tracking-widest text-primary font-bold">Daily Prompt</span>
                  <p className="font-medium mt-2">What's one thing you're too afraid to tell your best friend?</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="py-24 px-6 bg-surface-container-lowest border-t border-outline-variant/30">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-on-surface mb-4">Engineered for Transparency</h2>
            <p className="text-lg text-on-surface-variant max-w-2xl mx-auto">RAAZ provides the tools you need to connect without the masks of social media identity.</p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="p-8 bg-surface border border-outline-variant/30 rounded-2xl shadow-sm hover:shadow-md transition-shadow">
              <div className="w-12 h-12 rounded-xl bg-primary/10 text-primary flex items-center justify-center mb-6">
                <span className="material-symbols-outlined">masks</span>
              </div>
              <h3 className="text-xl font-bold text-on-surface mb-3">Anonymous Posting</h3>
              <p className="text-on-surface-variant">Share your thoughts without hesitation. Your identity is fully encrypted and never stored on our public servers.</p>
            </div>
            <div className="p-8 bg-surface border border-outline-variant/30 rounded-2xl shadow-sm hover:shadow-md transition-shadow">
              <div className="w-12 h-12 rounded-xl bg-secondary/10 text-secondary flex items-center justify-center mb-6">
                <span className="material-symbols-outlined">self_improvement</span>
              </div>
              <h3 className="text-xl font-bold text-on-surface mb-3">Daily Reflection</h3>
              <p className="text-on-surface-variant">Mental wellness check-ins that prompt you to reflect on your day and discover patterns in your emotional journey.</p>
            </div>
            <div className="p-8 bg-surface border border-outline-variant/30 rounded-2xl shadow-sm hover:shadow-md transition-shadow">
              <div className="w-12 h-12 rounded-xl bg-tertiary/10 text-tertiary flex items-center justify-center mb-6">
                <span className="material-symbols-outlined">trophy</span>
              </div>
              <h3 className="text-xl font-bold text-on-surface mb-3">Community Challenges</h3>
              <p className="text-on-surface-variant">Join collective quests for kindness, honesty, and growth. Track the community's positive impact in real-time.</p>
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}
