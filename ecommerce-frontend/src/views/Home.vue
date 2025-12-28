<template>
  <div class="eshop-home">
    <!-- 顶部品牌横幅 -->
    <div class="brand-banner">
      <div class="banner-content">
        <img src="https://img.icons8.com/fluency/96/shop.png" alt="logo" class="brand-logo" />
        <div class="brand-text">
          <h1>.NET eShop</h1>
          <p>云原生微服务电商平台</p>
        </div>
      </div>
    </div>

    <!-- 主内容区 -->
    <div class="main-content">
      <!-- 左侧分类筛选 -->
      <aside class="sidebar">
        <div class="filter-section">
          <h3>品牌</h3>
          <div class="filter-options">
            <label v-for="brand in brands" :key="brand" class="filter-item">
              <input type="checkbox" v-model="selectedBrands" :value="brand" @change="filterProducts" />
              <span>{{ brand }}</span>
            </label>
          </div>
        </div>
        <div class="filter-section">
          <h3>分类</h3>
          <div class="filter-options">
            <label v-for="cat in categories" :key="cat.id" class="filter-item">
              <input type="checkbox" v-model="selectedCategories" :value="cat.id" @change="filterProducts" />
              <span>{{ cat.name }}</span>
            </label>
          </div>
        </div>
      </aside>

      <!-- 右侧商品列表 -->
      <main class="product-grid">
        <div class="grid-header">
          <span class="result-count">{{ filteredProducts.length }} 件商品</span>
        </div>
        <div class="products" v-loading="loading">
          <div class="product-card" v-for="product in filteredProducts" :key="product.productId" @click="$router.push(`/product/${product.productId}`)">
            <div class="product-image">
              <img :src="product.mainImage || 'https://picsum.photos/200/200?random=' + product.productId" :alt="product.productName" />
            </div>
            <div class="product-info">
              <h4 class="product-name">{{ product.productName }}</h4>
              <p class="product-price">¥{{ product.price }}</p>
            </div>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { productApi } from '@/api'

const products = ref([])
const categories = ref([])
const loading = ref(false)
const selectedBrands = ref([])
const selectedCategories = ref([])

const brands = ['Apple', 'Samsung', 'Huawei', 'Xiaomi', 'OPPO', 'Vivo']

const filteredProducts = computed(() => {
  let result = products.value
  if (selectedBrands.value.length > 0) {
    result = result.filter(p => selectedBrands.value.some(brand => p.productName.includes(brand)))
  }
  if (selectedCategories.value.length > 0) {
    result = result.filter(p => selectedCategories.value.includes(p.categoryId))
  }
  return result
})

const fetchProducts = async () => {
  loading.value = true
  try {
    const res = await productApi.list({ page: 1, size: 50 })
    products.value = res.data?.records || res.data || []
  } finally {
    loading.value = false
  }
}

const fetchCategories = async () => {
  try {
    const res = await productApi.categories()
    categories.value = res.data || []
  } catch (e) {
    console.error('获取分类失败', e)
  }
}

const filterProducts = () => {
  // 触发计算属性重新计算
}

onMounted(() => {
  fetchProducts()
  fetchCategories()
})
</script>

<style scoped>
.eshop-home {
  min-height: 100vh;
  background: #f8f9fa;
}

/* 品牌横幅 */
.brand-banner {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 60px 0;
  text-align: center;
}

.banner-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.brand-logo {
  width: 80px;
  height: 80px;
}

.brand-text h1 {
  font-size: 48px;
  font-weight: 300;
  margin: 0;
  letter-spacing: -1px;
}

.brand-text p {
  font-size: 18px;
  margin: 8px 0 0;
  opacity: 0.9;
}

/* 主内容区 */
.main-content {
  display: flex;
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
  gap: 40px;
}

/* 左侧筛选 */
.sidebar {
  width: 250px;
  flex-shrink: 0;
}

.filter-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.filter-section h3 {
  margin: 0 0 15px;
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.filter-options {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-item {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 0;
}

.filter-item input[type="checkbox"] {
  margin: 0;
}

.filter-item span {
  font-size: 14px;
  color: #666;
}

/* 商品网格 */
.product-grid {
  flex: 1;
}

.grid-header {
  margin-bottom: 20px;
}

.result-count {
  font-size: 14px;
  color: #666;
}

.products {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 20px;
}

.product-card {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.product-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}

.product-image {
  width: 100%;
  height: 200px;
  overflow: hidden;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.product-card:hover .product-image img {
  transform: scale(1.05);
}

.product-info {
  padding: 15px;
}

.product-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  margin: 0 0 8px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.product-price {
  font-size: 16px;
  font-weight: 600;
  color: #e74c3c;
  margin: 0;
}

/* 响应式 */
@media (max-width: 768px) {
  .brand-banner {
    padding: 40px 20px;
  }
  
  .banner-content {
    flex-direction: column;
    gap: 15px;
  }
  
  .brand-text h1 {
    font-size: 32px;
  }
  
  .main-content {
    flex-direction: column;
    padding: 20px;
    gap: 20px;
  }
  
  .sidebar {
    width: 100%;
  }
  
  .products {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 15px;
  }
}
</style>