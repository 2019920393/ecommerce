<template>
  <div class="categories">
    <el-card>
      <template #header>
        <el-button type="primary" @click="showDialog()"><el-icon><Plus /></el-icon> 新增分类</el-button>
      </template>
      <el-table :data="list" v-loading="loading" row-key="categoryId" default-expand-all>
        <el-table-column prop="categoryId" label="ID" width="80" />
        <el-table-column prop="categoryName" label="分类名称" />
        <el-table-column prop="sortOrder" label="排序" width="80" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '启用' : '禁用' }}</el-tag></template>
        </el-table-column>
        <el-table-column label="操作" width="180">
          <template #default="{ row }">
            <el-button link type="primary" @click="showDialog(row)">编辑</el-button>
            <el-button link type="primary" @click="showDialog(null, row.categoryId)">添加子分类</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="form.categoryId ? '编辑分类' : '新增分类'" width="400px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="分类名称"><el-input v-model="form.categoryName" /></el-form-item>
        <el-form-item label="父分类" v-if="form.parentId"><el-input :value="getParentName(form.parentId)" disabled /></el-form-item>
        <el-form-item label="排序"><el-input-number v-model="form.sortOrder" :min="0" /></el-form-item>
        <el-form-item label="状态"><el-switch v-model="form.status" :active-value="1" :inactive-value="0" /></el-form-item>
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
import { categoryApi } from '@/api'
import { ElMessage } from 'element-plus'

const list = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const form = reactive({ categoryId: null, categoryName: '', parentId: null, sortOrder: 0, status: 1 })

const fetchData = async () => {
  loading.value = true
  try {
    const res = await categoryApi.tree()
    list.value = res.data || []
  } finally { loading.value = false }
}

const getParentName = (parentId) => {
  const find = list.value.find(c => c.categoryId === parentId)
  return find?.categoryName || parentId
}

const showDialog = (row = null, parentId = null) => {
  if (row) {
    Object.assign(form, row)
  } else {
    Object.assign(form, { categoryId: null, categoryName: '', parentId, sortOrder: 0, status: 1 })
  }
  dialogVisible.value = true
}

const handleSave = async () => {
  if (form.categoryId) {
    await categoryApi.update(form.categoryId, { categoryName: form.categoryName, sortOrder: form.sortOrder, status: form.status })
  } else {
    await categoryApi.create(form)
  }
  ElMessage.success('保存成功')
  dialogVisible.value = false
  fetchData()
}

onMounted(fetchData)
</script>
