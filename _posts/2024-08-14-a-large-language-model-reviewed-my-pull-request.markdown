---
date: 2024-08-14 17:32:46 -0400
title: A Large Language Model Reviewed My Pull Request
layout: post
author: Don Grote
category: anecdotes
tags: llm code-review ai
---

Recently at work the powers that be added a code review bot that makes suggestions to improve our code. If anybody was
worried about an <abbr title='Large Language Model'>LLM</abbr> replacing them, I suggest you fear not, as they've still got
a ways to go.

Let's take a look at a snippet of code from one of my recent pull requests that was examined by our beloved MerlinBot.

{% highlight csharp %}
public async Task<string> DownloadFileAsync(string id, CancellationToken cancellationToken)
{
  using (var writeStream = fs.File.OpenWrite(fs.Path.GetTempFileName()))
  {
    await CopyToAsync(id, writeStream, cancellatonToken);
    return writeStream.Name;
  }
}
{% endhighlight %}

This method takes some opaque identifier, uses it to look up a file and proceeds to write it to a local temporary file on disk.
Assuming the copy succeeds, the path to the temporary file is returned to the caller so that they can use the downloaded file.

Here is the improvement suggested by MerlinBot:

> **AI code review**
> 
> It might be better to ensure that the temporary file created in `DownloadFileAsync` method is cleaned up after its use to avoid leaving unused files on the file system. This can be achieved by deleting the file after its path has been used. Here is the suggested code:

{% highlight csharp %}
public async Task<string> DownloadFileAsync(string id, CancellationToken cancellationToken)
{
  var tempFileName = fs.Path.GetTempFileName();
  using (var writeStream = fs.File.OpenWrite(tempFileName))
  {
    await CopyToAsync(id, writeStream, cancellationToken);
  }
  try
  {
    // Use the file for whatever needed
    return tempFileName;
  }
  finally
  {
    fs.File.Delete(tempFileName); // Ensure that temporary file is deleted after use
  }
}
{% endhighlight %}

I did my due diligence and provided explicit feedback to the MerlinBot maintainers explaining what was wrong with the suggestion.
The first issue I pointed out was that the file the caller is expecting to work with is going to be deleted.
I would've expected it to be apparent that the caller is going to use the file since the original method returns
the path to the populated file.

The second issue that I pointed out is that the operations that are most likely to throw an `Exception` are located _outside_
of the `try` block. The calls to `fs.Path.GetTempFileName()` can throw an `IOException` when we are unable to create a temporary file.
The `fs.File.OpenWrite()` can throw an `IOException` when we're unable to open the file for writing (e.g.,
file descriptor table exhaustion). And finally, the most likely offender, the `CopyToAsync()` can throw a myriad of
`Exception` types since, in this case, it's fetching data from a remote system.

Of course, all of this is anecdotal. I'm sure there could be some scenarios where a code review bot will make
genuinely valuable suggestions but this was not one of them.
