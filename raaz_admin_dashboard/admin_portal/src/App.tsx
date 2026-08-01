import { Routes, Route } from 'react-router-dom'
import { AuthProvider } from './contexts/AuthContext'
import Layout from './components/Layout'
import Login from './pages/Login'
import Register from './pages/Register'

function DashboardHome() {
  return (
    <div>
      <h2 className="text-3xl font-bold text-on-surface mb-6">Dashboard Overview</h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm">
          <p className="text-on-surface-variant font-medium">Total Users</p>
          <p className="text-4xl font-bold text-primary mt-2">1,248</p>
        </div>
        <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm">
          <p className="text-on-surface-variant font-medium">Active Posts</p>
          <p className="text-4xl font-bold text-primary mt-2">8,432</p>
        </div>
        <div className="glass-panel p-6 rounded-2xl border border-outline-variant shadow-sm">
          <p className="text-on-surface-variant font-medium">Reports Pending</p>
          <p className="text-4xl font-bold text-red-500 mt-2">24</p>
        </div>
      </div>
    </div>
  )
}

function App() {
  return (
    <AuthProvider>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/admin/registration" element={<Register />} />
        
        {/* Protected Routes */}
        <Route path="/" element={<Layout />}>
          <Route index element={<DashboardHome />} />
        </Route>
      </Routes>
    </AuthProvider>
  )
}

export default App
