# 🌳 苗木易购

苗木电商小程序（跨端商城），基于 **uni-app (Vue 2)** 构建，一套代码可同时编译运行于 **H5、微信小程序、App（Android/iOS）、支付宝小程序** 等多个平台。面向苗木行业，提供苗木商品浏览、搜索、购物车、下单、订单管理、地址管理、收藏、优惠券等完整电商闭环能力，并内置苗木上架、苗木管理与轮播图管理等运营功能。

## ✨ 功能特性

### 用户端
- **首页**：轮播图展示、推荐苗木、快捷入口
- **分类**：按苗木类别浏览商品
- **搜索**：苗木关键字搜索
- **购物车**：已选商品管理、结算
- **订单**：确认订单、下单、订单列表、订单详情
- **地址管理**：收货地址的增删改查
- **我的**：个人中心、登录（验证码 / 手机号登录）
- **收藏**：苗木收藏与查看
- **优惠券**：优惠券列表与使用

### 运营管理端
- **苗木上架**：发布苗木商品
- **苗木管理**：已上架苗木的分页查询与管理
- **轮播图管理**：首页轮播图的配置与图片上传

## 🛠 技术栈

| 分类 | 技术 |
|------|------|
| 框架 | [uni-app](https://uniapp.dcloud.net.cn/)（Vue 2 语法） |
| UI 组件库 | [uView UI](https://uviewui.com/) 2.0 |
| 状态管理 | Vuex 3 |
| 分页组件 | z-paging |
| 网络请求 | uni.request 封装（`src/utils/request.js`） |
| 样式 | SCSS |
| 构建工具 | vue-cli 4 + vue-cli-plugin-uni |

> 后端基于 **Spring Boot + MySQL + MyBatis-plus + MinIO**，接口鉴权采用 **JWT（Bearer Token）**。数据库脚本见根目录 `treeApplet.sql`。

## 📁 目录结构

```
├── src
│   ├── api/                  # API 接口层
│   ├── common/               # 公共样式（atomic.scss）
│   ├── components/           # 自定义组件（z-paging 系列）
│   ├── mixins/               # 全局混入
│   ├── pages/                # 页面
│   │   ├── index/            # 首页
│   │   ├── category/         # 分类
│   │   ├── cart/             # 购物车
│   │   ├── search/           # 搜索
│   │   ├── product/          # 商品列表 / 详情 / 上架 / 管理
│   │   ├── order/            # 订单确认 / 列表 / 详情
│   │   ├── address/          # 地址管理 / 编辑
│   │   ├── banner/           # 轮播图管理
│   │   ├── collection/       # 我的收藏
│   │   ├── coupon/           # 优惠券
│   │   └── user/             # 我的 / 登录
│   ├── static/               # 静态资源（图标、图片）
│   ├── store/                # Vuex 状态管理
│   ├── utils/                # 工具（request / param / sign / file）
│   ├── App.vue               # 应用入口
│   ├── main.js               # 全局配置
│   ├── manifest.json         # 应用配置（各平台）
│   ├── pages.json            # 页面路由与 tabBar 配置
│   └── uni.scss              # uni-app 全局 SCSS 变量
├── .env.development          # 开发环境配置
├── .env.production           # 生产环境配置
├── demand.md                 # 需求文档
├── tabBar.md                 # TabBar 设计文档
└── treeApplet.sql            # 数据库建表脚本
```

## 🚀 快速开始

### 环境要求

- Node.js ≥ 12
- npm / yarn

### 安装依赖

```bash
# npm
npm install

# 或 yarn
yarn install
```

### 启动开发服务（H5）

```bash
npm run serve
# 等价于 npm run dev:h5
```

### 编译运行到微信小程序

```bash
npm run dev:mp-weixin
```

使用 **微信开发者工具** 导入编译产物 `dist/dev/mp-weixin` 目录即可预览调试。

## 📦 构建打包

### H5

```bash
npm run build:h5        # 生产构建
```

### 微信小程序

```bash
npm run build:mp-weixin
```

### App（Android / iOS）

```bash
npm run build:app-plus
```

### 其他平台

```bash
npm run build:mp-alipay        # 支付宝小程序
npm run build:mp-baidu         # 百度小程序
npm run build:mp-toutiao       # 抖音小程序
npm run build:mp-qq            # QQ 小程序
# ... 更多平台见 package.json scripts
```

## ⚙️ 环境配置

项目通过 `.env.*` 文件管理环境变量，所有环境变量需以 `VUE_APP_` 前缀命名。

```bash
# .env.development
VUE_APP_BASE_API = "http://10.218.72.64:8080/api"   # 后端 API 地址
```

| 文件 | 说明 |
|------|------|
| `.env.development` | 开发环境：`npm run dev:*` 生效 |
| `.env.production` | 生产环境：`npm run build:*` 生效 |

开发环境下 `vue.config.js` 已配置 `/api` 代理，自动将请求转发到 `VUE_APP_BASE_API` 并去除 `/api` 前缀。

## 🔑 登录鉴权

- 支持验证码登录与手机号快捷登录（后端接口 `/auth/login`、`/auth/login_by_phone`）
- 登录成功后 JWT Token 与用户信息存储于本地（`uni.setStorageSync`），并在每次请求时以 `Authorization: Bearer <token>` 携带
- 接口返回 `401` 时自动清理登录态并跳转登录页

## 🧩 请求封装约定

后端统一返回结构：

```json
{
  "code": 200,
  "message": "success",
  "data": {}
}
```

- `code === 200`：成功，请求返回 `data` 字段
- `code === 401`：未登录，自动跳转登录页
- 其他 `code`：以 `message` 作为错误信息抛出

## 📄 相关文档

- [需求文档](demand.md)
- [TabBar 设计文档](tabBar.md)
- [数据库脚本](treeApplet.sql)
