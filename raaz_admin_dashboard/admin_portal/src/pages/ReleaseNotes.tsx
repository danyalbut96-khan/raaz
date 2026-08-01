export default function ReleaseNotes() {
  return (
    <div className="py-24 px-6 max-w-3xl mx-auto">
      <h1 className="text-5xl font-bold mb-8">Release Notes & Roadmap</h1>
      <div className="space-y-8 mt-12">
        <div className="relative pl-8 border-l-2 border-primary">
          <div className="absolute w-4 h-4 bg-primary rounded-full -left-[9px] top-1"></div>
          <h3 className="text-2xl font-bold text-primary">v2.1.0 - The Community Update</h3>
          <p className="text-sm text-on-surface-variant mb-2">October 15, 2026</p>
          <ul className="list-disc ml-5 text-on-surface-variant">
            <li>Added Daily Challenges feature</li>
            <li>Improved anonymity hashing algorithms</li>
            <li>Bug fixes in the home feed</li>
          </ul>
        </div>
        <div className="relative pl-8 border-l-2 border-outline-variant">
          <div className="absolute w-4 h-4 bg-outline-variant rounded-full -left-[9px] top-1"></div>
          <h3 className="text-2xl font-bold">v2.0.0 - Global Launch</h3>
          <p className="text-sm text-on-surface-variant mb-2">September 1, 2026</p>
          <ul className="list-disc ml-5 text-on-surface-variant">
            <li>Initial public release of RAAZ</li>
          </ul>
        </div>
      </div>
    </div>
  )
}
