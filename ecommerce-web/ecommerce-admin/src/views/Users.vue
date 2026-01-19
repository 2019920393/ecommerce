<template>
  <div class="users">
    <el-card>
      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column prop="userId" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="150" />
        <el-table-column prop="phone" label="手机号" width="150" />
        <el-table-column prop="email" label="邮箱" width="200" />
        <el-table-column prop="role" label="角色" width="100">
          <template #default="{ row }"><el-tag :type="row.role === 'ADMIN' ? 'danger' : ''">{{ row.role === 'ADMIN' ? '管理员' : '用户' }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }"><el-tag :type="row.status === 'NORMAL' ? 'success' : 'danger'">{{ row.status === 'NORMAL' ? '正常' : '冻结' }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="createTime" label="注册时间" width="180"><template #default="{ row }">{{ formatTime(row.createTime) }}</template></el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="{ row }">
            <el-button link type="primary" @click="showDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination v-model:current-page="page" :total="total" :page-size="10" layout="total, prev, pager, next" @current-change="fetchData" style="margin-top:20px;justify-content:flex-end" />
    </el-card>

    <el-drawer v-model="drawerVisible" title="用户详情" size="400px">
      <el-descriptions :column="1" border v-if="detail">
        <el-descriptions-item label="用户ID">{{ detail.userId }}</el-descriptions-item>
        <el-descriptions-item label="用户名">{{ detail.username }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ detail.phone }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{ detail.email }}</el-descriptions-item>
        <el-descriptions-item label="昵称">{{ detail.nickname }}</el-descriptions-item>
        <el-descriptions-item label="角色">{{ detail.role === 'ADMIN' ? '管理员' : '普通用户' }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ detail.status === 'NORMAL' ? '正常' : '冻结' }}</el-descriptions-item>
        <el-descriptions-item label="注册时间">{{ formatTime(detail.createTime) }}</el-descriptions-item>
      </el-descriptions>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { userApi } from '@/api'

const list = ref([])
const loading = ref(false)
const page = ref(1)
const total = ref(0)
const drawerVisible = ref(false)
const detail = ref(null)

const formatTime = t => t ? new Date(t).toLocaleString() : '-'

const fetchData = async () => {
  loading.value = true
  try {
    const res = await userApi.list({ page: page.value, size: 10 })
    list.value = res.data?.records || res.data || []
    total.value = res.data?.total || 0
  } finally { loading.value = false }
}

const showDetail = async (row) => {
  const res = await userApi.detail(row.userId)
  detail.value = res.data
  drawerVisible.value = true
}

onMounted(fetchData)
</script>
