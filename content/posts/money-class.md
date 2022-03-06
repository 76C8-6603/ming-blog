---

    title: "货币类（比例分配货币）"
    date: 2019-04-25
    tags: ["architecture"]

---
## 背景
货币类包含诸多敏感操作，比如存储数据类型，舍入取整，和全球化等等。如果没有统一的货币工具类封装，维护成本太高。  

这里的货币类解决了一个核心问题：比例分配货币。主要策略是在不清楚比例数组顺序的情况下，平均的将余数金额分为多份（一分钱一份）。然后从头开始遍历，把每一份余数加到结果数组中。  
之后的代码用`long`类型保存货币，默认最小货币单位为分。

> 本文基于 Martin Flower《企业应用架构模式》一书，章节：18.7  
> 
> 关于代码中使用的舍入模式`BigDecimal.ROUND_HALF_EVEN`，参考[银行家舍入模式](https://baike.baidu.com/item/银行家舍入/4781630?fr=aladdin)：  
> （1）被修约的数字小于5时，该数字舍去；  
> （2）被修约的数字大于5时，则进位；  
> （3）被修约的数字等于5时，要看5前面的数字，若是奇数则进位，若是偶数则将5舍掉，即修约后末尾数字都成为偶数；若5的后面还有不为“0”的任何数，则此时无论5的前面是奇数还是偶数，均应进位。
## Code
```java
import java.math.BigDecimal;
import java.util.Currency;
import java.util.Locale;

/**
 * 货币类
 */
public class Money {
    private long amount;
    private Currency currency;
    private static final int[] cents = new int[]{1, 10, 100, 1000};

    public Money() {}

    public Money(long amount, Currency currency) {
        this.currency = currency;
        this.amount = amount * centFactor();
    }

    public Money(double amount, Currency currency) {
        this.currency = currency;
        this.amount = Math.round(amount * centFactor());
    }

    public Money(BigDecimal amount, Currency currency) {
        this(amount, currency, BigDecimal.ROUND_HALF_EVEN);
    }

    public Money(BigDecimal amount, Currency currency, int roundingMode) {
        this.currency = currency;
        this.amount = amount.multiply(BigDecimal.valueOf(centFactor()))
                .setScale(0, roundingMode)
                .longValue();

    }

    /**
     * 货币除法（等比分配）
     * @param n 除数（份数）
     * @return {@link Money}数组，length=n
     */
    public Money[] allocate(int n) {
        Money lowResult = newMoney(amount / n);
        Money highResult = newMoney(lowResult.amount + 1);
        Money[] results = new Money[n];
        int remainder = (int) (amount % n);
        for (int i = 0; i < remainder; i++) {
            results[i] = highResult;
        }
        for (int i = remainder; i < n; i++) {
            results[i] = lowResult;
        }
        return results;
    }

    /**
     * 货币除法（任何比例）
     * @param ratios 比例数组，如果带小数位的百分比，统一转为整数
     * @return {@link Money}数组，length=ratios.length
     */
    public Money[] allocate(long[] ratios) {
        long total = 0;
        for (long ratio : ratios) {
            total += ratio;
        }
        if (total == 0) {
            throw new IllegalArgumentException("百分比参数不能为零！");
        }
        long remainder = amount;
        Money[] results = new Money[ratios.length];
        for (int i = 0; i < results.length; i++) {
            results[i] = newMoney(amount * ratios[i] / total);
            remainder -= results[i].amount;
        }
        for (int i = 0; i < remainder; i++) {
            results[i].amount++;
        }
        return results;
    }

    /**
     * 货币加法
     * @param other 运算对象
     * @return {@link Money}
     */
    public Money add(Money other) {
        confirmSameCurrencyAs(other);
        return newMoney(amount + other.amount);
    }

    /**
     * 货币减法
     * @param other 运算对象
     * @return {@link Money}
     */
    public Money subtract(Money other) {
        confirmSameCurrencyAs(other);
        return newMoney(amount - other.amount);
    }

    /**
     * 货币乘法
     * @param amount double运算对象
     * @return {@link Money}
     */
    public Money multiply(double amount) {
        return multiply(BigDecimal.valueOf(amount));
    }

    /**
     * 货币乘法
     * @param amount {@link BigDecimal}运算对象
     * @return {@link Money}
     */
    public Money multiply(BigDecimal amount) {
        return multiply(amount, BigDecimal.ROUND_HALF_EVEN);
    }

    /**
     * 货币乘法
     * @param amount {@link BigDecimal}运算对象
     * @param roundingMode 舍入模式
     * @return {@link Money}
     */
    public Money multiply(BigDecimal amount, int roundingMode) {
        return new Money(amount().multiply(amount), currency, roundingMode);
    }


    /**
     * 根据amount创建新对象
     * @param amount long
     * @return {@link Money}
     */
    private Money newMoney(long amount) {
        Money money = new Money();
        money.amount = amount;
        money.currency = this.currency;
        return money;
    }

    /**
     * 确认运算对象的币种跟当前匹配
     * 不匹配抛出异常
     * @param other 运算对象
     */
    private void confirmSameCurrencyAs(Money other) {
        if (currency.equals(other.currency)) {
            throw new IllegalArgumentException("币种不匹配！");
        }
    }


    /**
     * 构造方法，默认人民币货币
     * @param amount 实际金额
     * @return {@link Money}
     */
    public static Money yuan(double amount) {
        return new Money(amount, Currency.getInstance(Locale.CHINA));
    }

    /**
     * 根据货币默认最小单位，获取转为long的乘数
     * @return 10的n次方
     */
    private int centFactor() {
        return cents[currency.getDefaultFractionDigits()];
    }

    /**
     * 获取真实金额
     * @return {@link BigDecimal}
     */
    public BigDecimal amount() {
        return BigDecimal.valueOf(amount, currency.getDefaultFractionDigits());
    }

    /**
     * 获取货币类
     * @return {@link Currency}
     */
    public Currency currency() {
        return currency;
    }

    /**
     * 比较货币类
     * @param other 对比对象
     * @return -1,0,1
     */
    public int compareTo(Object other) {
        return compareTo(((Money) other));
    }

    /**
     * 比较货币类
     * @param other 对比对象
     * @return -1,0,1
     */
    public int compareTo(Money other) {
        confirmSameCurrencyAs(other);
        if(amount < other.amount){return -1;}
        else if(amount == other.amount){return 0;}
        return 1;
    }

    /**
     * 当前金额是否更大
     * @param other 对比对象
     * @return true/false
     */
    public boolean greaterThan(Money other) {
        return compareTo(other) > 0;
    }

    @Override
    public boolean equals(Object other) {
        return (other instanceof Money) && equals(((Money) other));
    }

    public boolean equals(Money other) {
        return currency.equals(other.currency) && (amount == other.amount);
    }

    @Override
    public int hashCode() {
        return (int) (amount ^ (amount >>> 32));
    }

}

```
