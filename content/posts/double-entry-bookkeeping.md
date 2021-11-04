---

    title: "复式记账"
    date: 2021-10-08
    tags: ["mysql"]

---
复式记账(double-entry bookkeeping)概念，总体来说就是将一次交易分为`debit（支出方）`和`credit（收入方）`两方（两方可能不止一个账户），两方中流动的资金总额最后一定是相等的。  
> 复式记账详情参考[wikipedia double-entry bookkeeping](https://en.wikipedia.org/wiki/Double-entry_bookkeeping)  
> 交易余额账户表设计参考（非复式记账）[stackoverflow](https://stackoverflow.com/questions/29688982/derived-account-balance-vs-stored-account-balance-for-a-simple-bank-account/29713230#29713230)  
> 复式记账的表设计讨论可以参考[stackoverflow](https://stackoverflow.com/questions/59432964/relational-data-model-for-double-entry-accounting/59465148#59465148)  


复式记账sql实例：
> 外部账户表复用的用户表，以下不包含用户表  

```sql
CREATE TABLE `account_statement`
(
    `id`            bigint unsigned not null COMMENT '对账单id',
    `account_id`    bigint          not null COMMENT '账户（外部）id（用户id）',
    `close_date`    date            not null comment '下个月一号（例：五月一日，代表四月份的账单）',
    `close_balance` decimal(18, 4)  not null comment '截止到上月末，目前的总余额',
    `total_credit`  decimal(18, 4)  not null comment '当月总收入',
    `total_debit`   decimal(18, 4)  not null comment '当月总支出',
    primary key `pk_id` (`id`),
    unique key `uk_account_id_and_date` (`account_id`, `close_date`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT = '用户账户（外部）对账单（月）';

CREATE TABLE `account_transaction`
(
    `id`                bigint unsigned not null COMMENT '流水号',
    `ledger_id`         bigint unsigned not null COMMENT '平台账户id（内部）',
    `transaction_type`  varchar(5)      not null comment '交易类型码，代表复式记账中两方的关系：Cr：ledger <- account；Dr：ledger -> account',
    `transaction_class` varchar(5)      not null comment '交易分类码，Wd：提现，Rc：充值，Bl：保证金，By：购买，RR：收益，FP：平台费用，FR：平台资源',
    `account_id`        bigint          not null COMMENT '账户（外部）id（用户id）',
    `create_time`       datetime        not null comment '交易创建时间',
    `amount`            decimal(18, 4)  not null COMMENT '金额',
    `status`            VARCHAR(5)      not null COMMENT '交易状态：字母O成功，X失败，P进行中',
    `order_id`          varchar(200) COMMENT '订单id',
    `counterparty`      VARCHAR(100) COMMENT '对方信息',
    `balance`           decimal(18, 4) COMMENT '余额',
    `account_bank_id`   bigint unsigned COMMENT '银行账户（外部）id',
    primary key `pk_id` (`id`),
    key `idx_ledger_id` (`ledger_id`),
    key `idx_account_id_and_time` (`account_id`, `create_time`),
    key `idx_account_bank_id` (`account_bank_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT = '用户账户（外部）交易表';

CREATE TABLE `account_bank`
(
    `id`            bigint unsigned not null COMMENT '银行账户（外部）id',
    `account_id`    bigint          not null COMMENT '账户（外部）id（用户id）',
    `type`          varchar(10)     not null COMMENT '银行账户类型：BOC(中国银行），BCM（交通银行）...ALIPAY（支付宝），WECHAT（微信）',
    `identifier`    varchar(100)    not null COMMENT '账户识别码，银行卡号，和支付宝微信付款号等',
    `name`          varchar(10) COMMENT '开户名',
    `phone_num`     bigint unsigned COMMENT '手机号',
    `id_number`     varchar(25) COMMENT '身份证号',
    `open_branch`   varchar(200) COMMENT '开户支行',
    `open_province` varchar(20) COMMENT '开户所在省',
    `open_city`     varchar(100) COMMENT '开户所在市',
    `create_time`   datetime        not null comment '创建时间',
    `modify_time`   datetime        not null comment '修改时间',
    primary key `pk_id` (`id`),
    key `idx_identifier` (`identifier`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT = '账户（外部）银行卡';

CREATE TABLE `ledger`
(
    `id`             bigint unsigned not null COMMENT '平台账户id',
    `name`           varchar(20)     not null COMMENT '平台账户名称',
    `type`           varchar(5)      not null COMMENT '平台账户分类，RR：收益，AL：债务',
    `ledger_bank_id` bigint unsigned not null COMMENT '平台账户银行id',
    `create_time`    datetime        not null comment '创建时间',
    `modify_time`    datetime        not null comment '修改时间',
    primary key `pk_id` (`id`),
    key `idx_ledger_bank_id` (`ledger_bank_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT = '平台账户（内部）';

CREATE TABLE `ledger_transaction`
(
    `id`           bigint unsigned not null COMMENT '流水号',
    `create_time`  datetime        not null comment '交易创建时间',
    `ledger_id_cr` bigint unsigned not null COMMENT '平台账户收方',
    `ledger_id_dr` bigint unsigned not null COMMENT '平台账户支出方',
    `amount`       decimal(18, 4)  not null COMMENT '金额',
    primary key `pk_id` (`id`),
    key `idx_ledger_id_cr` (`ledger_id_cr`),
    key `idx_dr_id_and_time` (`ledger_id_dr`, `create_time`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT = '平台账户（内部）交易表';

CREATE TABLE `ledger_statement`
(
    `id`            bigint unsigned not null COMMENT '对账单id',
    `ledger_id`     bigint unsigned not null COMMENT '平台账户（内部）id',
    `close_date`    date            not null COMMENT '下周第一天（例：下周一，代表上周的账单）',
    `close_balance` decimal(18, 4)  not null COMMENT '截止到上周末，目前的总余额',
    primary key `pk_id` (`id`),
    unique key `uk_ledger_id_and_date` (`ledger_id`, `close_date`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT = '平台账户（内部）对账单';

CREATE TABLE `ledger_bank`
(
    `id`          bigint unsigned not null COMMENT '平台银行账户id',
    `type`        varchar(10)     not null COMMENT '银行账户类型：BOC(中国银行），BCM（交通银行）...ALIPAY（支付宝），WECHAT（微信）',
    `identifier`  varchar(100)    not null COMMENT '账户识别码，银行卡号，和支付宝微信付款号等',
    `create_time` datetime        not null comment '创建时间',
    `modify_time` datetime        not null comment '修改时间',
    primary key `pk_id` (`id`),
    key `idx_identifier` (`identifier`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT = '平台账户（内部）银行卡';

CREATE TABLE `statement_log`
(
    `id`          bigint unsigned auto_increment not null COMMENT '对账单id',
    `success`     tinyint(1) unsigned            not null COMMENT '是否成功，0否，1是',
    `external`    tinyint(1) unsigned            not null COMMENT '是否外部账户，0否，1是',
    `close_date`  date                           not null comment '账单日期',
    `create_time` datetime                       not null COMMENT '账单操作日期',
    `error_msg`   varchar(100) COMMENT '异常信息',
    primary key `pk_id` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT = '对账单日志，主要用于监控定时任务成功与否';






```