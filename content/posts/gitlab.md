---

    title: "Gitlab local installation"
    date: 2022-09-13
    tags: ["git"]

---

For ubuntu/debian  

> It takes up more than fucking 8GB ram, which is unacceptable to the local repository, so I decided to run it on docker.  

```shell
# install 
curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh
sudo bash script.deb.sh
sudo apt-get install gitlab-ce

# Exception: wait for logrotate service socket
/opt/gitlab/embedded/bin/runsvdir-start &

# Change host: external_url "http://localhost:8111"
nano /etc/gitlab/gitlab.rb

# Reload configuration
gitlab-ctl reconfigure

# restart
gitlab-ctl restart

# Exception: runsv not running
sudo systemctl enable gitlab-runsvdir.service
sudo systemctl start gitlab-runsvdir.service

# reset root password, then wait fucking ten minutes
gitlab-rake "gitlab:password:reset[root]"


```
 
