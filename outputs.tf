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

output "gateway_id" {
  description = "Identifier for the secure web proxy gateway."
  value       = google_network_services_gateway.this.id
}

output "policy_id" {
  description = "Identifier of the secure web proxy gateway policy."
  value       = google_network_security_gateway_security_policy.this.id
}

output "rule_ids" {
  description = "Identifiers of the secure web proxy rules created."
  value       = { for rule_name, _ in var.rules : rule_name => google_network_security_gateway_security_policy_rule.this[rule_name].id }
}

output "url_list_ids" {
  description = "Identifiers of the secure web proxy url lists."
  value       = { for list_name, _ in var.url_lists : list_name => google_network_security_url_lists.this[list_name].id }
}

output "service_attachment_id" {
  description = "ID of the service attachment resource, if created."
  value       = try(google_compute_service_attachment.default[0].id, null)
}

output "project_id" {
  description = "The project ID where the Secure Web Proxy is deployed."
  value       = google_network_services_gateway.this.project
}

output "gateway_ip_addresses" {
  description = "The IP addresses assigned to the Secure Web Proxy gateway."
  value       = google_network_services_gateway.this.addresses
}

output "network" {
  description = "The VPC network associated with the gateway."
  value       = google_network_services_gateway.this.network
}

output "subnetwork" {
  description = "The specific subnetwork used by the gateway."
  value       = google_network_services_gateway.this.subnetwork
}

output "self_link" {
  description = "The URI of the created resource."
  value       = google_network_services_gateway.this.self_link
}

output "ports" {
  description = "Ports of the secure web proxy resource created."
  value       = google_network_services_gateway.this.ports
}