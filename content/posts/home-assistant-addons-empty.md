---

    title: "Home Assistant Addons store empty"
    date: 2023-02-13
    tags: ["smart home"]

---
Make sure that your host or vm can connect to github.
```shell
docker exec -it hassio_supervisor /bin/bash
cd /data/addons/core
git clone https://github.com/home-assistant/addons
reboot
```