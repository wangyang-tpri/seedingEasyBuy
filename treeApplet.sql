-- =====================================================
-- 苗木易购 微信小程序 Database Schema V1.0
-- =====================================================

CREATE DATABASE IF NOT EXISTS nursery_app DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE nursery_app;
SET NAMES utf8mb4;

-- 1. 用户表
CREATE TABLE `user` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `openid`      VARCHAR(64)  NOT NULL COMMENT '微信openid',
  `unionid`     VARCHAR(64)  DEFAULT NULL COMMENT '微信unionid',
  `nickname`    VARCHAR(64)  DEFAULT NULL COMMENT '微信昵称',
  `avatar`      VARCHAR(512) DEFAULT NULL COMMENT '头像URL',
  `phone`       VARCHAR(20)  DEFAULT NULL COMMENT '手机号',
  `gender`      TINYINT      DEFAULT 0 COMMENT '性别 0未知 1男 2女',
  `user_type`   TINYINT      DEFAULT 0 COMMENT '用户类型 0普通用户 1商家 2管理员',
  `status`      TINYINT      DEFAULT 0 COMMENT '状态 0正常 1禁用',
  `points`      INT          DEFAULT 0 COMMENT '积分',
  `last_login`  DATETIME     DEFAULT NULL COMMENT '最后登录时间',
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_openid` (`openid`),
  KEY `idx_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 2. 店铺表
CREATE TABLE `shop` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `shop_name`     VARCHAR(100) NOT NULL COMMENT '店铺名称',
  `owner_id`      BIGINT       NOT NULL COMMENT '店主用户ID',
  `logo`          VARCHAR(512) DEFAULT NULL COMMENT '店铺LOGO',
  `description`   VARCHAR(500) DEFAULT NULL COMMENT '店铺描述',
  `location`      VARCHAR(200) DEFAULT NULL COMMENT '所在地',
  `contact_phone` VARCHAR(20)  DEFAULT NULL COMMENT '联系电话',
  `rating`        DECIMAL(3,2) DEFAULT 5.00 COMMENT '评分',
  `sales_count`   INT          DEFAULT 0 COMMENT '总销量',
  `status`        TINYINT      DEFAULT 0 COMMENT '状态 0正常 1禁用 2待审核',
  `create_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_owner` (`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺表';

-- 3. 分类表
CREATE TABLE `category` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`        VARCHAR(50)  NOT NULL COMMENT '分类名称',
  `parent_id`   BIGINT       DEFAULT 0 COMMENT '父分类ID, 0为顶级',
  `icon`        VARCHAR(512) DEFAULT NULL COMMENT '图标URL',
  `sort`        INT          DEFAULT 0 COMMENT '排序',
  `status`      TINYINT      DEFAULT 1 COMMENT '状态 0隐藏 1显示',
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分类表';

-- 4. 商品表
CREATE TABLE `product` (
  `id`             BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `shop_id`        BIGINT        NOT NULL COMMENT '店铺ID',
  `category_id`    BIGINT        NOT NULL COMMENT '分类ID',
  `name`           VARCHAR(200)  NOT NULL COMMENT '商品名称',
  `subtitle`       VARCHAR(300)  DEFAULT NULL COMMENT '副标题/简短描述',
  `description`    TEXT          DEFAULT NULL COMMENT '商品详情(富文本)',
  `price`          DECIMAL(10,2) NOT NULL COMMENT '最低价格(展示用)',
  `original_price` DECIMAL(10,2) DEFAULT NULL COMMENT '原价',
  `stock`          INT           DEFAULT 0 COMMENT '总库存',
  `sales`          INT           DEFAULT 0 COMMENT '销量',
  `images`         TEXT          DEFAULT NULL COMMENT '图片JSON数组',
  `video`          VARCHAR(512)  DEFAULT NULL COMMENT '视频URL',
  `specs`          JSON          DEFAULT NULL COMMENT '规格参数(key-value)',
  `planting_guide` TEXT          DEFAULT NULL COMMENT '种植指南',
  `has_sku`        TINYINT       DEFAULT 0 COMMENT '是否多规格 0单规格 1多规格',
  `unit`           VARCHAR(20)   DEFAULT NULL COMMENT '单位(株/盆/棵)',

  `min_quantity`   INT           DEFAULT 1 COMMENT '最小起售数量',
  `status`         TINYINT       DEFAULT 0 COMMENT '状态 0下架 1上架 2审核中',
  `sort`           INT           DEFAULT 0 COMMENT '排序',
  `create_time`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_shop` (`shop_id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_status_sort` (`status`, `sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- 5. 商品SKU表
CREATE TABLE `product_sku` (
  `id`           BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `product_id`   BIGINT        NOT NULL COMMENT '商品ID',
  `sku_name`     VARCHAR(100)  NOT NULL COMMENT 'SKU名称(如"高80-100cm")',
  `height_range` VARCHAR(50)   DEFAULT NULL COMMENT '高度范围',
  `crown_width`  VARCHAR(50)   DEFAULT NULL COMMENT '冠幅',
  `diameter`     VARCHAR(50)   DEFAULT NULL COMMENT '地径/胸径',
  `tree_age`     VARCHAR(50)   DEFAULT NULL COMMENT '树龄',
  `price`        DECIMAL(10,2) NOT NULL COMMENT '价格',
  `stock`        INT           DEFAULT 0 COMMENT '库存',
  `image`        VARCHAR(512)  DEFAULT NULL COMMENT 'SKU对应图片URL',
  `sort`         INT           DEFAULT 0 COMMENT '排序',
  `create_time`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品SKU表';

-- 6. 商品图片表
CREATE TABLE `product_image` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `product_id`  BIGINT       NOT NULL COMMENT '商品ID',
  `image_url`   VARCHAR(512) NOT NULL COMMENT '图片URL',
  `image_type`  TINYINT      DEFAULT 0 COMMENT '图片类型 0主图 1详情图 2SKU图',
  `sort_order`  INT          DEFAULT 0 COMMENT '排序',
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品图片表';

-- 7. 购物车表
CREATE TABLE `cart` (
  `id`          BIGINT   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`     BIGINT   NOT NULL COMMENT '用户ID',
  `product_id`  BIGINT   NOT NULL COMMENT '商品ID',
  `sku_id`      BIGINT   DEFAULT NULL COMMENT 'SKU ID(NULL表示单规格)',
  `quantity`    INT      NOT NULL DEFAULT 1 COMMENT '数量',
  `selected`    TINYINT  DEFAULT 1 COMMENT '是否选中 0未选 1选中',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product_sku` (`user_id`, `product_id`, `sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车表';

-- 8. 订单表
CREATE TABLE `orders` (
  `id`                BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no`          VARCHAR(64)   NOT NULL COMMENT '订单号',
  `user_id`           BIGINT        NOT NULL COMMENT '用户ID',
  `shop_id`           BIGINT        NOT NULL COMMENT '店铺ID',
  `total_amount`      DECIMAL(10,2) NOT NULL COMMENT '订单总额',
  `pay_amount`        DECIMAL(10,2) NOT NULL COMMENT '实付金额',
  `freight`           DECIMAL(10,2) DEFAULT 0.00 COMMENT '运费',
  `discount`          DECIMAL(10,2) DEFAULT 0.00 COMMENT '优惠金额',
  `coupon_id`         BIGINT        DEFAULT NULL COMMENT '使用的优惠券ID',
  `status`            TINYINT       DEFAULT 0 COMMENT '订单状态 0待付款 1待发货 2待收货 3待评价 4已完成 5已取消 6售后',
  `receiver_name`     VARCHAR(50)   NOT NULL COMMENT '收货人姓名',
  `receiver_phone`    VARCHAR(20)   NOT NULL COMMENT '收货电话',
  `receiver_address`  VARCHAR(500)  NOT NULL COMMENT '收货地址',
  `user_message`      VARCHAR(500)  DEFAULT NULL COMMENT '买家留言',
  `logistics_company` VARCHAR(50)   DEFAULT NULL COMMENT '物流公司',
  `logistics_no`      VARCHAR(64)   DEFAULT NULL COMMENT '物流单号',
  `pay_type`          TINYINT       DEFAULT 1 COMMENT '支付方式 1微信支付',
  `pay_time`          DATETIME      DEFAULT NULL COMMENT '支付时间',
  `delivery_time`     DATETIME      DEFAULT NULL COMMENT '发货时间',
  `receive_time`      DATETIME      DEFAULT NULL COMMENT '收货时间',
  `close_time`        DATETIME      DEFAULT NULL COMMENT '关闭时间',
  `close_reason`      VARCHAR(200)  DEFAULT NULL COMMENT '关闭原因',
  `create_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user` (`user_id`),
  KEY `idx_shop` (`shop_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- 9. 订单商品表
CREATE TABLE `order_item` (
  `id`            BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id`      BIGINT        NOT NULL COMMENT '订单ID',
  `product_id`    BIGINT        NOT NULL COMMENT '商品ID',
  `sku_id`        BIGINT        DEFAULT NULL COMMENT 'SKU ID',
  `product_name`  VARCHAR(200)  NOT NULL COMMENT '商品名称(快照)',
  `sku_name`      VARCHAR(100)  DEFAULT NULL COMMENT 'SKU名称(快照)',
  `product_image` VARCHAR(512)  DEFAULT NULL COMMENT '商品图片(快照)',
  `quantity`      INT           NOT NULL COMMENT '数量',
  `price`         DECIMAL(10,2) NOT NULL COMMENT '单价',
  `subtotal`      DECIMAL(10,2) NOT NULL COMMENT '小计',
  `create_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单商品表';

-- 10. 收货地址表
CREATE TABLE `address` (
  `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`        BIGINT       NOT NULL COMMENT '用户ID',
  `receiver_name`  VARCHAR(50)  NOT NULL COMMENT '收货人姓名',
  `phone`          VARCHAR(20)  NOT NULL COMMENT '联系电话',
  `province`       VARCHAR(50)  DEFAULT NULL COMMENT '省',
  `city`           VARCHAR(50)  DEFAULT NULL COMMENT '市',
  `district`       VARCHAR(50)  DEFAULT NULL COMMENT '区',
  `detail_address` VARCHAR(200) NOT NULL COMMENT '详细地址',
  `full_address`   VARCHAR(500) DEFAULT NULL COMMENT '完整地址',
  `is_default`     TINYINT      DEFAULT 0 COMMENT '是否默认 0否 1是',
  `label`          VARCHAR(20)  DEFAULT NULL COMMENT '地址标签(家/公司/学校)',
  `lng`            DECIMAL(10,6) DEFAULT NULL COMMENT '经度',
  `lat`            DECIMAL(10,6) DEFAULT NULL COMMENT '纬度',
  `create_time`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收货地址表';

-- 11. 收藏表
CREATE TABLE `collection` (
  `id`          BIGINT   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`     BIGINT   NOT NULL COMMENT '用户ID',
  `product_id`  BIGINT   NOT NULL COMMENT '商品ID',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product` (`user_id`, `product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- 12. 浏览足迹表
CREATE TABLE `footprint` (
  `id`          BIGINT   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`     BIGINT   NOT NULL COMMENT '用户ID',
  `product_id`  BIGINT   NOT NULL COMMENT '商品ID',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_time` (`user_id`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='浏览足迹表';

-- 13. 轮播图表
CREATE TABLE `banner` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title`       VARCHAR(100) DEFAULT NULL COMMENT '标题',
  `image_url`   VARCHAR(512) NOT NULL COMMENT '图片URL',
  `link_url`    VARCHAR(512) DEFAULT NULL COMMENT '跳转链接',
  `link_type`   TINYINT      DEFAULT 0 COMMENT '跳转类型 0无 1商品 2分类 3活动页',
  `link_value`  VARCHAR(100) DEFAULT NULL COMMENT '跳转参数(如商品ID)',
  `sort`        INT          DEFAULT 0 COMMENT '排序',
  `status`      TINYINT      DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='轮播图表';

-- 14. 优惠券表
CREATE TABLE `coupon` (
  `id`           BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`         VARCHAR(100)  NOT NULL COMMENT '优惠券名称',
  `type`         TINYINT       DEFAULT 0 COMMENT '类型 0满减券 1折扣券 2新人券',
  `value`        DECIMAL(10,2) NOT NULL COMMENT '面值(满减免金额或折扣率)',
  `min_amount`   DECIMAL(10,2) DEFAULT 0.00 COMMENT '最低使用金额',
  `total_count`  INT           DEFAULT 0 COMMENT '发放总量',
  `remain_count` INT           DEFAULT 0 COMMENT '剩余数量',
  `valid_days`   INT           DEFAULT 0 COMMENT '有效天数(领取后)',
  `start_time`   DATETIME      DEFAULT NULL COMMENT '有效期开始',
  `end_time`     DATETIME      DEFAULT NULL COMMENT '有效期结束',
  `status`       TINYINT       DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券表';

-- 15. 用户优惠券表
CREATE TABLE `user_coupon` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`     BIGINT       NOT NULL COMMENT '用户ID',
  `coupon_id`   BIGINT       NOT NULL COMMENT '优惠券ID',
  `status`      TINYINT      DEFAULT 0 COMMENT '状态 0未使用 1已使用 2已过期',
  `used_time`   DATETIME     DEFAULT NULL COMMENT '使用时间',
  `order_no`    VARCHAR(64)  DEFAULT NULL COMMENT '使用的订单号',
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

-- 16. 评价表
CREATE TABLE `review` (
  `id`            BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id`      BIGINT        NOT NULL COMMENT '订单ID',
  `order_item_id` BIGINT        DEFAULT NULL COMMENT '订单商品ID',
  `user_id`       BIGINT        NOT NULL COMMENT '用户ID',
  `product_id`    BIGINT        NOT NULL COMMENT '商品ID',
  `sku_id`        BIGINT        DEFAULT NULL COMMENT 'SKU ID',
  `rating`        TINYINT       DEFAULT 5 COMMENT '评分 1-5',
  `content`       TEXT          DEFAULT NULL COMMENT '评价内容',
  `images`        TEXT          DEFAULT NULL COMMENT '晒图JSON数组',
  `is_anonymous`  TINYINT       DEFAULT 0 COMMENT '是否匿名 0否 1是',
  `reply_content` TEXT          DEFAULT NULL COMMENT '商家回复',
  `reply_time`    DATETIME      DEFAULT NULL COMMENT '回复时间',
  `status`        TINYINT       DEFAULT 1 COMMENT '状态 0隐藏 1显示',
  `create_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_product` (`product_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评价表';

-- =====================================================
-- 初始化数据: 分类
-- =====================================================
INSERT INTO `category` (`id`, `name`, `parent_id`, `sort`) VALUES
(1, '观赏植物', 0, 1),
(2, '果树苗木', 0, 2),
(3, '绿化苗木', 0, 3),
(4, '多肉盆栽', 0, 4),
(5, '种子种苗', 0, 5),
(6, '桂花', 1, 1),
(7, '樱花', 1, 2),
(8, '桃花', 1, 3),
(9, '梅花', 1, 4),
(10, '月季', 1, 5),
(11, '苹果树', 2, 1),
(12, '梨树', 2, 2),
(13, '桃树', 2, 3),
(14, '柿子树', 2, 4),
(15, '香樟', 3, 1),
(16, '银杏', 3, 2),
(17, '法桐', 3, 3),
(18, '国槐', 3, 4),
(19, '多肉组合', 4, 1),
(20, '仙人掌', 4, 2),
(21, '绿萝', 4, 3),
(22, '花卉种子', 5, 1),
(23, '蔬菜种子', 5, 2),
(24, '草籽', 5, 3);

-- =====================================================
-- 初始化数据: 轮播图
-- =====================================================
INSERT INTO `banner` (`title`, `image_url`, `link_type`, `link_value`, `sort`) VALUES
('春季苗木热卖', 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22700%22 height=%22340%22%3E%3Cdefs%3E%3ClinearGradient id=%22g%22 x1=%220%22 y1=%220%22 x2=%22100%25%22 y2=%22100%25%22%3E%3Cstop offset=%220%22 stop-color=%22%2307C160%22/%3E%3Cstop offset=%22100%25%22 stop-color=%22%2306AD56%22/%3E%3C/linearGradient%3E%3C/defs%3E%3Crect fill=%22url(%23g)%22 width=%22700%22 height=%22340%22 rx=%2212%22/%3E%3Ctext fill=%22white%22 font-size=%2236%22 font-weight=%22bold%22 x=%22350%22 y=%22160%22 text-anchor=%22middle%22%3E🌳 春季苗木热卖%3C/text%3E%3Ctext fill=%22rgba(255,255,255,0.8)%22 font-size=%2220%22 x=%22350%22 y=%22195%22 text-anchor=%22middle%22%3E全场精品苗木 限时特惠%3C/text%3E%3C/svg%3E', 0, NULL, 1),
('品质保证 健康苗木', 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22700%22 height=%22340%22%3E%3Cdefs%3E%3ClinearGradient id=%22g%22 x1=%220%22 y1=%220%22 x2=%22100%25%22 y2=%22100%25%22%3E%3Cstop offset=%220%22 stop-color=%22%23FF6B35%22/%3E%3Cstop offset=%22100%25%22 stop-color=%22%23ff8c5a%22/%3E%3C/linearGradient%3E%3C/defs%3E%3Crect fill=%22url(%23g)%22 width=%22700%22 height=%22340%22 rx=%2212%22/%3E%3Ctext fill=%22white%22 font-size=%2236%22 font-weight=%22bold%22 x=%22350%22 y=%22160%22 text-anchor=%22middle%22%3E🌿 品质保证 健康苗木%3C/text%3E%3Ctext fill=%22rgba(255,255,255,0.8)%22 font-size=%2220%22 x=%22350%22 y=%22195%22 text-anchor=%22middle%22%3E实地验货 售后无忧%3C/text%3E%3C/svg%3E', 0, NULL, 2),
('新用户专享优惠', 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22700%22 height=%22340%22%3E%3Cdefs%3E%3ClinearGradient id=%22g%22 x1=%220%22 y1=%220%22 x2=%22100%25%22 y2=%22100%25%22%3E%3Cstop offset=%220%22 stop-color=%22%238B4513%22/%3E%3Cstop offset=%22100%25%22 stop-color=%22%23a0522d%22/%3E%3C/linearGradient%3E%3C/defs%3E%3Crect fill=%22url(%23g)%22 width=%22700%22 height=%22340%22 rx=%2212%22/%3E%3Ctext fill=%22white%22 font-size=%2236%22 font-weight=%22bold%22 x=%22350%22 y=%22160%22 text-anchor=%22middle%22%3E🎁 新用户专享优惠%3C/text%3E%3Ctext fill=%22rgba(255,255,255,0.8)%22 font-size=%2220%22 x=%22350%22 y=%22195%22 text-anchor=%22middle%22%3E首单立减 满百包邮%3C/text%3E%3C/svg%3E', 0, NULL, 3);

-- =====================================================
-- 初始化数据: 店铺
-- =====================================================
INSERT INTO `shop` (`id`, `shop_name`, `owner_id`, `location`, `status`) VALUES
(1, '绿意苗圃', 1, '浙江省杭州市萧山区', 0),
(2, '花香园林', 1, '江苏省南京市江宁区', 0);

-- =====================================================
-- 初始化数据: 商品
-- =====================================================
INSERT INTO `product` (`id`, `shop_id`, `category_id`, `name`, `subtitle`, `price`, `original_price`, `stock`, `sales`, `images`, `specs`, `has_sku`, `status`, `sort`) VALUES
(1, 1, 6, '桂花树 四季桂 浓香型', '庭院盆栽地栽皆可 四季常绿', 88.00, 128.00, 200, 356, '["data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect fill=%22%23e8f8ee%22 width=%22400%22 height=%22400%22/%3E%3Ctext fill=%22%2307C160%22 font-size=%2280%22 x=%22200%22 y=%22220%22 text-anchor=%22middle%22%3E🌳%3C/text%3E%3C/svg%3E"]', '{"高度":"80-100cm","冠幅":"30-50cm","树龄":"2年","品种":"四季桂"}', 1, 1, 1),
(2, 1, 7, '樱花树苗 日本晚樱', '庭院观赏 花开烂漫', 45.00, 68.00, 500, 892, '["data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect fill=%22%23fff0f0%22 width=%22400%22 height=%22400%22/%3E%3Ctext fill=%22%23ff6b6b%22 font-size=%2280%22 x=%22200%22 y=%22220%22 text-anchor=%22middle%22%3E🌸%3C/text%3E%3C/svg%3E"]', '{"高度":"50-80cm","冠幅":"20-30cm","树龄":"1年","品种":"日本晚樱"}', 1, 1, 2),
(3, 1, 15, '香樟树 绿化行道树', '常绿乔木 净化空气', 168.00, 220.00, 100, 128, '["data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect fill=%22%23e8f0e8%22 width=%22400%22 height=%22400%22/%3E%3Ctext fill=%22%23228B22%22 font-size=%2280%22 x=%22200%22 y=%22220%22 text-anchor=%22middle%22%3E🌲%3C/text%3E%3C/svg%3E"]', '{"高度":"200-250cm","地径":"5-8cm","树龄":"3年"}', 1, 1, 3),
(4, 1, 11, '苹果树苗 红富士', '自花授粉 当年结果', 35.00, 50.00, 300, 567, '["data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect fill=%22%23fff8f0%22 width=%22400%22 height=%22400%22/%3E%3Ctext fill=%22%23ff6347%22 font-size=%2280%22 x=%22200%22 y=%22220%22 text-anchor=%22middle%22%3E🍎%3C/text%3E%3C/svg%3E"]', '{"高度":"100-150cm","地径":"2-3cm","树龄":"2年"}', 1, 1, 4),
(5, 2, 19, '多肉植物组合盆栽', '办公桌阳台绿植 易养护', 28.00, 38.00, 800, 1234, '["data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect fill=%22%23f0fff0%22 width=%22400%22 height=%22400%22/%3E%3Ctext fill=%22%2332CD32%22 font-size=%2280%22 x=%22200%22 y=%22220%22 text-anchor=%22middle%22%3E🌵%3C/text%3E%3C/svg%3E"]', '{"规格":"6株组合","盆径":"15cm"}', 0, 1, 5),
(6, 2, 9, '红梅树苗 骨里红', '耐寒盆景 冬春开花', 98.00, 148.00, 150, 234, '["data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect fill=%22%23fff5f5%22 width=%22400%22 height=%22400%22/%3E%3Ctext fill=%22%23dc143c%22 font-size=%2280%22 x=%22200%22 y=%22220%22 text-anchor=%22middle%22%3E🌸%3C/text%3E%3C/svg%3E"]', '{"高度":"60-100cm","冠幅":"30-40cm","树龄":"2年","品种":"骨里红"}', 1, 1, 6),
(7, 2, 16, '银杏树苗 嫁接矮化', '庭院观赏 秋叶金黄', 128.00, 168.00, 80, 98, '["data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect fill=%22%23fffef0%22 width=%22400%22 height=%22400%22/%3E%3Ctext fill=%22%23FFD700%22 font-size=%2280%22 x=%22200%22 y=%22220%22 text-anchor=%22middle%22%3E🍂%3C/text%3E%3C/svg%3E"]', '{"高度":"150-200cm","地径":"3-5cm","树龄":"3年"}', 1, 1, 7),
(8, 1, 22, '薰衣草种子 盆栽花卉', '易播种 阳台庭院均可', 6.80, 9.90, 2000, 4567, '["data:image/svg+xml;charset=utf-8,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22400%22 height=%22400%22%3E%3Crect fill=%22%23f8f0ff%22 width=%22400%22 height=%22400%22/%3E%3Ctext fill=%22%239370DB%22 font-size=%2280%22 x=%22200%22 y=%22220%22 text-anchor=%22middle%22%3E🌱%3C/text%3E%3C/svg%3E"]', '{"规格":"100粒/包","发芽率":"≥85%"}', 0, 1, 8);

-- =====================================================
-- 初始化数据: 商品SKU
-- =====================================================
INSERT INTO `product_sku` (`product_id`, `sku_name`, `height_range`, `diameter`, `price`, `stock`, `sort`) VALUES
(1, '高30-50cm', '30-50cm', NULL, 48.00, 80, 1),
(1, '高50-80cm', '50-80cm', NULL, 68.00, 60, 2),
(1, '高80-100cm', '80-100cm', NULL, 88.00, 40, 3),
(1, '高100-150cm', '100-150cm', NULL, 128.00, 20, 4),
(2, '高30-50cm', '30-50cm', NULL, 25.00, 200, 1),
(2, '高50-80cm', '50-80cm', NULL, 45.00, 150, 2),
(2, '高80-120cm', '80-120cm', NULL, 78.00, 100, 3),
(3, '地径5-8cm 高2-2.5m', '200-250cm', '5-8cm', 168.00, 50, 1),
(3, '地径8-12cm 高2.5-3m', '250-300cm', '8-12cm', 280.00, 30, 2),
(4, '高80-120cm', '80-120cm', NULL, 25.00, 150, 1),
(4, '高120-180cm', '120-180cm', NULL, 48.00, 100, 2);
