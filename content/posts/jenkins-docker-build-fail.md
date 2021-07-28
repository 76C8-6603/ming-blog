---

    title: "unix://localhost:80: Permission denied"
    date: 2021-07-28
    tags: ["docker","jenkins"]

---

### 问题原因
权限问题，执行以下命令将jenkins加入docker group：
```shell
 sudo usermod -aG docker jenkins
```
然后重启jenkins 

> 参考[mvn docker build fail](https://github.com/spotify/docker-maven-plugin/issues/105)

### 完整异常
```log
Jul 28, 2021 1:23:12 PM com.spotify.docker.client.shaded.org.apache.http.impl.execchain.RetryExec execute
INFO: I/O exception (java.io.IOException) caught when processing request to {}->unix://localhost:80: Permission denied
Jul 28, 2021 1:23:12 PM com.spotify.docker.client.shaded.org.apache.http.impl.execchain.RetryExec execute
INFO: Retrying request to {}->unix://localhost:80
Jul 28, 2021 1:23:12 PM com.spotify.docker.client.shaded.org.apache.http.impl.execchain.RetryExec execute
INFO: I/O exception (java.io.IOException) caught when processing request to {}->unix://localhost:80: Permission denied
Jul 28, 2021 1:23:12 PM com.spotify.docker.client.shaded.org.apache.http.impl.execchain.RetryExec execute
INFO: Retrying request to {}->unix://localhost:80
Jul 28, 2021 1:23:12 PM com.spotify.docker.client.shaded.org.apache.http.impl.execchain.RetryExec execute
INFO: I/O exception (java.io.IOException) caught when processing request to {}->unix://localhost:80: Permission denied
Jul 28, 2021 1:23:12 PM com.spotify.docker.client.shaded.org.apache.http.impl.execchain.RetryExec execute
INFO: Retrying request to {}->unix://localhost:80
[WARNING] An attempt failed, will retry 1 more times
org.apache.maven.plugin.MojoExecutionException: Could not build image
	at com.spotify.plugin.dockerfile.BuildMojo.buildImage(BuildMojo.java:234)
	at com.spotify.plugin.dockerfile.BuildMojo.execute(BuildMojo.java:129)
	at com.spotify.plugin.dockerfile.AbstractDockerMojo.tryExecute(AbstractDockerMojo.java:265)
	at com.spotify.plugin.dockerfile.AbstractDockerMojo.execute(AbstractDockerMojo.java:254)
	at org.apache.maven.plugin.DefaultBuildPluginManager.executeMojo(DefaultBuildPluginManager.java:101)
```

如果jenkins中出现命令无法找到问题，可以直接通过完整路径访问，例如docker-compose，可通过`/usr/local/bin/docker-compose up -d`来访问  


