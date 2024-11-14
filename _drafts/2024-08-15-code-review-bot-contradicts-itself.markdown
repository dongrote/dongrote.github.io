---
date: 2024-08-15 14:03:30 -0400
title: Code Review Bot Contradicts Itself
author: Don Grote
layout: post
category: anecdotes
---

> **AI code review**
>
> It might be better to add a condition to include Swagger only in development
> mode to avoid exposing API documentation in production environments.
>
> Here is the suggested code:

{% highlight csharp %}
if (env.IsDevelopment())
{
    services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new OpenApiInfo { Title = "Microsoft.DeviceSecurity.Service.Scheduler", Version = "v1" });
    });
}
{% endhighlight %}


---


> **AI code review**
>
> It might be better to move the Swagger configuration outsidce of the development
> environment check to ensure that the Swagger documentation is available in all
> environments, not just during development. This can be useful for testing and
> production environments as well.
>
> Here is the suggested code:

{% highlight csharp %}
app.UseSwagger();
app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "Microsoft.DeviceSecurity.Service.Scheduler v1"));

if (env.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
{% endhighlight %}
