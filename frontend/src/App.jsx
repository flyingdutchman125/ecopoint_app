import { useEffect, useState } from 'react'
import './App.css'

const API_BASE = '/api'
const initialLoginForm = { email: '', password: '' }
const initialUserForm = { name: '', email: '', password: '', phone: '' }
const initialCollectorForm = { name: '', email: '', password: '', phone: '', vehicle_type: '', plate_number: '', ktp_photo: null }

function App() {
  const [view, setView] = useState('login')
  const [user, setUser] = useState(null)
  const [token, setToken] = useState('')
  const [loginForm, setLoginForm] = useState(initialLoginForm)
  const [registerUserForm, setRegisterUserForm] = useState(initialUserForm)
  const [registerCollectorForm, setRegisterCollectorForm] = useState(initialCollectorForm)
  const [pendingCollectors, setPendingCollectors] = useState([])
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    const storedToken = localStorage.getItem('ecopoint_token')
    const storedUser = localStorage.getItem('ecopoint_user')
    if (storedToken && storedUser) {
      setToken(storedToken)
      setUser(JSON.parse(storedUser))
      setView('dashboard')
    }
  }, [])

  useEffect(() => {
    if (token) {
      localStorage.setItem('ecopoint_token', token)
    } else {
      localStorage.removeItem('ecopoint_token')
    }
  }, [token])

  useEffect(() => {
    if (user) {
      localStorage.setItem('ecopoint_user', JSON.stringify(user))
    } else {
      localStorage.removeItem('ecopoint_user')
    }
  }, [user])

  useEffect(() => {
    if (user?.role === 'admin') {
      fetchPendingCollectors()
    }
  }, [user])

  const isAdmin = user?.role === 'admin'

  const apiFetch = async (path, options = {}) => {
    const { method = 'GET', body = null, formData = null, extraHeaders = {} } = options
    const headers = { ...extraHeaders }
    if (token) {
      headers.Authorization = `Bearer ${token}`
    }
    const config = { method, headers }

    if (formData) {
      config.body = formData
    } else if (body !== null) {
      headers['Content-Type'] = 'application/json'
      config.body = JSON.stringify(body)
    }

    const response = await fetch(`${API_BASE}${path}`, config)
    const data = await response.json().catch(() => null)
    if (!response.ok) {
      throw new Error(data?.message || `Request failed with status ${response.status}`)
    }
    return data
  }

  const resetFeedback = () => {
    setError('')
    setMessage('')
  }

  const handleModeChange = (mode) => {
    resetFeedback()
    setView(mode)
  }

  const handleLogin = async (event) => {
    event.preventDefault()
    resetFeedback()

    try {
      setLoading(true)
      const data = await apiFetch('/auth/login', {
        method: 'POST',
        body: loginForm,
      })
      setToken(data.token)
      setUser(data.user)
      setMessage('Login berhasil. Selamat datang, ' + data.user.name)
      setView('dashboard')
      setLoginForm(initialLoginForm)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleRegisterUser = async (event) => {
    event.preventDefault()
    resetFeedback()

    try {
      setLoading(true)
      await apiFetch('/auth/register/user', {
        method: 'POST',
        body: registerUserForm,
      })
      setMessage('Pendaftaran pengguna berhasil. Silakan login.')
      setRegisterUserForm(initialUserForm)
      setView('login')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleRegisterCollector = async (event) => {
    event.preventDefault()
    resetFeedback()

    try {
      setLoading(true)
      const formData = new FormData()
      Object.entries(registerCollectorForm).forEach(([key, value]) => {
        if (key === 'ktp_photo') {
          if (value) {
            formData.append(key, value)
          }
        } else {
          formData.append(key, value)
        }
      })
      await apiFetch('/auth/register/collector', {
        method: 'POST',
        formData,
      })
      setMessage('Pendaftaran mitra berhasil. Tunggu verifikasi admin.')
      setRegisterCollectorForm(initialCollectorForm)
      setView('login')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const fetchPendingCollectors = async () => {
    try {
      setLoading(true)
      const collectors = await apiFetch('/admin/pending-collectors')
      setPendingCollectors(collectors)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const verifyCollector = async (id, action) => {
    resetFeedback()
    try {
      setLoading(true)
      await apiFetch(`/admin/verify-collector/${id}`, {
        method: 'PUT',
        body: { action },
      })
      setMessage(`Collector ${action}d successfully`)
      fetchPendingCollectors()
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const logout = () => {
    setUser(null)
    setToken('')
    setView('login')
    resetFeedback()
  }

  return (
    <div className="app-shell">
      <header className="app-header">
        <div>
          <h1>EcoPoint Web</h1>
          <p>Front-end baru untuk backend EcoPoint. Gunakan formulir untuk mendaftar, login, dan mengelola pending collector.</p>
        </div>
        {user && (
          <div className="user-box">
            <div>{user.name}</div>
            <div className="user-role">{user.role}</div>
            <button className="link-button" onClick={logout}>Logout</button>
          </div>
        )}
      </header>

      <main className="app-content">
        <aside className="app-menu">
          {!user && (
            <>
              <button onClick={() => handleModeChange('login')} className={view === 'login' ? 'active' : ''}>Login</button>
              <button onClick={() => handleModeChange('register_user')} className={view === 'register_user' ? 'active' : ''}>Daftar Pengguna</button>
              <button onClick={() => handleModeChange('register_collector')} className={view === 'register_collector' ? 'active' : ''}>Daftar Mitra</button>
            </>
          )}
          {user && <button onClick={() => setView('dashboard')} className={view === 'dashboard' ? 'active' : ''}>Dashboard</button>}
          {isAdmin && <button onClick={() => setView('admin')} className={view === 'admin' ? 'active' : ''}>Admin Pending</button>}
        </aside>

        <section className="app-panel">
          {message && <div className="alert success">{message}</div>}
          {error && <div className="alert error">{error}</div>}
          {loading && <div className="alert info">Loading...</div>}

          {!user && view === 'login' && (
            <div className="card">
              <h2>Login</h2>
              <form onSubmit={handleLogin}>
                <label>
                  Email
                  <input type="email" value={loginForm.email} onChange={(e) => setLoginForm({ ...loginForm, email: e.target.value })} required />
                </label>
                <label>
                  Password
                  <input type="password" value={loginForm.password} onChange={(e) => setLoginForm({ ...loginForm, password: e.target.value })} required />
                </label>
                <button type="submit">Login</button>
              </form>
            </div>
          )}

          {!user && view === 'register_user' && (
            <div className="card">
              <h2>Daftar Warga</h2>
              <form onSubmit={handleRegisterUser}>
                <label>
                  Nama
                  <input type="text" value={registerUserForm.name} onChange={(e) => setRegisterUserForm({ ...registerUserForm, name: e.target.value })} required />
                </label>
                <label>
                  Email
                  <input type="email" value={registerUserForm.email} onChange={(e) => setRegisterUserForm({ ...registerUserForm, email: e.target.value })} required />
                </label>
                <label>
                  No. HP
                  <input type="text" value={registerUserForm.phone} onChange={(e) => setRegisterUserForm({ ...registerUserForm, phone: e.target.value })} required />
                </label>
                <label>
                  Password
                  <input type="password" value={registerUserForm.password} onChange={(e) => setRegisterUserForm({ ...registerUserForm, password: e.target.value })} required />
                </label>
                <button type="submit">Daftar Pengguna</button>
              </form>
            </div>
          )}

          {!user && view === 'register_collector' && (
            <div className="card">
              <h2>Daftar Mitra Pengepul</h2>
              <form onSubmit={handleRegisterCollector}>
                <label>
                  Nama
                  <input type="text" value={registerCollectorForm.name} onChange={(e) => setRegisterCollectorForm({ ...registerCollectorForm, name: e.target.value })} required />
                </label>
                <label>
                  Email
                  <input type="email" value={registerCollectorForm.email} onChange={(e) => setRegisterCollectorForm({ ...registerCollectorForm, email: e.target.value })} required />
                </label>
                <label>
                  No. HP
                  <input type="text" value={registerCollectorForm.phone} onChange={(e) => setRegisterCollectorForm({ ...registerCollectorForm, phone: e.target.value })} required />
                </label>
                <label>
                  Password
                  <input type="password" value={registerCollectorForm.password} onChange={(e) => setRegisterCollectorForm({ ...registerCollectorForm, password: e.target.value })} required />
                </label>
                <label>
                  Jenis Kendaraan
                  <input type="text" value={registerCollectorForm.vehicle_type} onChange={(e) => setRegisterCollectorForm({ ...registerCollectorForm, vehicle_type: e.target.value })} required />
                </label>
                <label>
                  Nomor Plat
                  <input type="text" value={registerCollectorForm.plate_number} onChange={(e) => setRegisterCollectorForm({ ...registerCollectorForm, plate_number: e.target.value })} required />
                </label>
                <label>
                  Upload KTP
                  <input type="file" accept="image/*" onChange={(e) => setRegisterCollectorForm({ ...registerCollectorForm, ktp_photo: e.target.files?.[0] || null })} required />
                </label>
                <button type="submit">Daftar Mitra</button>
              </form>
            </div>
          )}

          {user && view === 'dashboard' && (
            <div className="card">
              <h2>Dashboard</h2>
              <p>Anda masuk sebagai <strong>{user.role}</strong>.</p>
              <p>Selamat datang, {user.name}!</p>
              <p>Gunakan menu di sebelah kiri untuk mengakses fitur.</p>
            </div>
          )}

          {user && view === 'admin' && isAdmin && (
            <div className="card">
              <h2>Pending Collector Verification</h2>
              {pendingCollectors.length === 0 ? (
                <p>Tidak ada collector pending.</p>
              ) : (
                <div className="collector-list">
                  {pendingCollectors.map((collector) => (
                    <div className="collector-item" key={collector.id}>
                      <div>
                        <strong>{collector.name}</strong>
                        <span>{collector.email}</span>
                      </div>
                      <div>{collector.phone}</div>
                      <div>{collector.vehicle_type} / {collector.plate_number}</div>
                      <div>
                        {collector.ktp_photo_url ? (
                          <a href={collector.ktp_photo_url} target="_blank" rel="noreferrer">Lihat KTP</a>
                        ) : (
                          <span>Tidak ada KTP</span>
                        )}
                      </div>
                      <div className="collector-actions">
                        <button onClick={() => verifyCollector(collector.id, 'approve')}>Approve</button>
                        <button onClick={() => verifyCollector(collector.id, 'reject')} className="danger">Reject</button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </section>
      </main>
    </div>
  )
}

export default App
