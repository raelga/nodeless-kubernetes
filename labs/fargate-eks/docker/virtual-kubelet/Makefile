REPO := $(shell cd ../../terraform && terraform output virtual_kubelet_repo)

login:
	aws ecr get-login --no-include-email --region eu-west-1 | bash -

build:
	docker build -t $(REPO):latest .

push: build login
	docker push $(REPO):latest
