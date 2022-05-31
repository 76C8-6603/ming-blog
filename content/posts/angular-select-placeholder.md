---

    title: "Angular <select> placeholder"
    date: 2022-05-31
    tags: ["angular"]

---

参考[How to set placeholder on select](https://stackoverflow.com/questions/5805059/how-do-i-make-a-placeholder-for-a-select-box)  

在一般情况下，下面的代码就可以实现  
```angular2html
<select>
    <option value="" disabled selected>Select your option</option>
    <option value="hurr">Durr</option>
</select>
```
但是如果你的option是一个列表  
```angular2html
<select>
    <option value="undefined" disabled selected>Select your option</option>
    <option *ngFor="let item of list" [ngValue]="item">{{item}}</option>
</select>
```
第一个option的value就必须设置为`undefined`