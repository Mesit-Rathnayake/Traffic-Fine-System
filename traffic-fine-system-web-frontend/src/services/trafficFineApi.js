import axios from 'axios'

const AUTH_STORAGE_KEY = 'traffic-fine-auth-session'

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000',
  timeout: 10000,
})

apiClient.interceptors.request.use((config) => {
  try {
    const storedAuth = window.localStorage.getItem(AUTH_STORAGE_KEY)
    if (storedAuth) {
      const authUser = JSON.parse(storedAuth)
      if (authUser?.token) {
        config.headers.Authorization = `Bearer ${authUser.token}`
      }
    }
  } catch {
    // Ignore storage errors and continue without an auth header.
  }

  return config
})

export async function loginUser(credentials) {
  const response = await apiClient.post('/auth/login', credentials)
  return response.data
}

export async function registerUser(payload) {
  const response = await apiClient.post('/auth/register', payload)
  return response.data
}

export async function getFineByReference(referenceNumber) {
  const response = await apiClient.get(`/fines/${encodeURIComponent(referenceNumber)}`)
  return response.data
}

export async function createFine(payload) {
  const response = await apiClient.post('/fines', payload)
  return response.data
}

export async function payFine(payload) {
  const response = await apiClient.post('/payments/pay', payload)
  return response.data
}

export async function getAdminTotalCollections() {
  const response = await apiClient.get('/admin/total-collections')
  return response.data
}

export async function getAdminDistrictCollections() {
  const response = await apiClient.get('/admin/district-collections')
  return response.data
}

export async function getAdminCategoryBreakdown() {
  const response = await apiClient.get('/admin/category-breakdown')
  return response.data
}

export async function checkAdminAccess() {
  const response = await apiClient.get('/fines/admin-only')
  return response.data
}

export async function getAdminUsers(limit = 20) {
  const response = await apiClient.get('/admin/users', { params: { limit } })
  return response.data
}

export async function getAdminFines(limit = 20) {
  const response = await apiClient.get('/admin/fines', { params: { limit } })
  return response.data
}

export async function getAdminPayments(limit = 20) {
  const response = await apiClient.get('/admin/payments', { params: { limit } })
  return response.data
}
