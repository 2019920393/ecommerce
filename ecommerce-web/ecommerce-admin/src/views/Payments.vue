<template>
  <div class="payments">
    <el-card>
      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column prop="paymentNumber" label="支付单号" width="200" />
        <el-table-column prop="orderNumber" label="订单号" width="200" />
        <el-table-column prop="amount" label="支付金额" width="120"><template #default="{ row }">¥{{ row.amount }}</template></el-table-column>
        <el-table-column prop="paymentMethod" label="支付方式" width="100">
          <template #default="{ row }">{{ row.paymentMethod === 'ALIPAY' ? '支付宝' : '微信' }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'SUCCESS' ? 'success' : row.status === 'PENDING' ? 'warning' : 'danger'">
              {{ { PENDING: '待支付', SUCCESS: '成功', FAILED: '失败', EXPIRED: '已过期' }[row.status] }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180"><template #default="{ row }">{{ formatTime(row.createTime) }}</template></el-table-column>
        <el-table-column prop="payTime" label="支付时间" width="180"><template #default="{ row }">{{ formatTime(row.payTime) }}</template></el-table-column>
      </el-table>
      <el-pagination v-model:current-page="page" :total="total" :page-size="10" layout="total, prev, pager, next" @current-change="fetchData" style="margin-top:20px;justify-content:flex-end" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { paymentApi } from '@/api'

const list = ref([])
const loading = ref(false)
const page = ref(1)
const total = ref(0)

const formatTime = t => t ? new Date(t).toLocaleString() : '-'

const fetchData = async () => {
  loading.value = true
  try {
    const res = await paymentApi.list({ page: page.value, size: 10 })
    list.value = res.data?.records || res.data || []
    total.value = res.data?.total || 0
  } finally { loading.value = false }
}

onMounted(fetchData)
</script>
