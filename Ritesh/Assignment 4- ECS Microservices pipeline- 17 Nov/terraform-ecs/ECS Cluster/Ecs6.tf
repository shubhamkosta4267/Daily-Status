resource "aws_ecs_task_definition" "ECS6" {
  family                   = "ECS6"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "${data.aws_iam_role.ecs-service.arn}"



 container_definitions = jsonencode([
    {
      name   = "html6_container"
      image  = "033746436249.dkr.ecr.us-east-2.amazonaws.com/dockerfile6:latest"
      cpu    = 256
      memory = 512
      portMappings = [
        {
          containerPort = 80
          
        }
      ]
    }
  ])
}
# ECS SERVICE 6
resource "aws_ecs_service" "ecs6" {
  name            = var.service6
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.ecs6.id}"
  desired_count   = 2
  launch_type     = "FARGATE"




  network_configuration {
    subnets          = ["${aws_subnet.pub-a.id}", "${aws_subnet.pub-b.id}"]
    security_groups  = ["${aws_security_group.sg1.id}"]
    assign_public_ip = true
  }



 load_balancer {
    target_group_arn = "${aws_lb_target_group.tg5-group.arn}"
    container_name   = "html6_container"
    container_port   = "80"
  }
}

resource "aws_codebuild_project" "prod6" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "prod6"
  queued_timeout = 480
  service_role   = aws_iam_role.codebuild_role.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    
    type                   = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

}



# ----------------------------PIPELINE ---------------------------------

resource "aws_codepipeline" "pipeline6" {
  name     = "assignment_pipeline6"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }
  # SOURCE
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "Ritesh2912"
        Repo       = "6_ECS_Microservices"
        Branch     = "master"
        OAuthToken = "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"
      }
    }
  }
  # BUILD
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = "prod6"
      }
    }
  }
  # DEPLOY
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = "Cluster-prod"
        ServiceName = var.service6
        FileName    = "imagedefinitions6.json"
      }
    }
  }
}
