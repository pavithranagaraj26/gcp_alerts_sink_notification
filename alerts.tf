provider "google" {
  version = "~>3.7"
  project = var.project
  region  = var.region
  zone    = var.zone
}

variable "project" {
  description = "The project in which to hold the components"
  type        = string
  default = "<PROJECT_ID>"
}

variable "region" {
  description = "The region in which to create the VPC network"
  type        = string
  default = "us-central1"
}

variable "zone" {
  description = "The zone in which to create the Kubernetes cluster. Must match the region"
  type        = string
  default = "us-central1-a"
}

resource "google_logging_metric" "logging_metric_firewall_deletion" {
  name   = "firewall-deletion"
  filter = "resource.type=gce_firewall_rule AND protoPayload.authenticationInfo.principalEmail=<ACTION_EMAIL> AND protoPayload.methodName=v1.compute.firewalls.delete"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}


#Creating alertpolicy

# resource "google_monitoring_notification_channel" "slack" {
#   display_name = "Test Slack Channel"
#   type         = "slack"
#   labels = {
#     "channel_name" = "#tf-gitops-channel"
#   }
#   sensitive_labels {
#     auth_token = "present.txt"
#   }
# }

# resource "google_monitoring_notification_channel" "slack" {
#   display_name = "Slack-Channel"
#   type         = "slack"

#   labels = {
#     auth_token   = "${var.slack_hook}"
#     channel_name = "${var.slack_channel}"
#   }
# }

resource "google_monitoring_notification_channel" "email0" {
  display_name = "email-pavithra"
  type = "email"
  labels = {
    email_address = "pavithra@gmail.com"
  }
}

#alert policy for projectownershiplog
resource "google_monitoring_alert_policy" "alert_policy_project_ownership" {
 notification_channels = [
   #google_monitoring_notification_channel.slack.name,
   google_monitoring_notification_channel.email0.name]
  display_name = "firewall-deletion-alert"
  combiner     = "OR"
  conditions {
    display_name = "firewall deletion condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/firewall-deletion\" AND resource.type=\"global\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_COUNT"
      }
    }
  }

  user_labels = {
    alert = "firewall_deletion"
  }
}
