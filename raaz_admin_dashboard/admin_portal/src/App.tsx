import { Routes, Route } from 'react-router-dom'
import { AuthProvider } from './contexts/AuthContext'
import Layout from './components/Layout'
import Login from './pages/Login'
import Register from './pages/Register'
import DashboardOverview from './pages/DashboardOverview'
import PostsManagement from './pages/PostsManagement'
import AppSettings from './pages/AppSettings'
import CategoriesManagement from './pages/CategoriesManagement'
import DailyChallenges from './pages/DailyChallenges'
import AdsManagement from './pages/AdsManagement'
import PushNotifications from './pages/PushNotifications'

function App() {
  return (
    <AuthProvider>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/admin/registration" element={<Register />} />
        
        {/* Protected Routes */}
        <Route path="/" element={<Layout />}>
          <Route index element={<DashboardOverview />} />
          <Route path="posts" element={<PostsManagement />} />
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
