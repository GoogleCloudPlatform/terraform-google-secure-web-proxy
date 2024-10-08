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
  location                             = var.region
  addresses                            = var.ip_address != "" ? [var.ip_address] : null # Only supports 0 or 1 IP address.
  type                                 = "SECURE_WEB_GATEWAY"
  labels                               = var.labels
  ports                                = [443] # Gateways of type 'SECURE_WEB_GATEWAY' are limited to 1 port.
  scope                                = var.scope != "" ? var.scope : var.region
  certificate_urls                     = var.certificate_urls
  gateway_security_policy              = google_network_security_gateway_security_policy.this.id
  network                              = var.network
  subnetwork                           = var.subnetwork
  delete_swg_autogen_router_on_destroy = var.delete_swg_autogen_router_on_destroy
}

# Gateway Security Policy
resource "google_network_security_gateway_security_policy" "this" {
  name                  = lookup(var.policy, "name", "${var.gateway_name}-policy")
  provider              = google-beta
  project               = var.project_id
  location              = var.region
  description           = lookup(var.policy, "description", "Policy for SWP gateway - ${var.gateway_name}")
  tls_inspection_policy = lookup(var.policy, "tls_inspection_policy", null) != null ? google_network_security_tls_inspection_policy.this[0].id : null
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
  tls_inspection_enabled  = lookup(var.policy, "tls_inspection_policy", null) != null ? true : false
  depends_on = [
    google_network_security_url_lists.this
  ]
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
