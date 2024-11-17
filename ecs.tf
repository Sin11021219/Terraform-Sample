//TerraformでECS作成
$ git pull origin main
$ git checkout -b feat/ecs
$ touch ecs.tf

//タスク定義の作成
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = local.app
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.ecs.arn
  task_role_arn      = aws_iam_role.ecs_task.arn
  
  container_definitions =  <<CONTAINER
[
 {
    "name": "${local.app}",
    "image": "medpeer/health_check:latest",
    "portmapping" : [
     {
       "hostPort": 8080,
       "containerPort": 8080
     }
   ],
     "logConfiguration" : {
         "logDriver" : "awslogs", 
         "options" : {
            "awslogs-group" :"${aws_cloudwatch_log_group.cloudwatch_log_group.name}",
            "awslogs-region" : "${local.region}" ,
            "awslogs-stream-prefix : "${local.app}"
        } 
    },
    "environment" : [
     {
        "name" : "NEGIX_PORT",
        "value" : "8080"
     },
     {
        "name" : "HEALTH_CHECK_PATH",
        "value" : "/health_checks"
     }
   ]
 }

]
CONTAINERS
}

//サービスの作成

resource "aws_ecs_service" "ecs_service" {
   name = local.app
   launch_type ="FARGATE"
   cluster = aws_ecs_cluster.ecs_cluster.id
   task_definition = aws_ecs_task_definition.ecs_task_definition.arn
   desired_count = 2
   network_configuration {
      subnets = module.vpc.private_subnets
      security_groups = [aws_security_group.ecs.id]
   }
   load_balancer {
      target_group_arn = aws_lb_target_group.target_group.arn
      container_arn = local.app
      container_port = 8080

   }
   depends_on = [aws_lb_listener_rule.alb_listener_rule]
   
   }

//クラスタの作成

resource "aws_ecs_cluster" "ecs_cluster" {
      name = local.app
}

//GitHUbにpush
$ git  add . $$ git commit -m "run a Dummy container with ECS"
$ git push origin feat/ecs

//復習2回目
//Terraformを使用してコンテナをecsにデプロイ
$ git pull origin main
$ git checkout -b feat/ecs
$ touch ecs.tf

//タスク定義の作成
resource "aws_ecs_task_definition" "ecs_task_definition" {
   family       = local.app
   network_mode = "awsvpc"
   cpu          = 256
   memory       = 512
   requires_compatibilities = ["FARGATE"]
   execution_role_arn = aws_iam_role.ecs.arn
   task_role_arn      = aws_iam_role.ecs_task.arn
   container_definition = <<CONTAINERS
[
   {
      "name": "${local.app}",
      "image": "medpeer/health_check:latest",
      "portMapppings": [
         {
            "hostPort": 8080,
            "containerPort": 8080

         }
      ],
      "logConfiguration": {
         "logDriver": "awslogs",
         "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.cloudwatch_log_group.name}",
            "awslogs-region" "${local.region}",
            "awslogs-stream-prefix": "${local.app}"

         }
      },
      "environment": [
         {
            "name": "NGINX_PORT",
            "value": "8080"

         },
         {
            "name": "HEALTH_CHECK_PATH",
            "value": "/health_checks"
         }
      ]

   }
]
CONTAINERS
}
//サービスの作成
resource "aws_ecs_service" "ecs_service" {
   name = local.app
   launch_type = "FARGATE"
   cluster = aws_ecs_cluster.ecs_cluster.id
   task_definition = aws_ecs_task_definition.ecs_task_definition.arn
   desired_count = 2
   network_configuration {
      subnets = module.vpc.private_subnets
      security_groups = [aws_security_group.ecs.id]

   }
   load_balancer {
      target_group_arn = aws_lb_target_group.target_group.arn
      container_name = local.app
      container_port = 8080 
   }
     depends_on = [aws_lb_listener_rule.alb_listner_rule]
}
//クラスタの作成
resource "aws_ecs_cluster" "ecs_cluster" {
   name = local.app
}

//GitHUbにpush
$ git add . git commit -m "run a Dummy container with ECS "
$ git push origin feat/ecs

//復習3回目
//Terraformを使用してコンテナをecsにデプロイ
$  git pull origin main
$  git checkout -b feat/ecs
$ touch ecs.tf
//タスク定義の作成
resource "aws_ecs_task_definition" "ecs_tsk_definition"  {
   family                    = local.app
   network_mode              = "awsvpc"
   cpu                       = 256
   memory                    = 512
   requirerd_compatibilities = [ "FARGATE" ]
   execution_role_arn        = aws_iam_role.ecs.arn
   task_role.arn             = aws_iam_role.ecs_task.arn

   container_definition      = <<CONTAINERS

   [
      {
         "name": "${local.app}",
         "image": "medpeer/health_check:latest",
         "portMapping": [
            {
            "hostPort": 8080,
            containerPort: 8080
            }
         ],
          "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
               "awslogs-group"        : "${aws_cloudwatch_log_group.cloudwatch_log_group.name}",
               "awslogs-region"       : "${local.region}",
               "awslogs-stream-prefix": "app"
            }
          },
          "environment": [
            {
                "name": "NGINX_PORT",
               "value": "8080"
            },
          {
                "name": "HEALTH_CHECK_PATH",
                "value": "/health_checks"
          }  
      
       
          ]
      }
   ]
   CONTAINERS
} 

//サービスの作成
resource "aws_ecs_service" "ecs_service" {
          name     = local.app
   launch_type     = "FARGATE"
   cluster         = aws_ecs_cluster.ecs_cluster.id
   task_definition = aws_ecs_task_definition.ecs_task_definition.arn
   desired_count   = 2
   network_configuration {
      subnets      = module.vpc.private_subnets
    security_group = [aws_security_group.ecs.id]
   }
 }
 load_balancer {
   target_group_arn = aws_lb_target_group.target_group.arn
   container_name   = local.app
   container_port   = 8080
 }
 depends_on = [aws_lb_listener_rule.alb.listener_rule]

//クラスタの作成
resource "aws_ecs_cluster" "ecs_cluster" {
   name = local.app
}

//GtHUbにコミット
$ git add . && git commit -m "run a Dummy container with ECS"
$ git push origin feat/ecs

