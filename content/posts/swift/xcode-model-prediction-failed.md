---
    title: "CoreML Code=0 Prediction failed"
    date: 2023-12-24
    tags: ["AI", "swift"]
---

Create ML model prediction failed when the model file was replaced.  
Check the file access, make the access: `everyone` `read & write`:
> Right-click on the file, find the `Detail`, change the `read & write` access to everyone.  

And only when the app `Minimum Deployments` and `Simulator vision` are both `17.0`, you can test the prediction in the simulator(I think it's a bug, and Canvas never work).  
![img.png](/img-28.png)  
![img_1.png](/img_29.png)  
