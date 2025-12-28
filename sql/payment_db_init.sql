-- ============================================
-- 支付服务数据库初始化脚本
-- 数据库: payment_db
-- 包含表: payment_orders, payment_records
-- 创建时间: 2025-11-20
-- ============================================

-- 创建支付服务数据库
CREATE DATABASE IF NOT EXISTS `payment_db` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `payment_db`;

-- ============================================
-- 1. 支付订单表 (payment_orders)
-- ============================================
CREATE TABLE `payment_orders` (
  `payment_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '支付ID，主键',
  `payment_number` VARCHAR(20) NOT NULL COMMENT '支付流水号，格式PAY+时间戳+随机数',
  `order_id` BIGINT(20) NOT NULL COMMENT '订单ID',
  `order_number` VARCHAR(18) NOT NULL COMMENT '订单号',
  `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
  
  -- 支付信息
  `amount` DECIMAL(10,2) NOT NULL COMMENT '支付金额',
  `payment_method` VARCHAR(20) NOT NULL COMMENT '支付方式：ALIPAY/WECHAT/BANK_CARD/MOCK',
  `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '支付状态：PENDING/SUCCESS/FAILED',
  
  -- 时间信息
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `pay_time` DATETIME NULL COMMENT '支付完成时间',
  `expire_time` DATETIME NOT NULL COMMENT '过期时间，创建后15分钟',
  
  -- 第三方交易信息
  `transaction_id` VARCHAR(64) NULL COMMENT '第三方交易ID',
  `transaction_details` TEXT NULL COMMENT '交易详情，JSON格式',
  
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `uk_payment_number` (`payment_number`),
  UNIQUE KEY `uk_order_id` (`order_id`),
  KEY `idx_order_number` (`order_number`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付订单表';

-- ============================================
-- 2. 支付记录表 (payment_records)
-- ============================================
CREATE TABLE `payment_records` (
  `record_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '记录ID，主键',
  `payment_number` VARCHAR(20) NOT NULL COMMENT '支付流水号',
  `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
  `order_id` BIGINT(20) NOT NULL COMMENT '订单ID',
  `order_number` VARCHAR(18) NOT NULL COMMENT '订单号',
  
  -- 支付信息
  `amount` DECIMAL(10,2) NOT NULL COMMENT '支付金额',
  `payment_method` VARCHAR(20) NOT NULL COMMENT '支付方式',
  `status` VARCHAR(20) NOT NULL COMMENT '支付状态',
  
  -- 时间信息
  `pay_time` DATETIME NOT NULL COMMENT '支付时间',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  
  -- 第三方交易信息
  `transaction_id` VARCHAR(64) NULL COMMENT '第三方交易ID',
  `transaction_details` TEXT NULL COMMENT '交易详情，JSON格式',
  
  PRIMARY KEY (`record_id`),
  KEY `idx_payment_number` (`payment_number`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_pay_time` (`pay_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付记录表';

-- ============================================
-- 脚本执行完成
-- ============================================
SELECT '支付服务数据库初始化完成！' AS message;
SELECT '已创建2张表：payment_orders, payment_records' AS tables;