<template>
  <div class="products">
    <el-card>
      <template #header>
        <div class="header">
          <el-input v-model="keyword" placeholder="搜索商品" style="width:250px" clearable @keyup.enter="fetchData">
            <template #append><el-button @click="fetchData"><el-icon><Search /></el-icon></el-button></template>
          </el-input>
          <el-button type="primary" @click="showDialog()"><el-icon><Plus /></el-icon> 新增商品</el-button>
        </div>
      </template>
      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column prop="productId" label="ID" width="80" />
        <el-table-column label="商品图片" width="100">
          <template #default="{ row }"><el-image :src="row.mainImage || 'https://via.placeholder.com/60'" style="width:60px;height:60px" fit="cover" /></template>
        </el-table-column>
        <el-table-column prop="productName" label="商品名称" min-width="200" />
        <el-table-column prop="categoryName" label="分类" width="120" />
        <el-table-column prop="price" label="价格" width="100"><template #default="{ row }">¥{{ row.price }}</template></el-table-column>
        <el-table-column prop="stock" label="库存" width="80" />
        <el-table-column prop="sales" label="销量" width="80" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'ON_SALE' ? 'success' : 'info'">{{ row.status === 'ON_SALE' ? '在售' : '下架' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="showDialog(row)">编辑</el-button>
            <el-button link :type="row.status === 'ON_SALE' ? 'warning' : 'success'" @click="toggleStatus(row)">{{ row.status === 'ON_SALE' ? '下架' : '上架' }}</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination v-model:current-page="page" :total="total" :page-size="10" layout="total, prev, pager, next" @current-change="fetchData" style="margin-top:20px;justify-content:flex-end" />
    </el-card>

    <el-dialog v-model="dialogVisible" :title="form.productId ? '编辑商品' : '新增商品'" width="600px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="商品名称"><el-input v-model="form.productName" /></el-form-item>
        <el-form-item label="分类"><el-cascader v-model="form.categoryId" :options="categories" :props="{ value: 'categoryId', label: 'categoryName', children: 'children', emitPath: false }" /></el-form-item>
        <el-form-item label="价格"><el-input-number v-model="form.price" :min="0" :precision="2" /></el-form-item>
        <el-form-item label="库存"><el-input-number v-model="form.stock" :min="0" /></el-form-item>
        <el-form-item label="主图">
          <el-upload
            class="image-uploader"
            :show-file-list="false"
            :http-request="handleUpload"
            accept="image/*"
          >
            <el-image v-if="form.mainImage" :src="form.mainImage" style="width:120px;height:120px" fit="cover" />
            <el-icon v-else class="uploader-icon"><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">点击上传商品主图，支持jpg/png格式</div>
        </el-form-item>
        <el-form-item label="描述"><el-input v-model="form.description" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { productApi, categoryApi } from '@/api'
import { ElMessage, ElMessageBox } from 'element-plus'

const list = ref([])
const loading = ref(false)
const keyword = ref('')
const page = ref(1)
const total = ref(0)
const dialogVisible = ref(false)
const categories = ref([])
const form = reactive({ productId: null, productName: '', categoryId: null, price: 0, stock: 0, mainImage: '', description: '' })

const fetchData = async () => {
  loading.value = true
  try {
    const res = await productApi.list({ page: page.value, size: 10, keyword: keyword.value })
    list.value = res.data?.records || res.data || []
    total.value = res.data?.total || 0
  } finally { loading.value = false }
}

const fetchCategories = async () => {
  const res = await categoryApi.tree()
  categories.value = res.data || []
}

const showDialog = (row = null) => {
  if (row) {
    Object.assign(form, row)
  } else {
    Object.assign(form, { productId: null, productName: '', categoryId: null, price: 0, stock: 0, mainImage: '', description: '' })
  }
  dialogVisible.value = true
}

const handleSave = async () => {
  if (form.productId) {
    await productApi.update(form.productId, form)
  } else {
    await productApi.create(form)
  }
  ElMessage.success('保存成功')
  dialogVisible.value = false
  fetchData()
}

const handleUpload = async (options) => {
  try {
    const res = await productApi.uploadImage(options.file)
    form.mainImage = res.data.url
    ElMessage.success('上传成功')
  } catch (e) {
    ElMessage.error('上传失败')
  }
}

const toggleStatus = async (row) => {
  const newStatus = row.status === 'ON_SALE' ? 'OFF_SALE' : 'ON_SALE'
  await productApi.updateStatus(row.productId, newStatus)
  ElMessage.success('操作成功')
  fetchData()
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除商品「${row.productName}」吗？此操作不可恢复！`,
      '删除确认',
      { type: 'warning', confirmButtonText: '确定删除', cancelButtonText: '取消' }
    )
    await productApi.delete(row.productId)
    ElMessage.success('删除成功')
    fetchData()
  } catch (e) {
    if (e !== 'cancel') throw e
  }
}

onMounted(() => { fetchData(); fetchCategories() })
</script>

<style scoped>
.header { display: flex; justify-content: space-between; align-items: center; }
.image-uploader { border: 1px dashed #d9d9d9; border-radius: 6px; cursor: pointer; width: 120px; height: 120px; display: flex; align-items: center; justify-content: center; }
.image-uploader:hover { border-color: #409eff; }
.uploader-icon { font-size: 28px; color: #8c939d; }
.upload-tip { font-size: 12px; color: #909399; margin-top: 8px; }
</style>
