# 数据库初始化脚本使用说明

## 📋 概述

本目录包含云原生微服务电商平台的数据库初始化脚本，用于创建订单服务和支付服务所需的数据库和表结构。

## 📁 文件列表

| 文件名 | 说明 | 数据库 | 表数量 |
|--------|------|--------|--------|
| `order_db_init.sql` | 订单服务数据库初始化脚本 | order_db | 5张表 |
| `payment_db_init.sql` | 支付服务数据库初始化脚本 | payment_db | 2张表 |

## 🗄️ 数据库结构

### 订单服务数据库 (order_db)

包含以下5张表：

1. **orders** - 订单表
   - 存储订单基本信息、收货地址、金额、状态等
   - 主键：`order_id`
   - 业务主键：`order_number`（唯一索引）

2. **order_items** - 订单明细表
   - 存储订单中的商品明细（快照）
   - 主键：`item_id`
   - 外键关联：`order_id`, `order_number`

3. **inventory** - 库存表
   - 存储商品库存信息
   - 使用乐观锁（`version`字段）防止超卖
   - 主键：`inventory_id`
   - 唯一索引：`product_id`

4. **inventory_locks** - 库存锁表
   - 存储库存预扣记录
   - 支持订单超时自动释放
   - 主键：`lock_id`
   - 唯一索引：`(order_number, product_id)`

5. **undo_log** - Seata回滚日志表
   - 支持分布式事务回滚
   - Seata AT模式必需表

### 支付服务数据库 (payment_db)

包含以下2张表：

1. **payment_orders** - 支付订单表
   - 存储支付订单信息
   - 主键：`payment_id`
   - 业务主键：`payment_number`（唯一索引）
   - 唯一索引：`order_id`（一个订单只能有一个支付记录）

2. **payment_records** - 支付记录表
   - 存储支付历史记录
   - 用于审计和对账
   - 主键：`record_id`

## 🚀 使用方法

### 方法1：使用MySQL命令行

```bash
# 1. 登录MySQL
mysql -u root -p

# 2. 执行订单服务数据库初始化
source /path/to/sql/order_db_init.sql

# 3. 执行支付服务数据库初始化
source /path/to/sql/payment_db_init.sql
```

### 方法2：使用mysql命令直接执行

```bash
# 执行订单服务数据库初始化
mysql -u root -p < sql/order_db_init.sql

# 执行支付服务数据库初始化
mysql -u root -p < sql/payment_db_init.sql
```

### 方法3：使用MySQL Workbench

1. 打开MySQL Workbench
2. 连接到MySQL服务器
3. 打开SQL脚本文件（File → Open SQL Script）
4. 点击执行按钮（⚡）运行脚本

### 方法4：使用Navicat

1. 打开Navicat
2. 连接到MySQL服务器
3. 右键点击连接 → Execute SQL File
4. 选择脚本文件并执行

## ✅ 验证安装

执行以下SQL验证数据库是否创建成功：

```sql
-- 查看订单服务数据库的表
USE order_db;
SHOW TABLES;

-- 查看支付服务数据库的表
USE payment_db;
SHOW TABLES;

-- 查看库存测试数据
SELECT * FROM order_db.inventory;
```

预期输出：

```
-- order_db 应包含5张表
+----------------------+
| Tables_in_order_db   |
+----------------------+
| inventory            |
| inventory_locks      |
| order_items          |
| orders               |
| undo_log             |
+----------------------+

-- payment_db 应包含2张表
+------------------------+
| Tables_in_payment_db   |
+------------------------+
| payment_orders         |
| payment_records        |
+------------------------+

-- 库存表应包含5条测试数据
```

## 📊 测试数据

订单服务数据库已预置5条库存测试数据：

| product_id | total_stock | available_stock | locked_stock |
|------------|-------------|-----------------|--------------|
| 1001       | 1000        | 1000            | 0            |
| 1002       | 500         | 500             | 0            |
| 1003       | 800         | 800             | 0            |
| 1004       | 300         | 300             | 0            |
| 1005       | 1500        | 1500            | 0            |

## ⚙️ 配置要求

- **MySQL版本**：8.0+
- **字符集**：utf8mb4
- **排序规则**：utf8mb4_unicode_ci
- **存储引擎**：InnoDB
- **权限要求**：需要CREATE DATABASE权限

## 🔧 配置应用程序

创建数据库后，需要在应用程序配置文件中配置数据源：

### 订单服务配置 (application.yml)

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/order_db?useUnicode=true&characterEncoding=utf8mb4&serverTimezone=Asia/Shanghai&useSSL=false
    username: root
    password: your_password
```

### 支付服务配置 (application.yml)

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/payment_db?useUnicode=true&characterEncoding=utf8mb4&serverTimezone=Asia/Shanghai&useSSL=false
    username: root
    password: your_password
```

## 🔒 安全建议

1. **生产环境**：
   - 不要使用root账户
   - 为每个服务创建独立的数据库用户
   - 设置强密码
   - 限制用户权限（只授予必要的权限）

2. **创建专用用户示例**：

```sql
-- 创建订单服务用户
CREATE USER 'order_service'@'%' IDENTIFIED BY 'strong_password_here';
GRANT SELECT, INSERT, UPDATE, DELETE ON order_db.* TO 'order_service'@'%';
FLUSH PRIVILEGES;

-- 创建支付服务用户
CREATE USER 'payment_service'@'%' IDENTIFIED BY 'strong_password_here';
GRANT SELECT, INSERT, UPDATE, DELETE ON payment_db.* TO 'payment_service'@'%';
FLUSH PRIVILEGES;
```

## 🗑️ 清理数据库

如需重新初始化，可以执行以下命令删除数据库：

```sql
-- ⚠️ 警告：此操作将删除所有数据，请谨慎操作！
DROP DATABASE IF EXISTS order_db;
DROP DATABASE IF EXISTS payment_db;
```

## 📚 相关文档

- [14.数据持久化设计文档.md](../14.数据持久化设计文档.md) - 详细的数据库设计文档
- [12.类的精化设计文档.md](../12.类的精化设计文档.md) - 实体类设计
- [13.体系结构的设计.md](../13.体系结构的设计.md) - 系统架构设计

## ❓ 常见问题

### Q1: 执行脚本时报错 "Access denied"
**A**: 检查MySQL用户权限，确保有CREATE DATABASE权限。

### Q2: 字符集问题导致中文乱码
**A**: 确保MySQL服务器配置了utf8mb4字符集，并在连接URL中指定`characterEncoding=utf8mb4`。

### Q3: 如何修改表结构？
**A**: 不建议直接修改初始化脚本，应该创建数据库迁移脚本（如Flyway或Liquibase）。

### Q4: 是否需要手动创建索引？
**A**: 不需要，脚本已包含所有必要的索引定义。

## 📝 更新日志

- **2025-11-20**: 初始版本，创建订单服务和支付服务数据库初始化脚本

---

**维护团队**: 数据库设计团队  
**最后更新**: 2025-11-20