# Ghost on Dokku

## Prequisite: setup an host with Dokku

The starting point is... guess what...: [getting started](http://dokku.viewdocs.io/dokku/getting-started/installation/) from the official doc.

You shall therefore prepare 

1. a fresh installation of ubuntu. I used 18.04 (eventhough 16.04 is recommended) and the installation script ran smoothly
2. a DNS entry to the IP of this brand new server, e.g: dokku.me

Just browse by http://dokku.me, where you are be kindly asked for your public SSH key which you could quickly pick up from a `cat ~/.ssh/id_rsa.pub | pbcopy`

Note that once this setup complete, http://dokku.me is not available anymore

On the server side, I like to have access to docker commands without sudo, hence a quick `sudo adduser myself docker` to add myself in the docker group. Logout and login again, and `docker ps` (for instance) will output the expected :

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

As will next section will prove, this is unncessary since all commands are done with dokku (instead of docker) which prompts your password anyways.

## Your first application

Just before jumping onto Ghost make sure to follow the [getting started](http://dokku.viewdocs.io/dokku/getting-started/installation/) guide down to the end. It helped me in any case...

I had created and deployed ruby-rails-sample, but the subdomain configuration did not really work out of the box for me(ruby-rails-sample.dokku.me does not return anything)... It required to have configured a DNS entry on *.dokku.me.

That allows the next steps to work out smoothly, and to spawn ghosts in any subdomain you like, just like mosquitos

## Ghosts

On the host side, create an app and apply a few settings:

    # register app in dokku
    dokku apps:create ghost
    # declare the 'url' environment variable needed by ghost
    dokku config:set ghost url=http://ghost.dokku.me
    # prepare the redirection to the container's port
    dokku proxy:ports-add ghost http:80:2368

On my side, I create repo with only one file, the Dockerfile

    FROM ghost:2-alpine

And I push the app

    git remote add ghost dokku@dokku.me:ghost
    git push ghost master

Would I wish a second blog now, I would repeat those steps:

    # on host
    dokku apps:create another
    dokku config:set another url=http://another.dokku.me
    dokku proxy:ports-add ghost http:80:2638
    
    # on my side
    git remote add another dokku@dokku.me:another
    git push another master

# Automation

Well, let's be old-fashioned and have a cosy `Makefile` there... you will be able to create and destroy apps with a single command. That's always handy.

# Next ?

1. Follow up on https://github.com/dokku/dokku-graphite-grafana/issues/21
1. Find a dashboard for the [offered monitoring](https://github.com/dokku/dokku-graphite-grafana)
1. Check the [maintenance plugin](https://github.com/dokku/dokku-maintenance)