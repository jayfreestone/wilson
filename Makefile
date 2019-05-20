IMAGE_NAME=wilson

include .env

build:
	docker build -t jayfreestone/${IMAGE_NAME}

push:
	docker push jayfreestone/${IMAGE_NAME}

test:
	cat kubernetes/wilson-ssh-sv.yml | sed s/\$$WILSON_STATIC_LOAD_BALANCER_IP/${WILSON_STATIC_LOAD_BALANCER_IP}/

create:
	# https://serverfault.com/questions/791715/using-environment-variables-in-kubernetes-deployment-spec
	cat kubernetes/wilson-ssh-sv.yml | sed s/\$$WILSON_STATIC_LOAD_BALANCER_IP/${WILSON_STATIC_LOAD_BALANCER_IP}/ | kubectl create -f -
	cat kubernetes/wilson-mosh-sv.yml | sed s/\$$WILSON_STATIC_LOAD_BALANCER_IP/${WILSON_STATIC_LOAD_BALANCER_IP}/ | kubectl create -f -
	kubectl create -f kubernetes/wilson-rs.yml
	kubectl create -f kubernetes/wilson-sv.yml

apply:
	# https://serverfault.com/questions/791715/using-environment-variables-in-kubernetes-deployment-spec
	cat kubernetes/wilson-ssh-sv.yml | sed s/\$$WILSON_STATIC_LOAD_BALANCER_IP/${WILSON_STATIC_LOAD_BALANCER_IP}/ | kubectl create -f -
