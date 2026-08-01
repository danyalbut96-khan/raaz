import { Routes, Route } from 'react-router-dom'
import { AuthProvider } from './contexts/AuthContext'
import Layout from './components/Layout'
import PublicLayout from './components/PublicLayout'
import Login from './pages/Login'
import Register from './pages/Register'
import DashboardOverview from './pages/DashboardOverview'
import PostsManagement from './pages/PostsManagement'
import AppSettings from './pages/AppSettings'
import CategoriesManagement from './pages/CategoriesManagement'
import DailyChallenges from './pages/DailyChallenges'
import AdsManagement from './pages/AdsManagement'
import PushNotifications from './pages/PushNotifications'
import AnalyticsDashboard from './pages/AnalyticsDashboard'
import FeaturedStoriesManagement from './pages/FeaturedStoriesManagement'

// Public Pages
import LandingPage from './pages/LandingPage'
import AboutUs from './pages/AboutUs'
import BlogUpdates from './pages/BlogUpdates'
import Careers from './pages/Careers'
import CommunityGuidelines from './pages/CommunityGuidelines'
import ContactUs from './pages/ContactUs'
import DownloadApp from './pages/DownloadApp'
import FeaturesOverview from './pages/FeaturesOverview'
import FAQ from './pages/FAQ'
import PressKit from './pages/PressKit'
import PrivacyTerms from './pages/PrivacyTerms'
import ReleaseNotes from './pages/ReleaseNotes'
import DesignSystem from './pages/DesignSystem'

function App() {
  return (
    <AuthProvider>
      <Routes>
        {/* Auth Routes */}
        <Route path="/login" element={<Login />} />
        <Route path="/admin/registration" element={<Register />} />
        
        {/* Public Marketing Routes */}
        <Route path="/" element={<PublicLayout />}>
          <Route index element={<LandingPage />} />
          <Route path="about" element={<AboutUs />} />
          <Route path="blog" element={<BlogUpdates />} />
          <Route path="careers" element={<Careers />} />
          <Route path="community" element={<CommunityGuidelines />} />
          <Route path="contact" element={<ContactUs />} />
          <Route path="download" element={<DownloadApp />} />
          <Route path="features" element={<FeaturesOverview />} />
          <Route path="faq" element={<FAQ />} />
          <Route path="press" element={<PressKit />} />
          <Route path="privacy" element={<PrivacyTerms />} />
          <Route path="release-notes" element={<ReleaseNotes />} />
          <Route path="design" element={<DesignSystem />} />
        </Route>

        {/* Protected Admin Routes */}
        <Route path="/admin" element={<Layout />}>
          <Route index element={<DashboardOverview />} />
          <Route path="analytics" element={<AnalyticsDashboard />} />
          <Route path="posts" element={<PostsManagement />} />
          <Route path="featured-stories" element={<FeaturedStoriesManagement />} />
          <Route path="categories" element={<CategoriesManagement />} />
          <Route path="challenges" element={<DailyChallenges />} />
          <Route path="ads" element={<AdsManagement />} />
          <Route path="notifications" element={<PushNotifications />} />
          <Route path="settings" element={<AppSettings />} />
        </Route>
      </Routes>
    </AuthProvider>
  )
}

export default App
