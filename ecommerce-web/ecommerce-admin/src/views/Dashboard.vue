<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <el-col :span="6" v-for="stat in stats" :key="stat.title">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" :style="{ background: stat.color }">
            <el-icon :size="28"><component :is="stat.icon" /></el-icon>
          </div>
          <div class="stat-info">
            <p class="stat-value">{{ stat.value }}</p>
            <p class="stat-title">{{ stat.title }}</p>
          </div>
        </el-card>
      </el-col>
    </el-row>
    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="16">
        <el-card>
          <template #header>近7天订单趋势</template>
          <div ref="chartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card>
          <template #header>订单状态分布</template>
          <div ref="pieRef" style="height: 300px"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import * as echarts from 'echarts'
import { productApi, orderApi, userApi } from '@/api'

const stats = reactive([
  { title: '今日订单', value: '0', icon: 'ShoppingCart', color: '#409eff' },
  { title: '今日销售额', value: '¥0', icon: 'Money', color: '#67c23a' },
  { title: '商品总数', value: '0', icon: 'Goods', color: '#e6a23c' },
  { title: '用户总数', value: '0', icon: 'User', color: '#f56c6c' }
])

const chartRef = ref()
const pieRef = ref()

const fetchStats = async () => {
  try {
    // 获取商品总数
    const productRes = await productApi.list({ page: 1, size: 1 })
    stats[2].value = (productRes.data?.total || productRes.data?.length || 0).toString()
    
    // 获取订单数据
    const orderRes = await orderApi.list({ page: 1, size: 1000 })
    const orders = orderRes.data?.records || orderRes.data || []
    
    // 今日订单
    const today = new Date().toDateString()
    const todayOrders = orders.filter(o => new Date(o.createTime).toDateString() === today)
    stats[0].value = todayOrders.length.toString()
    
    // 今日销售额
    const todaySales = todayOrders.reduce((sum, o) => sum + (parseFloat(o.totalAmount) || 0), 0)
    stats[1].value = '¥' + todaySales.toFixed(2)
    
    // 订单状态分布
    const statusCount = { PENDING_PAYMENT: 0, PENDING_SHIPMENT: 0, SHIPPED: 0, COMPLETED: 0, CANCELLED: 0 }
    orders.forEach(o => { if (statusCount[o.status] !== undefined) statusCount[o.status]++ })
    
    // 更新饼图
    if (pieRef.value) {
      const pie = echarts.init(pieRef.value)
      pie.setOption({
        tooltip: { trigger: 'item' },
        series: [{
          type: 'pie', radius: ['40%', '70%'],
          data: [
            { value: statusCount.PENDING_PAYMENT, name: '待支付' },
            { value: statusCount.PENDING_SHIPMENT, name: '待发货' },
            { value: statusCount.SHIPPED, name: '已发货' },
            { value: statusCount.COMPLETED, name: '已完成' },
            { value: statusCount.CANCELLED, name: '已取消' }
          ]
        }]
      })
    }
    
    // 获取用户总数
    const userRes = await userApi.list({ page: 1, size: 1 })
    stats[3].value = (userRes.data?.total || userRes.data?.length || 0).toString()
  } catch (e) {
    console.error('获取统计数据失败', e)
  }
}

onMounted(async () => {
  await fetchStats()
  
  // 折线图 - 近7天订单趋势
  if (chartRef.value) {
    const chart = echarts.init(chartRef.value)
    const days = []
    const counts = []
    for (let i = 6; i >= 0; i--) {
      const d = new Date()
      d.setDate(d.getDate() - i)
      days.push((d.getMonth() + 1) + '/' + d.getDate())
      counts.push(Math.floor(Math.random() * 50) + 10) // 暂用模拟数据
    }
    chart.setOption({
      tooltip: { trigger: 'axis' },
      xAxis: { type: 'category', data: days },
      yAxis: { type: 'value' },
      series: [{ data: counts, type: 'line', smooth: true, areaStyle: { opacity: 0.3 } }]
    })
  }
})
</script>

<style scoped>
.stat-card { display: flex; align-items: center; padding: 10px; }
.stat-card :deep(.el-card__body) { display: flex; align-items: center; gap: 15px; width: 100%; }
.stat-icon { width: 60px; height: 60px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #fff; }
.stat-value { font-size: 24px; font-weight: 600; color: #333; margin: 0; }
.stat-title { font-size: 14px; color: #999; margin: 5px 0 0; }
</style>
