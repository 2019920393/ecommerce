---
inclusion: always
---
编码阶段：在任何时候都需要符合我们前面写的文档中的信息，不能额外添加，也不能少。
请用中文回答我，第一句话要说帅哥
每次会话终止时，第二次会话开始，你必须先查阅电商项目的设计文档，了解全部过程，以及上一次会话所干的事情。从开发进度文档查询当前进度 并继续开发，记得每完成一个功能提醒我push一下到git。

## 代码命名规范
- 数据访问层包名：`mapper`（不用repository）
- 数据访问层类名：`xxxMapper`（如 OrderMapper、ProductMapper）
- 响应VO类名：`xxxRspVO`（如 ProductRspVO、OrderRspVO）
- 请求类名：`xxxRequest`（如 CreateOrderRequest）
- 所有服务统一使用此命名规范