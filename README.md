***Note: This is a work-in-progress***

# nvALT + TextExpander + Sublime Text 2 + Notesy (iOS) + Markdown + Dropbox + git + BitBucket crontab == Bioinformatics Lab Notebook

I've chosen a set of tools that, when used together, comprise a ***customizable, easy to use digital notebook***. Notes are ***automatically synced*** across computers, mobile devices, and the web for easy access and are ***automatically version controlled***, which allows for easy recovery of deleted/corrupted notes and helps provide detailed records of when notes were added and/or edited.

## Rationale

Using a paper-based lab notebook in Bioinformatics, Computational Biology, etc. is a pain (at best) and in most circumstances is not at all feasible. Although there are some digital lab notebook systems available, the ones I've looked into, however, seem overly-restrictive, clunky, out-dated, and/or over-priced.

As a post-doc, I made good use of [Evernote][EVERNOTE] as a makeshift lab notebook. I think it is a great option for a digital lab notebook for most scientists. It is free (or low-cost for the Premium version), easy to use, good for collaboration/sharing, and has great search features (including searching for text in images).

Now that I do much more programming and unix/linux CLI-based work, I've run into a common problem related to keeping digital records that contain code. Evernote (and most other common writing applications) add hidden formatting even when the user pastes plain text. This can cause inaccurate or ugly notes. It can also cause unexpected behavior when reusing code snippets (e.g. copying from notes and pasting into Terminal).

Although there have been requests from many people to add plain-text support to Evernote, it doesn't seem to be a priority. Therefore, I've switched completely to plain-text apps for note-taking. Here, I'll describe my approach and provide the various configurations, etc. that I use.

## Tools Used

I use all of these in conjunction with one another, but certain subsets will work well to satisfy most requirements.

### [nvALT][NVALT] (OS X)

TODO:

- Tip for adding .md as a recognized filetype (and making it the default filetype). This lets ST2 auto-set syntax highlighting to Markdown! (http://faceofgeoff.com/post/9665888623/nvalt-quick-tip-making-markdown-readable-and-your)
- Link to template
- Link to css

### [Dropbox][DROPBOX] (OS X/Linux/Windows)

TODO:

- Describe how I have Dropbox setup
    - `~/Dropbox/Notes/`
    - `~/Dropbox/Notes/Images`

### [TextExpander][TEXTEXPANDER] (OS X/iOS)

TODO:

- Description of usage w/ nvALT
- Link to snippets I use

### [Sublime Text 2][SUBLIME] (OS X/Linux/Windows)

TODO:

- Description of usage
- Link to free tutorial
- Links to my favorite plug-ins

### [Notesy][NOTESY] (iOS)

TODO:

- Link to css

### [Markdown][MARKDOWN]

TODO:

- Link to tutorial
- Link to raw version of this page

### [git][GIT] (OS X/Linux/Windows??)

TODO:

- Basic description of git
- Links to git tutorials
- Contents of `.gitignore`
- Add SourceTree to list of tools?

### [BitBucket][BITBUCKET]

A lot of people know about [GitHub][GITHUB], but not as many have heard of BitBucket. I primarily use GitHub for my public projects; however, a lab notebook is generally something you want to keep private. One great thing about BitBucket (vs. GitHub) is that users in Academia get free access to unlimited private repositories with unlimites private collaborators.

TODO:

- Setup public key...

### crontab (OS X/Linux)

Because `crontab` doesn't see your environmental variables, we sometimes need to pass this info along. In order to allow `crontab` to push commits to BitBucket **via SSH**, we need to determine what `SSH_AUTH_SOCK` is set to (in my case, it is `/tmp/launch-y5fz8q/Listeners`):

    echo $SSH_AUTH_SOCK

Edit the `crontab` schedule:

    crontab -e

Add the following to the `crontab` schedule (change `/tmp/launch-y5fz8q/Listeners`, `~/Dropbox/Notes/`, etc. as necessary):

    SSH_AUTH_SOCK=/tmp/launch-y5fz8q/Listeners
    00 * * * * TIMESTAMP=`date "+\%Y.\%m.\%d \%H:\%M:\%S"` && cd ~/Dropbox/Notes/ && git add --all && git commit -m "hourly commit - $TIMESTAMP" && git push -u origin --all

This sets the `SSH_AUTH_SOCK` variable, and every hour on the hour, the following actions are performed:

1. A TIMESTAMP variable is created (e.g., `2013.01.04 15:00:00`)
2. The directory is changed to the location of the notes (`~/Dropbox/Notes/`)
3. All files are staged for the next commit (except those specified by `.gitignore`)
4. Staged files are committed with an auto-generated message (e.g., `hourly commit - 2013.01.04 15:00:00`)
5. The local repository is pushed to the remote repo (in my case, a private repo on BitBucket)

## Brief Summary of Approach

TODO:

- Summary of approach:

>I quickly grew addicted to writing my notes in [Markdown][MARKDOWN]. Markdown is a fun, easy to read...


<!-- LINKS -->

[BITBUCKET]:    https://bitbucket.org/
[DROPBOX]:      https://www.dropbox.com/
[EVERNOTE]:     http://evernote.com/
[GIT]:          http://git-scm.com/
[GITHUB]:       https://github.com/
[MARKDOWN]:     http://daringfireball.net/projects/markdown/
[NOTATIONAL]:   http://notational.net/
[NOTESY]:       http://notesy-app.com/
[NVALT]:        http://brettterpstra.com/projects/nvalt/
[SUBLIME]:      http://www.sublimetext.com/
[TEXTEXPANDER]: http://smilesoftware.com/TextExpander/index.html
