[
  {
    "name": "${service_name}-${env}",
    "image": "${image}",
    "essential": true,
    "portMappings": [
      {
        "containerPort":8000,
        "hostPort": 8000
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/usr/app/${dump_dir}",
        "sourceVolume": "${dump_dir}",
        "readOnly": false
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${service_name}-${env}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "${service_name}-${env}-ecs"
      }
    }
  }
]