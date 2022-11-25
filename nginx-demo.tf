resource "kubernetes_deployment" "nginx_demo" {
  metadata {
    name = "nginx-demo"
    labels = {
      app = "nginx-demo"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx-demo"
        }
      }

      spec {
        node_selector = {
          "type"        = "karpenter"
          "provisioner" = "default"
        }

        toleration {
          key      = "default"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        container {
          image = "nginx:1.21.6"
          name  = "nginx-demo"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_demo" {
  metadata {
    name = "nginx-demo"
  }
  spec {
    selector = {
      app = kubernetes_deployment.nginx_demo.metadata.0.labels.app
    }
    port {
      port        = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "nginx_demo" {
  metadata {
    name = "nginx-demo"
  }

  spec {
    min_replicas = 2
    max_replicas = 20

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "nginx-demo"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type  = "Utilization"
          average_utilization = "50"
        }
      }
    }
  }
}