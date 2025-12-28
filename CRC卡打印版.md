# CRC卡打印版
## 可用于复制到Word/PowerPoint

---

## 1. User（用户）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 存储用户基本信息 | • Order |
| • 管理用户账号和密码 | • ShoppingCart |
| • 验证用户身份 | • ShippingAddress |
| • 提供用户注册和登录 | |
| • 更新用户个人资料 | |
| • 判断用户角色和状态 | |

---

## 2. Order（订单）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 存储订单信息 | • User |
| • 管理订单状态 | • OrderItem |
| • 计算订单总金额 | • PaymentOrder |
| • 记录订单时间信息 | • OrderStatus |
| • 处理订单取消 | • ShippingAddress |
| • 判断订单是否可支付/取消 | |
| • 维护订单与订单明细的关系 | |

---

## 3. OrderItem（订单明细）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 存储订单中的商品信息 | • Order |
| • 记录商品快照数据 | • Product |
| • 计算商品小计金额 | • CartItem |
| • 从购物车项创建订单明细 | |
| • 从商品创建订单明细 | |

---

## 4. Product（商品）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 存储商品基本信息 | • Inventory |
| • 管理商品价格和规格 | • CartItem |
| • 提供商品详情 | • OrderItem |
| • 判断商品是否可购买 | |
| • 判断库存是否充足 | |
| • 更新商品库存和销量 | |

---

## 5. ShoppingCart（购物车）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 存储用户待购买商品 | • User |
| • 管理购物车项 | • CartItem |
| • 添加/删除/更新购物车项 | • Product |
| • 计算购物车总价 | |
| • 获取购物车商品数量 | |
| • 清空购物车 | |

---

## 6. CartItem（购物车项）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 存储购物车中的单个商品 | • ShoppingCart |
| • 记录商品快照价格 | • Product |
| • 管理商品数量和选中状态 | |
| • 计算商品小计 | |
| • 判断商品是否过期 | |

---

## 7. ShippingAddress（收货地址）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 存储用户收货地址信息 | • User |
| • 管理地址的增删改 | • Order |
| • 设置默认地址 | |
| • 提供完整地址字符串 | |
| • 验证地址信息完整性 | |

---

## 8. Inventory（库存）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 存储商品库存信息 | • Product |
| • 管理总库存和可用库存 | • InventoryService |
| • 检查库存是否充足 | |
| • 锁定库存（预扣） | |
| • 实际扣减库存 | |
| • 释放预扣库存 | |
| • 使用乐观锁处理并发 | |

---

## 9. PaymentOrder（支付订单）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 存储支付订单信息 | • Order |
| • 生成支付流水号 | • PaymentRecord |
| • 管理支付状态 | • PaymentStatus |
| • 记录支付方式和金额 | • PaymentMethod |
| • 判断是否可支付 | |
| • 判断是否过期 | |
| • 记录支付结果 | |

---

## 10. PaymentRecord（支付记录）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 记录所有支付操作 | • PaymentOrder |
| • 存储支付详情 | • PaymentStatus |
| • 提供支付历史查询 | • PaymentMethod |
| • 支持对账和审计 | |
| • 记录第三方交易信息 | |

---

## 11. OrderStatus（订单状态枚举）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 定义订单的5种状态 | • Order |
| • 提供状态码和描述 | • OrderService |
| • 判断状态是否可转换 | |
| • 根据状态码获取枚举值 | |

---

## 12. PaymentStatus（支付状态枚举）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 定义支付的3种状态 | • PaymentOrder |
| • 提供状态码和描述 | • PaymentRecord |
| • 判断支付是否成功 | • PaymentService |
| • 判断支付是否失败 | |

---

## 13. PaymentMethod（支付方式枚举）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 定义4种支付方式 | • PaymentOrder |
| • 提供方式码和描述 | • PaymentRecord |
| • 判断是否为模拟支付 | • PaymentService |

---

## 14. OrderService（订单服务）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 协调订单创建流程 | • Order |
| • 校验订单信息 | • OrderItem |
| • 调用库存服务检查库存 | • User |
| • 调用购物车服务获取商品 | • ShippingAddress |
| • 管理订单状态流转 | • InventoryService |
| • 处理订单取消 | • ShoppingCart |
| • 提供订单查询功能 | |
| • 定时检查超时订单 | |

---

## 15. InventoryService（库存服务）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 检查商品库存是否充足 | • Inventory |
| • 批量检查多个商品库存 | • Product |
| • 锁定库存（预扣） | • OrderService |
| • 实际扣减库存 | • PaymentCallbackHandler |
| • 释放预扣库存 | |
| • 更新商品库存数量 | |
| • 处理乐观锁重试 | |
| • 定时释放超时锁 | |

---

## 16. PaymentService（支付服务）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 创建支付订单 | • PaymentOrder |
| • 处理支付请求 | • PaymentRecord |
| • 模拟支付流程 | • Order |
| • 查询支付状态 | • OrderService |
| • 记录支付历史 | • PaymentCallbackHandler |
| • 支持支付重试 | |
| • 提供支付记录查询 | |

---

## 17. PaymentCallbackHandler（支付回调处理器）

| **职责 (Responsibilities)** | **协作者 (Collaborators)** |
|:---------------------------|:--------------------------|
| • 处理支付结果回调 | • PaymentService |
| • 协调支付成功后的操作 | • OrderService |
| • 更新订单状态 | • InventoryService |
| • 扣减商品库存 | • ShoppingCart |
| • 清空购物车 | • PaymentOrder |
| • 生成支付记录 | • Order |
| • 触发发货通知 | • Inventory |
| • 处理支付失败回滚 | |
| • 通知用户支付结果 | |

---

**说明**：
- 可以将每个卡片复制到PowerPoint的独立页面
- 建议使用3x5英寸或4x6英寸的卡片尺寸
- 打印后可以用于团队讨论和设计评审
