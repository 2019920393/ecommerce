<template>
  <div class="login-page">
    <div class="login-box">
      <h1>电商管理后台</h1>
      <el-form :model="form" :rules="rules" ref="formRef">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="管理员账号" prefix-icon="User" size="large" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="密码" prefix-icon="Lock" size="large" show-password @keyup.enter="handleLogin" />
        </el-form-item>
        <el-button type="primary" size="large" style="width:100%" :loading="loading" @click="handleLogin">登 录</el-button>
      </el-form>
      <p class="tip">默认账号: admin / admin123</p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

const router = useRouter()
const formRef = ref()
const loading = ref(false)
const form = reactive({ username: '', password: '' })
const rules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
  await formRef.value.validate()
  loading.value = true
  setTimeout(() => {
    // 模拟登录验证
    if (form.username === 'admin' && form.password === 'admin123') {
      localStorage.setItem('admin_token', 'admin-token-' + Date.now())
      ElMessage.success('登录成功')
      router.push('/dashboard')
    } else {
      ElMessage.error('账号或密码错误')
    }
    loading.value = false
  }, 500)
}
</script>

<style scoped>
.login-page { height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
.login-box { width: 400px; padding: 40px; background: #fff; border-radius: 12px; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
.login-box h1 { text-align: center; margin-bottom: 30px; color: #333; font-size: 24px; }
.tip { text-align: center; color: #999; font-size: 12px; margin-top: 20px; }
</style>
