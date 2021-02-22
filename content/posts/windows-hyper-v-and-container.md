---

    title: "启用Windows Hyper-v和containers"
    date: 2020-10-19
    tags: ["windows"]

---
# Hyper-v
powershell admin
```commandline
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```
> [Install Hyper-V on Windows 10](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v)

# Containers
[Prep windows for containers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=Windows-Server)