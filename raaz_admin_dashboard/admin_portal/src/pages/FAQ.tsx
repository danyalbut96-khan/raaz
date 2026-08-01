export default function FAQ() {
  return (
    <div className="py-24 px-6 max-w-3xl mx-auto">
      <h1 className="text-5xl font-bold mb-12 text-center">Frequently Asked Questions</h1>
      <div className="space-y-6">
        <div className="bg-surface p-6 rounded-2xl border border-outline-variant/30">
          <h3 className="text-xl font-bold mb-2">Is RAAZ really anonymous?</h3>
          <p className="text-on-surface-variant">Yes. We do not store your name, phone number, or email address in association with your posts.</p>
        </div>
        <div className="bg-surface p-6 rounded-2xl border border-outline-variant/30">
          <h3 className="text-xl font-bold mb-2">How is content moderated?</h3>
          <p className="text-on-surface-variant">We use a combination of AI filtering and community reporting to ensure the platform remains a safe space.</p>
        </div>
        <div className="bg-surface p-6 rounded-2xl border border-outline-variant/30">
          <h3 className="text-xl font-bold mb-2">Is the app free?</h3>
          <p className="text-on-surface-variant">RAAZ is completely free to download and use.</p>
        </div>
      </div>
    </div>
  )
}
