---

    title: "Docker Desktop needs privileged access"
    date: 2021-11-11
    tags: ["docker"]

---
Mac打开Docker时无限弹出`Docker Desktop needs privileged access`  
执行此命令即可`rm -rf /Library/LaunchDaemons/com.docker.vmnetd.plist`  
详情参考[Docker Forums](https://forums.docker.com/t/cant-get-past-docker-for-mac-needs-privileged-access-to-install-its-networking-components-and-links-to-the-docker-apps/42518)