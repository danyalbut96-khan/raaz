export default function AboutUs() {
  return (
    <div className="py-24 px-6 max-w-7xl mx-auto">
      <div className="text-center space-y-6 mb-16">
        <span className="text-primary font-bold tracking-widest uppercase">Our Purpose</span>
        <h1 className="text-5xl font-bold max-w-4xl mx-auto leading-tight">
          Engineering <span className="text-primary">Human Connection</span> through Absolute Privacy.
        </h1>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div className="p-8 bg-surface rounded-2xl border border-outline-variant/30">
          <span className="material-symbols-outlined text-primary text-4xl mb-4">rocket_launch</span>
          <h2 className="text-3xl font-bold mb-4">Mission</h2>
          <p className="text-lg text-on-surface-variant leading-relaxed">
            To empower individuals worldwide by providing a secure, anonymous environment where vulnerability is a strength and authentic sharing is protected by world-class encryption.
          </p>
        </div>
        <div className="p-8 bg-surface rounded-2xl border border-outline-variant/30">
          <span className="material-symbols-outlined text-secondary text-4xl mb-4">visibility</span>
          <h2 className="text-3xl font-bold mb-4">Vision</h2>
          <p className="text-lg text-on-surface-variant leading-relaxed">
            A digital world where identity doesn't define worth, and where the collective wisdom of humanity can flow freely without fear of judgment or surveillance.
          </p>
        </div>
      </div>
    </div>
  )
}
