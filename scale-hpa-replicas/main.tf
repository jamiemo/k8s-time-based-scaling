resource "kubernetes_cron_job" "scale_min_replicas" {
  metadata {
    name      = var.name
    namespace = var.service-account-namespace
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = var.schedule
    starting_deadline_seconds     = 60
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 300
        template {
          metadata {
          }
          spec {
            service_account_name = var.service-account-name
            container {
              name    = "kubectl"
              image   = "${var.kubectl-repo}:latest"
              command = ["/bin/sh", "-c", "kubectl patch hpa ${var.horizontal-pod-autoscaler-name} -n ${var.horizontal-pod-autoscaler-namespace} -p '{\"spec\":{\"minReplicas\": ${var.min-replicas}}}'"]
            }
          }
        }
      }
    }
  }
}
