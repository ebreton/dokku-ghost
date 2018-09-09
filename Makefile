DOKKU_HOST:=breton.ch
DOKKU_LETSENCRYPT_EMAIL:=manu@ibimus.com
DOKKU_GRAFANA_SERVICE:=grafana

LOCAL_BACKUP_PATH:=~/var/dokku_backup

###
# ONE OFF

init-host:
	# set email to use for let's encrypt globally
	# ! requires: sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
	ssh -t dokku@breton.ch config:set --global DOKKU_LETSENCRYPT_EMAIL=${DOKKU_LETSENCRYPT_EMAIL}
	# install monitoring
	# ! requires: sudo dokku plugin:install https://github.com/dokku/dokku-graphite-grafana.git graphite
	ssh -t dokku@breton.ch graphite:create ${DOKKU_GRAFANA_SERVICE}
	ssh -t dokku@breton.ch graphite:nginx-expose ${DOKKU_GRAFANA_SERVICE} ${DOKKU_GRAFANA_SERVICE}.${DOKKU_HOST}
	# ! connect with admin/admin and change password


###
# CREATE & DESTROY

create: validate-app
	# create an app and set environment variable+port before 1st deployment
	ssh -t dokku@breton.ch apps:create ${NAME}
	ssh -t dokku@breton.ch config:set ${NAME} url=https://${NAME}.${DOKKU_HOST}
	ssh -t dokku@breton.ch proxy:ports-add ${NAME} http:80:2368
	# add remote and push app to trigger deployment on host
	git remote add ${NAME} dokku@${DOKKU_HOST}:${NAME}
	git push ${NAME} master
	# remove unnecessary port
	ssh -t dokku@breton.ch proxy:ports-remove ${NAME} http:2368:2368
	# switch to HTTPs
	ssh -t dokku@breton.ch letsencrypt ${NAME}
	# mount volume for images
	ssh -t dokku@breton.ch storage:mount ${NAME} /var/lib/dokku/data/storage/${NAME}:/var/lib/ghost/content/images
	ssh -t dokku@breton.ch ps:restart ${NAME}
	# connect to grafana
	ssh -t dokku@breton.ch graphite:link ${DOKKU_GRAFANA_SERVICE} ${NAME}

destroy: validate-app
	ssh -t dokku@breton.ch apps:destroy ${NAME}
	git remote remove ${NAME}

###
# MONITORING

apps:
	ssh -t dokku@breton.ch apps:report ${NAME}

domains:
	ssh -t dokku@breton.ch domains:report ${NAME}

proxy:
	ssh -t dokku@breton.ch proxy:report ${NAME}

storage:
	ssh -t dokku@breton.ch storage:report ${NAME}

###
# BACKUP & RESTORE

backup-all:
	[ -d $(LOCAL_BACKUP_PATH) ] || mkdir -p $(LOCAL_BACKUP_PATH)
	rsync -av ${DOKKU_HOST}:/var/lib/dokku/data/storage/ ${LOCAL_BACKUP_PATH}

backup: validate-app
	[ -d $(LOCAL_BACKUP_PATH) ] || mkdir -p $(LOCAL_BACKUP_PATH)
	rsync -av ${DOKKU_HOST}:/var/lib/dokku/data/storage/${NAME} ${LOCAL_BACKUP_PATH}/

restore: validate-app
	rsync -av ${LOCAL_BACKUP_PATH}/${NAME} ${DOKKU_HOST}:/var/lib/dokku/data/storage/

###
# INPUT VALIDATION

validate-app:
ifndef NAME
	$(error NAME is not set)
endif
