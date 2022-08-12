vpc_cidr              = "10.6.0.0/16"
private_subnet        = { count = 2, newbits = 10, netnum = 0 }
public_subnet         = { count = 2, newbits = 10, netnum = 4 }
vpc_name              = "ecs_vpc"
ecs_cluster_name      = "fargate-cluster"
docker_container_port = 8080
ecs_service_name      = "simplehttp"
docker_image_url      = "564947779265.dkr.ecr.us-west-2.amazonaws.com/demo-repo:v1"
memory                = 512
desired_task_number   = 2
message               = "Hello World!!"
cpu                   = 256
env_name              = "dev"
ecr_repository_name   = "demo-repo"
container_name        = "ecs-container-name"
