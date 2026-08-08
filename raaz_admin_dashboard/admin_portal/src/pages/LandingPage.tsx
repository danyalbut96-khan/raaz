import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { supabase } from '../lib/supabase'

type BlogPost = {
  id: string
  title: string
  slug: string
  summary: string
  cover_image_url: string
  author_name: string
  tags: string[]
  published_at: string
}

type Stats = {
  users: number
  posts: number
  categories: number
}

export default function LandingPage() {
  const [blogs, setBlogs] = useState<BlogPost[]>([])
  const [stats, setStats] = useState<Stats>({ users: 0, posts: 0, categories: 0 })
  const [heroHeadline, setHeroHeadline] = useState('Share Secrets. Stay 100% Anonymous.')
  const [heroSub, setHeroSub] = useState('The premier anonymous confession and support network built for complete privacy.')
  const [appVersion, setAppVersion] = useState('1.0.0')

  useEffect(() => {
    // Fetch app_config realtime settings
    const fetchConfig = async () => {
      const { data } = await supabase.from('app_config').select('key, value')
      if (data) {
        const cfg: Record<string, string> = {}
        data.forEach((row: { key: string; value: string }) => { cfg[row.key] = row.value })
        if (cfg.landing_hero_headline) setHeroHeadline(cfg.landing_hero_headline)
        if (cfg.landing_hero_subheadline) setHeroSub(cfg.landing_hero_subheadline)
        if (cfg.app_version) setAppVersion(cfg.app_version)
      }
    }

    const fetchBlogs = async () => {
      const { data } = await supabase
        .from('blog_posts')
        .select('id, title, slug, summary, cover_image_url, author_name, tags, published_at')
        .eq('is_published', true)
        .order('published_at', { ascending: false })
        .limit(3)
      if (data) setBlogs(data)
    }

    const fetchStats = async () => {
      const [{ count: users }, { count: posts }, { count: categories }] = await Promise.all([
        supabase.from('profiles').select('user_id', { count: 'exact', head: true }),
        supabase.from('posts').select('id', { count: 'exact', head: true }).eq('is_deleted', false),
        supabase.from('categories').select('id', { count: 'exact', head: true }),
      ])
      setStats({
        users: users ?? 0,
        posts: posts ?? 0,
        categories: categories ?? 0,
      })
    }

    fetchConfig()
    fetchBlogs()
    fetchStats()

    // Realtime subscription for app_config
    const configSub = supabase
      .channel('landing_config')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'app_config' }, fetchConfig)
      .subscribe()
    const blogSub = supabase
      .channel('landing_blogs')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'blog_posts' }, fetchBlogs)
      .subscribe()

    return () => {
      supabase.removeChannel(configSub)
      supabase.removeChannel(blogSub)
    }
  }, [])

  const features = [
    {
      icon: 'masks',
      color: 'from-indigo-500 to-blue-600',
      bg: 'bg-indigo-50',
      text: 'text-indigo-600',
      title: 'True Anonymity',
      desc: 'Your identity is fully encrypted. No names, no photos — just raw, authentic thoughts.',
    },
    {
      icon: 'self_improvement',
      color: 'from-violet-500 to-purple-600',
      bg: 'bg-violet-50',
      text: 'text-violet-600',
      title: 'Daily Reflection',
      desc: 'AI-powered prompts help you check in mentally, track emotions and grow daily.',
    },
    {
      icon: 'trophy',
      color: 'from-amber-500 to-orange-600',
      bg: 'bg-amber-50',
      text: 'text-amber-600',
      title: 'Community Challenges',
      desc: 'Join global quests for kindness, honesty and personal growth — earn XP badges.',
    },
    {
      icon: 'security',
      color: 'from-emerald-500 to-teal-600',
      bg: 'bg-emerald-50',
      text: 'text-emerald-600',
      title: 'Bank-Level Security',
      desc: 'End-to-end encryption ensures your confessions are yours alone — forever.',
    },
    {
      icon: 'forum',
      color: 'from-sky-500 to-cyan-600',
      bg: 'bg-sky-50',
      text: 'text-sky-600',
      title: 'Reply Threads',
      desc: 'Deep, meaningful conversations under a cloak of anonymity. Be heard.',
    },
    {
      icon: 'local_fire_department',
      color: 'from-rose-500 to-pink-600',
      bg: 'bg-rose-50',
      text: 'text-rose-600',
      title: 'Trending Confessions',
      desc: 'Discover what the world is secretly thinking. Real-time trending stories.',
    },
  ]

  return (
    <div className="overflow-hidden">
      {/* ── HERO ── */}
      <section className="relative min-h-screen flex items-center justify-center px-6 py-24 overflow-hidden bg-gradient-to-br from-slate-950 via-indigo-950 to-slate-900">
        {/* Radial glow blobs */}
        <div className="absolute -top-40 -left-40 w-[600px] h-[600px] bg-indigo-600/20 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -bottom-40 -right-20 w-[500px] h-[500px] bg-violet-600/20 rounded-full blur-3xl pointer-events-none" />

        <div className="max-w-7xl mx-auto w-full grid grid-cols-1 lg:grid-cols-2 gap-16 items-center relative z-10">
          {/* Text */}
          <div className="flex flex-col gap-8">
            <div className="inline-flex items-center gap-2 px-4 py-1.5 bg-indigo-500/20 text-indigo-300 rounded-full font-medium text-sm w-fit border border-indigo-500/30">
              <span className="material-symbols-outlined text-sm">verified_user</span>
              v{appVersion} — Fully Anonymous
            </div>

            <h1 className="text-5xl md:text-6xl xl:text-7xl font-extrabold text-white leading-tight tracking-tight">
              {heroHeadline.split('.')[0]}.<br />
              <span className="bg-gradient-to-r from-indigo-400 to-violet-400 bg-clip-text text-transparent">
                {heroHeadline.split('.').slice(1).join('.').trim()}
              </span>
            </h1>

            <p className="text-lg text-slate-300 max-w-lg leading-relaxed">
              {heroSub}
            </p>

            <div className="flex flex-wrap gap-4">
              <Link
                to="/download"
                className="flex items-center gap-2 bg-gradient-to-r from-indigo-600 to-violet-600 text-white px-8 py-4 rounded-2xl font-semibold shadow-xl shadow-indigo-900/40 hover:scale-105 transition-transform"
              >
                <span className="material-symbols-outlined text-sm">download</span>
                Download Free
              </Link>
              <Link
                to="/features"
                className="flex items-center gap-2 border border-white/20 text-white/80 px-8 py-4 rounded-2xl font-semibold backdrop-blur hover:bg-white/10 transition-colors"
              >
                Learn More
                <span className="material-symbols-outlined text-sm">arrow_forward</span>
              </Link>
            </div>

            {/* Live stats */}
            <div className="flex flex-wrap gap-8 mt-2">
              <div>
                <p className="text-3xl font-bold text-white">
                  {stats.users > 0 ? `${(stats.users / 1000).toFixed(1)}K+` : '—'}
                </p>
                <p className="text-sm text-slate-400">Anonymous Users</p>
              </div>
              <div>
                <p className="text-3xl font-bold text-white">
                  {stats.posts > 0 ? `${(stats.posts / 1000).toFixed(1)}K+` : '—'}
                </p>
                <p className="text-sm text-slate-400">Confessions Shared</p>
              </div>
              <div>
                <p className="text-3xl font-bold text-white">
                  {stats.categories > 0 ? `${stats.categories}` : '—'}
                </p>
                <p className="text-sm text-slate-400">Topic Categories</p>
              </div>
            </div>
          </div>

          {/* Phone mockup */}
          <div className="relative flex justify-center lg:justify-end">
            <div className="relative w-64 aspect-[9/19.5] bg-slate-900 rounded-[3rem] border-4 border-slate-700 shadow-2xl shadow-indigo-900/50 overflow-hidden">
              {/* Notch */}
              <div className="absolute top-3 left-1/2 -translate-x-1/2 w-20 h-5 bg-slate-800 rounded-full z-10" />
              {/* Screen */}
              <div className="absolute inset-0 bg-gradient-to-b from-slate-900 to-slate-800 flex flex-col pt-10 px-4 gap-3">
                <div className="flex items-center gap-2 mt-2">
                  <span className="material-symbols-outlined text-indigo-400 text-lg">security</span>
                  <span className="text-white font-bold text-lg">RAAZ</span>
                </div>
                <div className="bg-indigo-600/20 border border-indigo-500/30 rounded-2xl p-3">
                  <span className="text-xs text-indigo-300 uppercase tracking-widest font-bold">Daily Prompt</span>
                  <p className="text-white text-xs mt-1 leading-relaxed">What's one thing you're too afraid to tell your best friend?</p>
                </div>
                {['Confession #1', 'Confession #2', 'Confession #3'].map((_label, i) => (
                  <div key={i} className="bg-slate-800/80 border border-slate-700/60 rounded-xl p-3">
                    <p className="text-white/90 text-xs line-clamp-2">
                      {i === 0 ? 'I pretend to be happy at work every day but inside I feel completely lost...' :
                       i === 1 ? 'I secretly applied to another company. No one knows yet.' :
                       'I cried in my car today for 30 minutes before going in to work.'}
                    </p>
                    <div className="flex gap-3 mt-2">
                      <span className="text-xs text-slate-400">❤️ {18 + i * 7}</span>
                      <span className="text-xs text-slate-400">💬 {4 + i * 3}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            {/* Decorative ring */}
            <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
              <div className="w-80 h-80 rounded-full border border-indigo-500/10" />
              <div className="absolute w-96 h-96 rounded-full border border-violet-500/10" />
            </div>
          </div>
        </div>
      </section>

      {/* ── FEATURES GRID ── */}
      <section className="py-28 px-6 bg-white">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <span className="inline-block px-4 py-1.5 bg-indigo-50 text-indigo-600 rounded-full text-sm font-semibold mb-4">Why RAAZ?</span>
            <h2 className="text-4xl md:text-5xl font-extrabold text-slate-900 mb-4">Built for Authentic Humans</h2>
            <p className="text-lg text-slate-500 max-w-2xl mx-auto">
              We built RAAZ to be the one place where you can speak freely, reflect deeply, and connect without the weight of identity.
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {features.map((f, i) => (
              <div key={i} className="group p-8 bg-white border border-slate-100 rounded-2xl shadow-sm hover:shadow-lg hover:-translate-y-1 transition-all duration-300">
                <div className={`w-12 h-12 rounded-2xl ${f.bg} flex items-center justify-center mb-6`}>
                  <span className={`material-symbols-outlined ${f.text}`}>{f.icon}</span>
                </div>
                <h3 className="text-xl font-bold text-slate-900 mb-3">{f.title}</h3>
                <p className="text-slate-500 leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── HOW IT WORKS ── */}
      <section className="py-28 px-6 bg-gradient-to-br from-indigo-50 to-violet-50">
        <div className="max-w-5xl mx-auto text-center">
          <span className="inline-block px-4 py-1.5 bg-indigo-100 text-indigo-600 rounded-full text-sm font-semibold mb-4">Simple &amp; Private</span>
          <h2 className="text-4xl md:text-5xl font-extrabold text-slate-900 mb-16">How RAAZ Works</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 relative">
            <div className="hidden md:block absolute top-12 left-1/4 right-1/4 h-0.5 bg-gradient-to-r from-indigo-200 to-violet-200" />
            {[
              { step: '01', icon: 'download', title: 'Download', desc: 'Get RAAZ free on iOS or Android. Zero sign-up info required.' },
              { step: '02', icon: 'edit_note', title: 'Write Freely', desc: 'Share thoughts, confessions, or questions — completely anonymously.' },
              { step: '03', icon: 'forum', title: 'Connect', desc: 'React to others, join threads, earn XP — all without revealing who you are.' },
            ].map((s, i) => (
              <div key={i} className="flex flex-col items-center text-center gap-4">
                <div className="w-20 h-20 bg-white rounded-3xl shadow-lg flex items-center justify-center border border-indigo-100">
                  <span className="material-symbols-outlined text-indigo-600 text-3xl">{s.icon}</span>
                </div>
                <span className="text-4xl font-black text-indigo-100">{s.step}</span>
                <h3 className="text-xl font-bold text-slate-900 -mt-3">{s.title}</h3>
                <p className="text-slate-500">{s.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── TESTIMONIALS ── */}
      <section className="py-28 px-6 bg-white">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <span className="inline-block px-4 py-1.5 bg-rose-50 text-rose-600 rounded-full text-sm font-semibold mb-4">Real Impact</span>
            <h2 className="text-4xl md:text-5xl font-extrabold text-slate-900">What People Are Saying</h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {[
              { quote: "RAAZ gave me a space to voice things I couldn't say to anyone. It's the most freeing app I've ever used.", handle: 'Anonymous User, Mumbai' },
              { quote: "The daily challenges helped me build a journaling habit I could never stick to before. 6-week streak!", handle: 'Anonymous User, Karachi' },
              { quote: "I cried reading the confessions — so relatable. I feel less alone knowing others feel the same.", handle: 'Anonymous User, London' },
            ].map((t, i) => (
              <div key={i} className="p-8 bg-slate-50 border border-slate-100 rounded-2xl">
                <div className="flex gap-1 mb-4">
                  {[0,1,2,3,4].map(s => (
                    <span key={s} className="text-amber-400">★</span>
                  ))}
                </div>
                <p className="text-slate-700 leading-relaxed mb-6 italic">"{t.quote}"</p>
                <p className="text-sm text-slate-400 font-medium">{t.handle}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── BLOG SECTION (live from DB) ── */}
      {blogs.length > 0 && (
        <section className="py-28 px-6 bg-gradient-to-br from-slate-950 to-indigo-950">
          <div className="max-w-6xl mx-auto">
            <div className="flex items-center justify-between mb-12">
              <div>
                <span className="inline-block px-4 py-1.5 bg-indigo-500/20 text-indigo-300 rounded-full text-sm font-semibold mb-3 border border-indigo-500/30">Latest from RAAZ</span>
                <h2 className="text-4xl font-extrabold text-white">Blog & Updates</h2>
              </div>
              <Link to="/blog" className="text-indigo-400 hover:text-indigo-300 font-medium flex items-center gap-1 transition-colors">
                View All <span className="material-symbols-outlined text-sm">arrow_forward</span>
              </Link>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {blogs.map((b) => (
                <div key={b.id} className="group bg-slate-900/80 border border-slate-700/60 rounded-2xl overflow-hidden hover:-translate-y-1 transition-all duration-300">
                  <img
                    src={b.cover_image_url || 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80'}
                    alt={b.title}
                    className="w-full h-44 object-cover group-hover:scale-105 transition-transform duration-500"
                  />
                  <div className="p-6">
                    <div className="flex flex-wrap gap-2 mb-3">
                      {(b.tags || []).slice(0, 2).map((tag, j) => (
                        <span key={j} className="text-xs px-2 py-0.5 rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/30">{tag}</span>
                      ))}
                    </div>
                    <h3 className="text-lg font-bold text-white mb-2 line-clamp-2">{b.title}</h3>
                    <p className="text-slate-400 text-sm line-clamp-3">{b.summary}</p>
                    <div className="flex items-center justify-between mt-5 pt-4 border-t border-slate-700/50">
                      <span className="text-xs text-slate-500">{b.author_name}</span>
                      <span className="text-xs text-slate-500">{new Date(b.published_at).toLocaleDateString()}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>
      )}

      {/* ── DOWNLOAD CTA ── */}
      <section className="py-28 px-6 bg-gradient-to-r from-indigo-600 to-violet-600 relative overflow-hidden">
        <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-10" />
        <div className="max-w-3xl mx-auto text-center relative z-10">
          <h2 className="text-4xl md:text-5xl font-extrabold text-white mb-6">
            Ready to Speak Freely?
          </h2>
          <p className="text-xl text-indigo-100 mb-10">
            Join millions of users sharing their truth anonymously every single day.
          </p>
          <div className="flex flex-wrap gap-4 justify-center">
            <Link
              to="/download"
              className="flex items-center gap-3 bg-white text-indigo-700 px-8 py-4 rounded-2xl font-bold shadow-xl hover:scale-105 transition-transform"
            >
              <span className="material-symbols-outlined">phone_iphone</span>
              App Store
            </Link>
            <Link
              to="/download"
              className="flex items-center gap-3 bg-white text-indigo-700 px-8 py-4 rounded-2xl font-bold shadow-xl hover:scale-105 transition-transform"
            >
              <span className="material-symbols-outlined">android</span>
              Google Play
            </Link>
          </div>
          <p className="text-indigo-200 text-sm mt-8">Free forever. No personal data required. 100% private.</p>
        </div>
      </section>
    </div>
  )
}
