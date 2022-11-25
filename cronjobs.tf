#---------------------------------------------------------------
# CronJobs to scale minReplicas up and down
#---------------------------------------------------------------

resource "kubernetes_cron_job" "nginx_scale_up" {
  metadata {
    name = "nginx-scale-up"
    namespace = kubernetes_namespace.nginx_demo.metadata[0].name
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "0,30 * * * *"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name    = "kubectl"
              image   = "${aws_ecr_repository.cluster_repo.name}:latest"
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
    name = "nginx-scale-down"
    namespace = kubernetes_namespace.nginx_demo.metadata[0].name
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "15,45 * * * *"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name    = "kubectl"
              image   = "${aws_ecr_repository.cluster_repo.name}:latest"
              command = ["/bin/sh", "-c", "kubectl patch hpa ${kubernetes_horizontal_pod_autoscaler.nginx_demo.metadata[0].name} -n nginx-demo -p '{\"spec\":{\"minReplicas\": 2}}'"]
            }
          }
        }
      }
    }
  }
}