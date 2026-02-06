/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Network Services Gateway
resource "google_network_services_gateway" "this" {
  name                                 = var.gateway_name
  project                              = var.project_id
  description                          = var.description
  location                             = var.region
  addresses                            = var.ip_address != "" ? [var.ip_address] : null # Only supports 0 or 1 IP address.
  type                                 = "SECURE_WEB_GATEWAY"
  labels                               = var.labels
  ports                                = [443] # Gateways of type 'SECURE_WEB_GATEWAY' are limited to 1 port.
  routing_mode                         = var.next_hop_routing_mode ? "NEXT_HOP_ROUTING_MODE" : null
  scope                                = var.scope != "" ? var.scope : var.region
  certificate_urls                     = var.certificate_urls
  gateway_security_policy              = google_network_security_gateway_security_policy.this.id
  network                              = var.network
  subnetwork                           = var.subnetwork
  delete_swg_autogen_router_on_destroy = var.delete_swg_autogen_router_on_destroy
}

# Optional PSC Service Attachment
resource "google_compute_service_attachment" "default" {
  count          = var.service_attachment == null ? 0 : 1
  project        = var.project_id
  region         = var.region
  name           = var.gateway_name
  description    = coalesce(var.service_attachment.description, "Service attachment for SWP ${var.gateway_name}")
  target_service = google_network_services_gateway.this.self_link
  nat_subnets    = var.service_attachment.nat_subnets
  connection_preference = (
    var.service_attachment.automatic_accept_all_connections
    ? "ACCEPT_AUTOMATIC"
    : "ACCEPT_MANUAL"
  )
  consumer_reject_lists = var.service_attachment.consumer_reject_lists
  domain_names = (
    var.service_attachment.domain_name == null
    ? null
    : [var.service_attachment.domain_name]
  )
  enable_proxy_protocol = var.service_attachment.enable_proxy_protocol
  reconcile_connections = var.service_attachment.reconcile_connections
  dynamic "consumer_accept_lists" {
    for_each = var.service_attachment.consumer_accept_lists
    iterator = accept
    content {
      project_id_or_num = accept.key
      connection_limit  = accept.value
    }
  }
}

# Gateway Security Policy
resource "google_network_security_gateway_security_policy" "this" {
  name                  = lookup(var.policy, "name", "${var.gateway_name}-policy")
  provider              = google-beta
  project               = var.project_id
  location              = var.region
  description           = lookup(var.policy, "description", "Policy for SWP gateway - ${var.gateway_name}")
  tls_inspection_policy = lookup(var.policy, "tls_inspection_policy", null) != null ? google_network_security_tls_inspection_policy.this[0].id : null
  lifecycle {
    create_before_destroy = true
  }
}

# Gateway Security Policy Rules
resource "google_network_security_gateway_security_policy_rule" "this" {
  for_each                = var.rules
  name                    = each.key
  project                 = var.project_id
  location                = var.region
  gateway_security_policy = google_network_security_gateway_security_policy.this.name
  enabled                 = each.value.enabled
  description             = each.value.description
  priority                = each.value.priority
  session_matcher         = each.value.session_matcher
  application_matcher     = each.value.application_matcher
  basic_profile           = each.value.basic_profile
  depends_on = [
    google_network_security_url_lists.this
  ]
  lifecycle {
    # add a trigger to recreate rules, if the policy is replaced
    # because it is referenced by name, this won't happen automatically, as it would, if referenced by id
    replace_triggered_by = [
      google_network_security_gateway_security_policy.this.id
    ]
  }
}

# TLS Inspection Policy
resource "google_network_security_tls_inspection_policy" "this" {
  count    = lookup(var.policy, "tls_inspection_policy", null) != null ? 1 : 0
  provider = google-beta
  name     = lookup(var.policy.tls_inspection_policy, "name")
  project  = var.project_id
  location = var.region
  ca_pool  = lookup(var.policy.tls_inspection_policy, "ca_pool")
}

# URL List - The created list can be within the swp policy rules.
resource "google_network_security_url_lists" "this" {
  for_each    = var.url_lists
  project     = var.project_id
  name        = each.key
  location    = var.region
  description = each.value.description
  values      = each.value.values
}
