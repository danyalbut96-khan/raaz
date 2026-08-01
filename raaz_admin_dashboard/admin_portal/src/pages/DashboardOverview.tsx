import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

type Stats = {
  totalPosts: number
  totalProfiles: number
  pendingReports: number
  openBugReports: number
  totalComments: number
  totalReactions: number
  postsToday: number
  profilesThisWeek: number
}

type RecentPost = {
  id: string
  body: string
  pseudonym: string
  created_at: string
  categories: { name: string } | null
}

type RecentReport = {
  id: string
  reason: string
  status: string
  created_at: string
}

export default function DashboardOverview() {
  const [stats, setStats] = useState<Stats>({
    totalPosts: 0,
    totalProfiles: 0,
    pendingReports: 0,
    openBugReports: 0,
    totalComments: 0,
    totalReactions: 0,
    postsToday: 0,
    profilesThisWeek: 0,
  })
  const [recentPosts, setRecentPosts] = useState<RecentPost[]>([])
  const [recentReports, setRecentReports] = useState<RecentReport[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchAll()
  }, [])

  async function fetchAll() {
    setLoading(true)
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const weekAgo = new Date()
    weekAgo.setDate(weekAgo.getDate() - 7)

    const [
      { count: totalPosts },
      { count: totalProfiles },
      { count: pendingReports },
      { count: openBugReports },
      { count: totalComments },
      { count: totalReactions },
      { count: postsToday },
      { count: profilesThisWeek },
      { data: latestPosts },
      { data: latestReports },
    ] = await Promise.all([
      supabase.from('posts').select('*', { count: 'exact', head: true }).eq('is_deleted', false),
      supabase.from('profiles').select('*', { count: 'exact', head: true }),
      supabase.from('reported_posts').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
      supabase.from('bug_reports').select('*', { count: 'exact', head: true }),
      supabase.from('comments').select('*', { count: 'exact', head: true }).eq('is_deleted', false),
      supabase.from('reactions').select('*', { count: 'exact', head: true }),
      supabase.from('posts').select('*', { count: 'exact', head: true }).gte('created_at', today.toISOString()),
      supabase.from('profiles').select('*', { count: 'exact', head: true }).gte('member_since', weekAgo.toISOString()),
      supabase.from('posts').select('id, body, pseudonym, created_at, categories(name)').order('created_at', { ascending: false }).limit(5),
      supabase.from('reported_posts').select('id, reason, status, created_at').order('created_at', { ascending: false }).limit(5),
    ])

    setStats({
      totalPosts: totalPosts || 0,
      totalProfiles: totalProfiles || 0,
      pendingReports: pendingReports || 0,
      openBugReports: openBugReports || 0,
      totalComments: totalComments || 0,
      totalReactions: totalReactions || 0,
      postsToday: postsToday || 0,
      profilesThisWeek: profilesThisWeek || 0,
    })
    setRecentPosts((latestPosts as unknown as RecentPost[]) || [])
    setRecentReports((latestReports as RecentReport[]) || [])
    setLoading(false)
  }

  const StatCard = ({ icon, label, value, sub, subValue, color = 'text-primary', bgColor = 'bg-primary/10' }: {
    icon: string, label: string, value: number, sub?: string, subValue?: number, color?: string, bgColor?: string
  }) => (
    <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm hover:shadow-lg transition-all group">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-on-surface-variant text-sm font-medium">{label}</p>
          {loading ? (
            <div className="h-10 w-24 bg-black/10 rounded-lg animate-pulse mt-3" />
          ) : (
            <p className={`text-4xl font-bold mt-2 ${color}`}>{value.toLocaleString()}</p>
          )}
          {sub && subValue !== undefined && !loading && (
            <p className="text-xs text-on-surface-variant mt-2 flex items-center gap-1">
              <span className="material-symbols-outlined text-sm text-green-500">arrow_upward</span>
              <span className="font-semibold text-green-600">{subValue}</span> {sub}
            </p>
          )}
        </div>
        <div className={`w-12 h-12 ${bgColor} rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform`}>
          <span className={`material-symbols-outlined ${color}`}>{icon}</span>
        </div>
      </div>
    </div>
  )

  return (
    <div className="space-y-8">
      <div>
        <h2 className="text-3xl font-bold text-on-surface">Dashboard Overview</h2>
        <p className="text-on-surface-variant mt-1">Real-time metrics from your RAAZ platform.</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-5">
        <StatCard icon="group" label="Total Users" value={stats.totalProfiles} sub="new this week" subValue={stats.profilesThisWeek} />
        <StatCard icon="dynamic_feed" label="Total Posts" value={stats.totalPosts} sub="today" subValue={stats.postsToday} />
        <StatCard icon="comment" label="Total Comments" value={stats.totalComments} color="text-secondary" bgColor="bg-secondary/10" />
        <StatCard icon="favorite" label="Total Reactions" value={stats.totalReactions} color="text-tertiary" bgColor="bg-tertiary/10" />
        <StatCard icon="flag" label="Pending Reports" value={stats.pendingReports} color="text-error" bgColor="bg-error/10" />
        <StatCard icon="bug_report" label="Bug Reports" value={stats.openBugReports} color="text-orange-500" bgColor="bg-orange-50" />
        <StatCard icon="today" label="Posts Today" value={stats.postsToday} color="text-green-600" bgColor="bg-green-50" />
        <StatCard icon="person_add" label="New Users (7d)" value={stats.profilesThisWeek} color="text-purple-600" bgColor="bg-purple-50" />
      </div>

      {/* Recent Activity — Two Columns */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Posts */}
        <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
          <div className="flex items-center justify-between px-6 py-4 border-b border-outline-variant/30 bg-black/[0.02]">
            <h3 className="font-bold text-lg text-on-surface flex items-center gap-2">
              <span className="material-symbols-outlined text-primary">dynamic_feed</span>
              Recent Posts
            </h3>
            <a href="/admin/posts" className="text-primary text-sm font-medium hover:underline">View All →</a>
          </div>
          <div className="divide-y divide-outline-variant/20">
            {loading ? (
              Array(5).fill(0).map((_, i) => (
                <div key={i} className="p-4 animate-pulse flex gap-3">
                  <div className="h-4 bg-black/10 rounded w-3/4" />
                </div>
              ))
            ) : recentPosts.length === 0 ? (
              <p className="p-6 text-center text-on-surface-variant">No posts yet.</p>
            ) : recentPosts.map(post => (
              <div key={post.id} className="p-4 hover:bg-black/[0.02] transition-colors">
                <div className="flex items-start justify-between gap-2">
                  <div className="flex-1 min-w-0">
                    <p className="text-on-surface text-sm font-medium truncate">{post.body}</p>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="text-xs text-primary bg-primary/10 px-2 py-0.5 rounded-full font-medium">
                        {post.pseudonym}
                      </span>
                      {post.categories && (
                        <span className="text-xs text-on-surface-variant bg-black/5 px-2 py-0.5 rounded-full">
                          {post.categories.name}
                        </span>
                      )}
                    </div>
                  </div>
                  <span className="text-xs text-on-surface-variant whitespace-nowrap">
                    {new Date(post.created_at).toLocaleDateString()}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Reports */}
        <div className="glass-panel rounded-2xl border border-outline-variant shadow-sm overflow-hidden">
          <div className="flex items-center justify-between px-6 py-4 border-b border-outline-variant/30 bg-black/[0.02]">
            <h3 className="font-bold text-lg text-on-surface flex items-center gap-2">
              <span className="material-symbols-outlined text-error">flag</span>
              Recent Reports
            </h3>
            <a href="/admin/reports" className="text-primary text-sm font-medium hover:underline">View All →</a>
          </div>
          <div className="divide-y divide-outline-variant/20">
            {loading ? (
              Array(5).fill(0).map((_, i) => (
                <div key={i} className="p-4 animate-pulse flex gap-3">
                  <div className="h-4 bg-black/10 rounded w-3/4" />
                </div>
              ))
            ) : recentReports.length === 0 ? (
              <p className="p-6 text-center text-on-surface-variant">No reports yet.</p>
            ) : recentReports.map(report => (
              <div key={report.id} className="p-4 hover:bg-black/[0.02] transition-colors">
                <div className="flex items-center justify-between">
                  <div>
                    <span className="text-sm font-medium text-on-surface capitalize">{report.reason.replace('_', ' ')}</span>
                    <p className="text-xs text-on-surface-variant mt-0.5">{new Date(report.created_at).toLocaleString()}</p>
                  </div>
                  <span className={`text-xs font-semibold px-2 py-1 rounded-full ${
                    report.status === 'pending' ? 'bg-orange-100 text-orange-700' :
                    report.status === 'reviewed' ? 'bg-blue-100 text-blue-700' :
                    'bg-green-100 text-green-700'
                  }`}>
                    {report.status}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
