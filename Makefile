DOKKU_HOST:=breton.ch

ifndef NAME
$(error NAME is not set)
endif

create:
	git remote add ${NAME} dokku@${DOKKU_HOST}:${NAME}
	git push ${NAME} master
	ssh -t dokku@breton.ch proxy:ports-clear ${NAME}
	ssh -t dokku@breton.ch proxy:ports-add ${NAME} http:80:2368