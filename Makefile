DOKKU_HOST:=breton.ch

create: validate-app
	git remote add ${NAME} dokku@${DOKKU_HOST}:${NAME}
	git push ${NAME} master
	ssh -t dokku@breton.ch config:set ${NAME} url=http://${NAME}.${DOKKU_HOST}
	ssh -t dokku@breton.ch proxy:ports-remove ${NAME} http:2368:2368
	ssh -t dokku@breton.ch proxy:ports-add ${NAME} http:80:2368

destroy: validate-app
	ssh -t dokku@breton.ch apps:destroy ${NAME}

apps:
	ssh -t dokku@breton.ch apps:report ${NAME}

domains:
	ssh -t dokku@breton.ch domains:report ${NAME}

proxy:
	ssh -t dokku@breton.ch proxy:report ${NAME}

validate-app:
ifndef NAME
	$(error NAME is not set)
endif
