---

    title: "复式记账"
    date: 2021-10-08
    tags: ["mysql"]

---
复式记账(double-entry bookkeeping)概念，总体来说就是将一次交易分为`debit（支出方）`和`credit（收入方）`两方（两方可能不止一个账户），两方中流动的资金总额最后一定是相等的。  
> 复式记账详情参考[wikipedia double-entry bookkeeping](https://en.wikipedia.org/wiki/Double-entry_bookkeeping)  
> 交易余额账户表设计参考（非复式记账）[stackoverflow](https://stackoverflow.com/questions/29688982/derived-account-balance-vs-stored-account-balance-for-a-simple-bank-account/29713230#29713230)  
> 复式记账的表设计讨论可以参考[stackoverflow](https://stackoverflow.com/questions/59432964/relational-data-model-for-double-entry-accounting/59465148#59465148)  

