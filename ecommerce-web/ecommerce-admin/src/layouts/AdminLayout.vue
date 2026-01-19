<template>
  <el-container class="admin-layout">
    <el-aside width="220px" class="aside">
      <div class="logo">
        <el-icon :size="24"><Shop /></el-icon>
        <span>电商管理后台</span>
      </div>
      <el-menu :default-active="$route.path" router background-color="#001529" text-color="#ffffffa6" active-text-color="#fff">
        <el-menu-item index="/dashboard"><el-icon><DataAnalysis /></el-icon><span>控制台</span></el-menu-item>
        <el-menu-item index="/products"><el-icon><Goods /></el-icon><span>商品管理</span></el-menu-item>
        <el-menu-item index="/categories"><el-icon><Menu /></el-icon><span>分类管理</span></el-menu-item>
        <el-menu-item index="/orders"><el-icon><List /></el-icon><span>订单管理</span></el-menu-item>
        <el-menu-item index="/payments"><el-icon><Money /></el-icon><span>支付记录</span></el-menu-item>
        <el-menu-item index="/users"><el-icon><User /></el-icon><span>用户管理</span></el-menu-item>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header class="header">
        <span class="title">{{ $route.meta.title }}</span>
        <el-dropdown @command="handleCommand">
          <span class="user"><el-avatar :size="32">A</el-avatar> 管理员</span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </el-header>
      <el-main class="main"><router-view /></el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { useRouter } from 'vue-router'
const router = useRouter()
const handleCommand = (cmd) => {
  if (cmd === 'logout') {
    localStorage.removeItem('admin_token')
    router.push('/login')
  }
}
</script>

<style scoped>
.admin-layout { height: 100vh; }
.aside { background: #001529; }
.logo { height: 60px; display: flex; align-items: center; justify-content: center; gap: 10px; color: #fff; font-size: 16px; font-weight: 600; border-bottom: 1px solid #ffffff1a; }
.header { background: #fff; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 1px 4px rgba(0,0,0,0.1); }
.title { font-size: 18px; font-weight: 500; }
.user { display: flex; align-items: center; gap: 8px; cursor: pointer; }
.main { background: #f0f2f5; }
</style>
