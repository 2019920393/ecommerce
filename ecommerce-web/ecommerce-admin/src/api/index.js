import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'

const api = axios.create({ baseURL: '/api/v1', timeout: 10000 })

api.interceptors.request.use(config => {
  const token = localStorage.getItem('admin_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  res => {
    if (res.data.code !== 200) {
      ElMessage.error(res.data.message || '请求失败')
      return Promise.reject(res.data)
    }
    return res.data
  },
  err => {
    if (err.response?.status === 401) {
      localStorage.removeItem('admin_token')
      router.push('/login')
    }
    ElMessage.error(err.message || '网络错误')
    return Promise.reject(err)
  }
)

export const productApi = {
  list: params => api.get('/products', { params }),
  detail: id => api.get(`/products/${id}`),
  create: data => api.post('/products', data),
  update: (id, data) => api.put(`/products/${id}`, data),
  updateStatus: (id, status) => api.put(`/products/${id}/status`, null, { params: { status } }),
  delete: id => api.delete(`/products/${id}`),
  uploadImage: file => {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/products/upload', formData)
  }
}

export const categoryApi = {
  tree: () => api.get('/categories/tree'),
  create: data => api.post('/categories', data),
  update: (id, data) => api.put(`/categories/${id}`, data),
  updateStatus: (id, status) => api.put(`/categories/${id}/status`, null, { params: { status } })
}

export const orderApi = {
  list: params => api.get('/orders/list', { params }),
  detail: orderNumber => api.get(`/orders/${orderNumber}`),
  updateStatus: (orderNumber, status) => api.put(`/orders/${orderNumber}/status`, null, { params: { status } })
}

export const paymentApi = {
  list: params => api.get('/payments', { params }),
  detail: paymentNumber => api.get(`/payments/${paymentNumber}`)
}

export const userApi = {
  list: params => api.get('/users/list', { params }),
  detail: id => api.get(`/users/${id}`)
}

export default api
