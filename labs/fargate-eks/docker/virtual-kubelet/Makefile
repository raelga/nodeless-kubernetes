REPO := $(shell cd ../../terraform && terraform output virtual_kubelet_repo)

login:
	aws ecr get-login --no-include-email | bash -

build:
	docker build -t $(REPO):latest .

push: login
	docker push $(REPO):latest