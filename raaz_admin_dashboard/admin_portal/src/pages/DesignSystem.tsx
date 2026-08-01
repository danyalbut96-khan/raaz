export default function DesignSystem() {
  return (
    <div className="py-24 px-6 max-w-5xl mx-auto">
      <h1 className="text-5xl font-bold mb-12">RAAZ Design System</h1>
      <p className="text-on-surface-variant mb-12">Internal reference for the RAAZ visual identity and Tailwind config.</p>
      
      <div className="space-y-12">
        <section>
          <h2 className="text-3xl font-bold mb-6">Colors</h2>
          <div className="flex gap-4">
            <div className="w-24 h-24 bg-primary rounded-xl flex items-end p-2 text-white font-mono text-xs">primary</div>
            <div className="w-24 h-24 bg-secondary rounded-xl flex items-end p-2 text-white font-mono text-xs">secondary</div>
            <div className="w-24 h-24 bg-tertiary rounded-xl flex items-end p-2 text-white font-mono text-xs">tertiary</div>
            <div className="w-24 h-24 bg-error rounded-xl flex items-end p-2 text-white font-mono text-xs">error</div>
          </div>
        </section>
        
        <section>
          <h2 className="text-3xl font-bold mb-6">Typography</h2>
          <div className="space-y-4">
            <div className="text-5xl font-bold">Display Large</div>
            <div className="text-3xl font-bold">Headline Large</div>
            <div className="text-xl font-bold">Title Large</div>
            <div className="text-base">Body Medium</div>
          </div>
        </section>
      </div>
    </div>
  )
}
