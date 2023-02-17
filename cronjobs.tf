#---------------------------------------------------------------
# CronJobs to scale minReplicas up and down
#---------------------------------------------------------------

resource "kubernetes_cron_job" "nginx_scale_up" {
  metadata {
    name      = "nginx-scale-up"
    namespace = module.irsa.namespace
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "0,20,40 * * * *"
    starting_deadline_seconds     = 60
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 300
        template {
          metadata {
            labels = {
              component = "nginx-scale"
            }
          }
          spec {
            service_account_name = "kubectl-hpa"
            container {
              name    = "kubectl"
              env {
                name = "AWS_REGION"
                value = "${local.region}"
              }
              env {
                name = "CLUSTER_NAME"
                value = "${local.name}"
              }
              image   = "${aws_ecr_repository.cluster_repo.repository_url}:latest"
              command = ["/bin/sh", "-c", "kubectl patch hpa ${kubernetes_horizontal_pod_autoscaler.nginx_demo.metadata[0].name} -n nginx-demo -p '{\"spec\":{\"minReplicas\": 10}}'"]
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_cron_job" "nginx_scale_down" {
  metadata {
    name      = "nginx-scale-down"
    namespace = module.irsa.namespace
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "10,30,50 * * * *"
    starting_deadline_seconds     = 60
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 300
        template {
          metadata {
            labels = {
              component = "nginx-scale"
            }
          }
          spec {
            service_account_name = "kubectl-hpa"
            container {
              name    = "kubectl"
              env {
                name = "AWS_REGION"
                value = "${local.region}"
              }
              env {
                name = "CLUSTER_NAME"
                value = "${local.name}"
              }
              image   = "${aws_ecr_repository.cluster_repo.repository_url}:latest"
              command = ["/bin/sh", "-c", "kubectl patch hpa ${kubernetes_horizontal_pod_autoscaler.nginx_demo.metadata[0].name} -n nginx-demo -p '{\"spec\":{\"minReplicas\": 2}}'"]
            }
          }
        }
      }
    }
  }
}
