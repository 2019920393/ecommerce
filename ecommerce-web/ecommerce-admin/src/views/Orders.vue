<template>
  <div class="orders">
    <el-card>
      <template #header>
        <el-radio-group v-model="status" @change="fetchData">
          <el-radio-button label="">全部</el-radio-button>
          <el-radio-button label="PENDING_PAYMENT">待支付</el-radio-button>
          <el-radio-button label="PENDING_SHIPMENT">待发货</el-radio-button>
          <el-radio-button label="SHIPPED">已发货</el-radio-button>
          <el-radio-button label="COMPLETED">已完成</el-radio-button>
          <el-radio-button label="CANCELLED">已取消</el-radio-button>
        </el-radio-group>
      </template>
      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column prop="orderNumber" label="订单号" width="200" />
        <el-table-column prop="userId" label="用户ID" width="80" />
        <el-table-column prop="totalAmount" label="订单金额" width="120"><template #default="{ row }">¥{{ row.totalAmount }}</template></el-table-column>
        <el-table-column prop="status" label="状态" width="120">
          <template #default="{ row }"><el-tag :type="statusType(row.status)">{{ statusText(row.status) }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="createTime" label="下单时间" width="180"><template #default="{ row }">{{ formatTime(row.createTime) }}</template></el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="showDetail(row)">详情</el-button>
            <el-button link type="success" v-if="row.status === 'PENDING_SHIPMENT'" @click="handleShip(row)">发货</el-button>
            <el-button link type="danger" v-if="row.status === 'PENDING_PAYMENT'" @click="handleCancel(row)">取消</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination v-model:current-page="page" :total="total" :page-size="10" layout="total, prev, pager, next" @current-change="fetchData" style="margin-top:20px;justify-content:flex-end" />
    </el-card>

    <el-drawer v-model="drawerVisible" title="订单详情" size="500px">
      <template v-if="detail">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="订单号">{{ detail.orderNumber }}</el-descriptions-item>
          <el-descriptions-item label="用户ID">{{ detail.userId }}</el-descriptions-item>
          <el-descriptions-item label="订单状态"><el-tag :type="statusType(detail.status)">{{ statusText(detail.status) }}</el-tag></el-descriptions-item>
          <el-descriptions-item label="订单金额">¥{{ detail.totalAmount }}</el-descriptions-item>
          <el-descriptions-item label="下单时间">{{ formatTime(detail.createTime) }}</el-descriptions-item>
          <el-descriptions-item label="收货人">{{ detail.shippingAddress?.receiverName }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ detail.shippingAddress?.receiverPhone }}</el-descriptions-item>
          <el-descriptions-item label="收货地址">{{ detail.shippingAddress?.province }}{{ detail.shippingAddress?.city }}{{ detail.shippingAddress?.district }}{{ detail.shippingAddress?.detailAddress }}</el-descriptions-item>
        </el-descriptions>
        <h4 style="margin:20px 0 10px">商品明细</h4>
        <el-table :data="detail.items" size="small">
          <el-table-column prop="productName" label="商品" />
          <el-table-column prop="price" label="单价" width="80"><template #default="{ row }">¥{{ row.price }}</template></el-table-column>
          <el-table-column prop="quantity" label="数量" width="60" />
        </el-table>
      </template>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { orderApi } from '@/api'
import { ElMessage, ElMessageBox } from 'element-plus'

const list = ref([])
const loading = ref(false)
const status = ref('')
const page = ref(1)
const total = ref(0)
const drawerVisible = ref(false)
const detail = ref(null)

const statusMap = { PENDING_PAYMENT: '待支付', PENDING_SHIPMENT: '待发货', SHIPPED: '已发货', COMPLETED: '已完成', CANCELLED: '已取消' }
const statusText = s => statusMap[s] || s
const statusType = s => ({ PENDING_PAYMENT: 'warning', PENDING_SHIPMENT: 'info', SHIPPED: '', COMPLETED: 'success', CANCELLED: 'danger' }[s])
const formatTime = t => t ? new Date(t).toLocaleString() : ''

const fetchData = async () => {
  loading.value = true
  try {
    const res = await orderApi.list({ page: page.value, size: 10, status: status.value || undefined })
    list.value = res.data?.records || res.data || []
    total.value = res.data?.total || 0
  } finally { loading.value = false }
}

const showDetail = async (row) => {
  const res = await orderApi.detail(row.orderNumber)
  detail.value = res.data
  drawerVisible.value = true
}

const handleShip = async (row) => {
  await ElMessageBox.confirm('确认发货？', '提示')
  await orderApi.updateStatus(row.orderNumber, 'SHIPPED')
  ElMessage.success('发货成功')
  fetchData()
}

const handleCancel = async (row) => {
  await ElMessageBox.confirm('确认取消订单？', '提示', { type: 'warning' })
  await orderApi.updateStatus(row.orderNumber, 'CANCELLED')
  ElMessage.success('已取消')
  fetchData()
}

onMounted(fetchData)
</script>
