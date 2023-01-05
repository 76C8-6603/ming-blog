---

    title: "linux temperature monitor"
    date: 2023-01-04
    tags: ["linux"]

---

# CPU/GPU
`lm-sensors` 可以监测cpu/gpu的温度  

```shell
# install
sudo sensors-detect  

# check temperature
sensors
```
但是因为linux内核的更新速度，最新的cpu和gpu一般无法识别，也无法监测温度  
这时候可以通过cpu-x来监测，安装参考[github](https://github.com/TheTumultuousUnicornOfDarkness/CPU-X)  
```shell
# check temperature
cpu-x
```

# Disk
`hddtemp` 可以监测硬盘温度  

debian/ubuntu 安装：
```shell
sudo apt update
wget http://archive.ubuntu.com/ubuntu/pool/universe/h/hddtemp/hddtemp_0.3-beta15-53_amd64.deb  
sudo apt install ./hddtemp_0.3-beta15-53_amd64.deb
```

温度监测  
```shell
hddtemp /dev/sd?
```
