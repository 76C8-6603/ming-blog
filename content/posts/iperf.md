---

    title: "iperf usecase"
    date: 2023-01-30
    tags: ["linux"]

---

for server:  
`iperf -s -u –p 12345 –i 1`  

for client:  
`iperf -u -c server-ip -p server-port -i 1 -t 10 -b 1000m`  

> refer to [iperf cnblog](https://www.cnblogs.com/yingsong/p/5682080.html)  

