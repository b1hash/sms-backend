# SMS后端项目部署指南

## 📦 部署产物清单

项目已成功构建，以下是可用的部署产物：

### 核心模块
- **sms-sdk.jar** (13,299 bytes / ~13 KB) - 核心SDK模块
- **sms-entity.jar** (74,657 bytes / ~75 KB) - 实体模块
- **sms-server.jar** (69,625,356 bytes / ~69.6 MB) - **主服务模块** ⭐
- **sms-api.jar** (65,445,791 bytes / ~65.4 MB) - API模块
- **sms-manage.jar** (85,843,170 bytes / ~85.8 MB) - 管理模块

### 📍 部署位置
```
/www/sms/sms-backend/
├── sms-api/target/sms-api.jar
├── sms-entity/target/sms-entity.jar
├── sms-sdk/target/sms-sdk.jar
├── sms-manage/target/sms-manage.jar
└── sms-server/target/sms-server.jar ← 主部署文件
```

## 🚀 部署步骤

### 1. 环境准备
确保部署服务器已安装：
- Java 1.8+
- MySQL 8.0+
- Redis (可选，本地已有)

### 2. 数据库配置
```sql
-- 创建数据库
CREATE DATABASE sms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户 (根据实际情况修改)
CREATE USER 'sms_user'@'%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON sms.* TO 'sms_user'@'%';
FLUSH PRIVILEGES;
```

### 3. 配置文件修改
在部署服务器上创建配置文件 `application-prod.yml`：

```yaml
server:
  port: 8772

spring:
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://your_mysql_host:3306/sms?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false
    username: sms_user
    password: your_password
    druid:
      initial-size: 5
      min-idle: 5
      max-active: 20
      max-wait: 60000
      time-between-eviction-runs-millis: 60000
      min-evictable-idle-time-millis: 300000
      validation-query: SELECT 1 FROM DUAL
      test-while-idle: true
      test-on-borrow: false
      test-on-return: false
      pool-prepared-statements: true
      max-pool-prepared-statement-per-connection-size: 20
      filters: stat,wall,log4j
      connection-properties: druid.stat.mergeSql=true;druid.stat.slowSqlMillis=5000

  redis:
    host: localhost
    port: 6379
    password:  # 如有密码请填写
    database: 0
    timeout: 6000ms
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 0
        max-wait: -1ms

mybatis-plus:
  mapper-locations: classpath:/mapper/*Mapper.xml
  type-aliases-package: com.sms.entity
  configuration:
    map-underscore-to-camel-case: true
    cache-enabled: false
    call-setters-on-nulls: true
    jdbc-type-for-null: 'null'

logging:
  level:
    com.sms: INFO
    com.baomidou.mybatisplus: INFO
    com.alibaba.druid: INFO
  path: ./logs
  file:
    name: ${logging.path}/${spring.application.name}.log

management:
  endpoints:
    web:
      exposure:
        include: '*'
  endpoint:
    health:
      show-details: always

pd:
  local-ip: 127.0.0.1
```

### 4. 启动服务
```bash
# 方式1：直接运行JAR
java -jar sms-server.jar --spring.profiles.active=prod

# 方式2：后台运行
nohup java -jar sms-server.jar --spring.profiles.active=prod > sms-server.log 2>&1 &

# 方式3：指定配置文件
java -jar sms-server.jar --spring.config.location=file:./application-prod.yml
```

### 5. 验证启动
```bash
# 检查进程
ps aux | grep sms-server

# 检查端口
netstat -tlnp | grep 8772

# 检查日志
tail -f sms-server.log

# 访问应用
curl http://localhost:8772/doc.html  # Swagger文档
curl http://localhost:8772/druid     # 数据库监控
```

## 📋 服务信息

- **服务端口**: 8772
- **Swagger文档**: http://your-server:8772/doc.html
- **数据库监控**: http://your-server:8772/druid
- **健康检查**: http://your-server:8772/actuator/health

## ⚠️ 注意事项

1. **依赖环境**: 确保MySQL和Redis服务正常运行
2. **网络配置**: 根据实际网络环境调整数据库连接地址
3. **安全配置**: 生产环境请修改默认密码和配置
4. **日志目录**: 确保应用有权限写入 `./logs` 目录
5. **JVM参数**: 生产环境可添加JVM调优参数，如 `-Xmx2g -Xms1g`

## 🔧 故障排除

### 常见问题
1. **端口占用**: 修改 `server.port` 配置
2. **数据库连接失败**: 检查数据库地址、用户名、密码
3. **Redis连接失败**: 检查Redis服务状态和配置
4. **权限问题**: 确保应用有读写文件权限

### 日志查看
```bash
# 查看启动日志
cat sms-server.log

# 实时查看日志
tail -f logs/sms-server.log
```

---

*部署完成后，请通过浏览器访问 http://your-server:8772/doc.html 查看API文档*

## 📤 文件上传命令

```bash
# 上传所有JAR文件到部署服务器
scp sms-server/target/sms-server.jar alias:/www/sms/sms-backend/sms-server/target/
scp sms-api/target/sms-api.jar alias:/www/sms/sms-backend/sms-api/target/
scp sms-entity/target/sms-entity.jar alias:/www/sms/sms-backend/sms-entity/target/
scp sms-sdk/target/sms-sdk.jar alias:/www/sms/sms-backend/sms-sdk/target/
scp sms-manage/target/sms-manage.jar alias:/www/sms/sms-backend/sms-manage/target/
```