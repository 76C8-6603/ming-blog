---

    title: "hive kerberos jdbc连接方式"
    date: 2021-06-19
    tags: ["hive"]

---

```shell
public class HiveConnection {

    public static void main(String[] args) throws ClassNotFoundException, SQLException, IOException {
        System.setProperty("java.security.krb5.conf", "./Project/src/main/resources/conf/krb5.conf");


        final Configuration conf = new Configuration();
        conf.set("hadoop.security.authentication", "Kerberos");

        UserGroupInformation.setConfiguration(conf);
        UserGroupInformation.loginUserFromKeytab("hive/cdh-1@EXAMPLE.COM", "./Project/src/main/resources/conf/hive.keytab");

        String url = "jdbc:hive2://192.168.200.110:10000/;principal=hive/cdh-1@EXAMPLE.COM";
        Class.forName("org.apache.hive.jdbc.HiveDriver");
        Connection connection = DriverManager.getConnection(url,null,null);
        final PreparedStatement ps = connection.prepareStatement("show tables");
        final ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            System.out.println(rs.getString(1));
        }
    }
}
```

注意，精简`krb5.conf`配置文件，非必要的参数会导致意外错误
```lombok.config
[libdefaults]
 dns_lookup_realm = false
 renewable = true
 forwardable = true
 rdns = false
 default_realm = EXAMPLE.COM
[realms]
 EXAMPLE.COM = {
  kdc = 192.168.200.110
  admin_server = 192.168.200.110
 }
[domain_realm]
.example.com = EXAMPLE.COM
example.com = EXAMPLE.COM
```

hive jdbc驱动版本要和hive版本匹配，不然也会报错，这里用的`1.1.0`版本
```xml
<dependency>
    <groupId>org.apache.hive</groupId>
    <artifactId>hive-jdbc</artifactId>
    <version> 1.1.0</version>
</dependency>
```
