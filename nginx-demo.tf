resource "kubernetes_namespace" "nginx-demo" {
  metadata {
    name      = local.demo_namespace
  } 
}

resource "kubernetes_deployment" "nginx_demo" {
  metadata {
    name      = local.demo_name
    namespace = kubernetes_namespace.nginx-demo.metadata[0].name
    labels = {
      app = local.demo_name
    }
  }
  spec {
    replicas                  = 2
    progress_deadline_seconds = 300
    selector {
      match_labels = {
        app = local.demo_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.demo_name
        }
      }
      spec {
        node_selector = {
          "type"        = "karpenter"
          "provisioner" = "default-lt"
        }
        toleration {
          key      = "default-lt"
          operator = "Exists"
          effect   = "NoSchedule"
        }
        container {
          image = "nginx:1.21.6"
          name  = local.demo_name
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
  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
  timeouts {
    create = "5m"
  }
}

resource "kubernetes_service" "nginx_demo" {
  metadata {
    name      = local.demo_name
    namespace = kubernetes_namespace.nginx-demo.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.nginx_demo.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "nginx_demo" {
  metadata {
    name      = local.demo_name
    namespace = kubernetes_namespace.nginx-demo.metadata[0].name
  }
  spec {
    min_replicas = 2
    max_replicas = 20
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = local.demo_name
    }
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = "50"
        }
      }
    }
  }
}
