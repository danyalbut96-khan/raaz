import { Outlet, Link } from 'react-router-dom'

export default function PublicLayout() {
  return (
    <div className="min-h-screen bg-background text-on-background flex flex-col font-sans">
      {/* TopNavBar */}
      <nav className="fixed top-0 w-full z-50 bg-surface/80 backdrop-blur-xl border-b border-white/20 shadow-sm">
        <div className="flex justify-between items-center px-6 py-4 max-w-7xl mx-auto">
          <div className="flex items-center">
            <Link to="/" className="font-bold text-2xl text-primary tracking-tight">RAAZ</Link>
          </div>
          <div className="hidden md:flex items-center space-x-6">
            <Link to="/features" className="font-medium text-on-surface hover:text-primary transition-colors duration-200">Features</Link>
            <Link to="/community" className="font-medium text-on-surface hover:text-primary transition-colors duration-200">Community</Link>
            <Link to="/blog" className="font-medium text-on-surface hover:text-primary transition-colors duration-200">Blog</Link>
            <Link to="/careers" className="font-medium text-on-surface hover:text-primary transition-colors duration-200">Careers</Link>
            <Link to="/about" className="font-medium text-on-surface hover:text-primary transition-colors duration-200">About Us</Link>
          </div>
          <Link to="/download" className="bg-primary text-white px-6 py-2 rounded-xl font-medium hover:bg-opacity-90 transition-all shadow-sm">
            Download App
          </Link>
        </div>
      </nav>

      {/* Main Content Area */}
      <main className="flex-1 pt-24 overflow-x-hidden">
        <Outlet />
      </main>

      {/* Basic Footer */}
      <footer className="bg-surface-container-high py-12 mt-auto">
        <div className="max-w-7xl mx-auto px-6 grid grid-cols-1 md:grid-cols-4 gap-8">
          <div>
            <span className="font-bold text-xl text-primary mb-4 block">RAAZ</span>
            <p className="text-on-surface-variant text-sm">The Future of Honest Socializing. Speak your truth, stay unknown.</p>
          </div>
          <div>
            <span className="font-bold text-on-surface mb-4 block">Product</span>
            <ul className="space-y-2 text-sm text-on-surface-variant">
              <li><Link to="/features" className="hover:text-primary">Features</Link></li>
              <li><Link to="/download" className="hover:text-primary">Download App</Link></li>
              <li><Link to="/release-notes" className="hover:text-primary">Release Notes</Link></li>
            </ul>
          </div>
          <div>
            <span className="font-bold text-on-surface mb-4 block">Company</span>
            <ul className="space-y-2 text-sm text-on-surface-variant">
              <li><Link to="/about" className="hover:text-primary">About Us</Link></li>
              <li><Link to="/careers" className="hover:text-primary">Careers</Link></li>
              <li><Link to="/blog" className="hover:text-primary">Blog</Link></li>
              <li><Link to="/contact" className="hover:text-primary">Contact Us</Link></li>
            </ul>
          </div>
          <div>
            <span className="font-bold text-on-surface mb-4 block">Legal</span>
            <ul className="space-y-2 text-sm text-on-surface-variant">
              <li><Link to="/privacy" className="hover:text-primary">Privacy & Terms</Link></li>
              <li><Link to="/community" className="hover:text-primary">Community Guidelines</Link></li>
              <li><Link to="/faq" className="hover:text-primary">FAQ</Link></li>
              <li><Link to="/login" className="hover:text-primary">Admin Portal</Link></li>
            </ul>
          </div>
        </div>
        <div className="max-w-7xl mx-auto px-6 mt-12 pt-8 border-t border-outline-variant/30 text-center text-sm text-on-surface-variant">
          &copy; {new Date().getFullYear()} RAAZ Inc. All rights reserved.
        </div>
      </footer>
    </div>
  )
}
