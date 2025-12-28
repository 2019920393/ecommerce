-- ============================================
-- 订单服务数据库初始化脚本
-- 数据库: order_db
-- 包含表: orders, order_items, inventory, inventory_locks, undo_log
-- 创建时间: 2025-11-20
-- ============================================

-- 创建订单服务数据库
CREATE DATABASE IF NOT EXISTS `order_db` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `order_db`;

-- ============================================
-- 1. 订单表 (orders)
-- ============================================
CREATE TABLE `orders` (
  `order_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '订单ID，主键',
  `order_number` VARCHAR(18) NOT NULL COMMENT '订单号，格式ORD+时间戳+随机数',
  `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
  
  -- 收货信息
  `recipient_name` VARCHAR(20) NOT NULL COMMENT '收货人姓名',
  `recipient_phone` VARCHAR(11) NOT NULL COMMENT '收货人电话',
  `shipping_address` VARCHAR(200) NOT NULL COMMENT '完整收货地址',
  `province` VARCHAR(20) NOT NULL COMMENT '省',
  `city` VARCHAR(20) NOT NULL COMMENT '市',
  `district` VARCHAR(20) NOT NULL COMMENT '区',
  `detail_address` VARCHAR(100) NOT NULL COMMENT '详细地址',
  
  -- 金额信息
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
  `product_amount` DECIMAL(10,2) NOT NULL COMMENT '商品总价',
  `shipping_fee` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '运费',
  `discount` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '优惠金额',
  
  -- 状态和时间
  `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING_PAYMENT' COMMENT '订单状态：PENDING_PAYMENT/PENDING_SHIPMENT/PENDING_RECEIPT/COMPLETED/CANCELLED',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `pay_time` DATETIME NULL COMMENT '支付时间',
  `expire_time` DATETIME NOT NULL COMMENT '超时时间，创建后30分钟',
  `cancel_time` DATETIME NULL COMMENT '取消时间',
  
  -- 其他
  `remark` VARCHAR(500) NULL COMMENT '订单备注',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '逻辑删除标记：0-未删除，1-已删除',
  
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_order_number` (`order_number`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_expire_time` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- ============================================
-- 2. 订单明细表 (order_items)
-- ============================================
CREATE TABLE `order_items` (
  `item_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID，主键',
  `order_id` BIGINT(20) NOT NULL COMMENT '订单ID',
  `order_number` VARCHAR(18) NOT NULL COMMENT '订单号',
  
  -- 商品信息（快照）
  `product_id` BIGINT(20) NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(50) NOT NULL COMMENT '商品名称',
  `product_image` VARCHAR(255) NOT NULL COMMENT '商品图片URL',
  `specification` VARCHAR(100) NULL COMMENT '商品规格',
  
  -- 价格和数量
  `unit_price` DECIMAL(10,2) NOT NULL COMMENT '单价',
  `quantity` INT(11) NOT NULL COMMENT '购买数量',
  `subtotal` DECIMAL(10,2) NOT NULL COMMENT '小计金额',
  
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  
  PRIMARY KEY (`item_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_number` (`order_number`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单明细表';

-- ============================================
-- 3. 库存表 (inventory)
-- ============================================
CREATE TABLE `inventory` (
  `inventory_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '库存ID，主键',
  `product_id` BIGINT(20) NOT NULL COMMENT '商品ID',
  
  -- 库存数量
  `total_stock` INT(11) NOT NULL DEFAULT 0 COMMENT '总库存数量',
  `available_stock` INT(11) NOT NULL DEFAULT 0 COMMENT '可用库存',
  `locked_stock` INT(11) NOT NULL DEFAULT 0 COMMENT '预扣库存（锁定但未实际扣减）',
  
  -- 乐观锁
  `version` INT(11) NOT NULL DEFAULT 0 COMMENT '版本号，乐观锁',
  
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  
  PRIMARY KEY (`inventory_id`),
  UNIQUE KEY `uk_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存表';

-- ============================================
-- 4. 库存锁表 (inventory_locks)
-- ============================================
CREATE TABLE `inventory_locks` (
  `lock_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '锁ID，主键',
  `product_id` BIGINT(20) NOT NULL COMMENT '商品ID',
  `order_number` VARCHAR(18) NOT NULL COMMENT '订单号',
  `locked_quantity` INT(11) NOT NULL COMMENT '锁定数量',
  `lock_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '锁定时间',
  `expire_time` DATETIME NOT NULL COMMENT '过期时间，锁定后30分钟',
  `status` VARCHAR(20) NOT NULL DEFAULT 'LOCKED' COMMENT '状态：LOCKED-已锁定，DEDUCTED-已扣减，RELEASED-已释放',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  PRIMARY KEY (`lock_id`),
  UNIQUE KEY `uk_order_product` (`order_number`, `product_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_expire_time` (`expire_time`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存锁表';

-- ============================================
-- 5. Seata回滚日志表 (undo_log)
-- ============================================
CREATE TABLE `undo_log` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `branch_id` BIGINT(20) NOT NULL COMMENT '分支事务ID',
  `xid` VARCHAR(100) NOT NULL COMMENT '全局事务ID',
  `context` VARCHAR(128) NOT NULL COMMENT '上下文',
  `rollback_info` LONGBLOB NOT NULL COMMENT '回滚信息',
  `log_status` INT(11) NOT NULL COMMENT '日志状态：0-正常，1-已回滚',
  `log_created` DATETIME NOT NULL COMMENT '创建时间',
  `log_modified` DATETIME NOT NULL COMMENT '修改时间',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_undo_log` (`xid`, `branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Seata回滚日志表';

-- ============================================
-- 6. 插入测试数据
-- ============================================

-- 插入测试库存数据
INSERT INTO `inventory` (`product_id`, `total_stock`, `available_stock`, `locked_stock`, `version`) VALUES
(1001, 1000, 1000, 0, 0),
(1002, 500, 500, 0, 0),
(1003, 800, 800, 0, 0),
(1004, 300, 300, 0, 0),
(1005, 1500, 1500, 0, 0);

-- ============================================
-- 脚本执行完成
-- ============================================
SELECT '订单服务数据库初始化完成！' AS message;
SELECT '已创建5张表：orders, order_items, inventory, inventory_locks, undo_log' AS tables;
SELECT '已插入5条测试库存数据' AS test_data;