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

output "project_id" {
  description = "Project ID for the DNS response policy."
  value       = var.project_id
}

output "region" {
  description = "Project ID for the DNS response policy."
  value       = var.region
}

output "certificate_manager_id" {
  description = "Identifier of the certificate manager resource created for SWP."
  value       = google_certificate_manager_certificate.this.id
}

output "gateway_id" {
  description = "Identifier for the secure web proxy gateway."
  value       = module.secure_web_proxy.gateway_id
}

output "policy_id" {
  description = "Identifier of the secure web proxy gateway policy."
  value       = module.secure_web_proxy.policy_id
}

output "rule_ids" {
  description = "Identifiers of the secure web proxy rules created."
  value       = module.secure_web_proxy.rule_ids
}

output "url_list_ids" {
  description = "Identifiers of the secure web proxy url lists."
  value       = module.secure_web_proxy.url_list_ids
}
