REPO = $(shell cd ../../terraform && terraform output traefik_repo)

login:
	aws ecr get-login --no-include-email --region eu-west-1 | bash -

build: token ca.crt
	docker build -t $(REPO):latest .

push: build login
	docker push $(REPO):latest

token:
	kubectl get secret $$(kubectl get sa traefik-ingress-controller -ojsonpath='{.secrets[0].name}') -ojsonpath='{.data.token}' | base64 --decode > token

ca.crt:
	cd ../../terraform && terraform output eks_cluster_ca | base64 --decode > /tmp/ca.crt
	cp /tmp/ca.crt .