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

variable "project_id" {
  type        = string
  description = "The Google Cloud project ID where the secure web proxy will be deployed."
}

variable "gateway_name" {
  type        = string
  description = "The name of secure web proxy gateway to be created."
}

variable "region" {
  type        = string
  description = "The region in which the secure web proxy components will be created."
}

variable "ip_address" {
  type        = string
  description = "Static IP reservation for SWP. When no address is provided, an IP from the input subnetwork is allocated."
  default     = ""
}

variable "scope" {
  type        = string
  description = "Scope determines how configuration across multiple gateway instances are merged. The configuration for multiple gateway instances with the same scope will be merged as presented as a single coniguration to the proxy. Defaults to name of the region. Max length - 64 characters."
  default     = ""
}

variable "certificate_urls" {
  type        = list(string)
  description = "A fully-qualified certificates URL reference. The proxy presents a Certificate (selected based on SNI) when establishing a TLS connection."
}

variable "network" {
  type        = string
  description = "URI of the subnetwork for which this secure web proxy will be created."
}

variable "subnetwork" {
  type        = string
  description = "URI of the subnetwork for which this secure web proxy will be created."
}

variable "delete_swg_autogen_router_on_destroy" {
  type        = bool
  description = "boolean option to also delete auto generated router by the gateway creation."
  default     = true
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Map of labels for secure web proxy gateway."
}

variable "policy" {
  type = object({
    name        = string
    description = string
    tls_inspection_policy = optional(object({
      name    = string
      ca_pool = string
    }))
  })
  description = "Gateway security policy configuration."
}

variable "rules" {
  type = map(object({
    enabled             = optional(bool, true)
    description         = optional(string, "SWP rules created by terraform")
    priority            = number                                                # Lower number corresponds to higher precedence.
    session_matcher     = optional(string, "inIpRange(source.ip, '0.0.0.0/0')") # By default, open all source ips.
    application_matcher = optional(string)
    basic_profile       = optional(string, "ALLOW") # Supports ALLOW or DENY.string
  }))
  description = "Security policy rules configuration."
  default     = null
}

variable "url_lists" {
  type = map(object({
    description = optional(string, "URL lists created by terraform")
    values      = list(string)
  }))
  default     = {}
  description = "URL lists that can be used within SWP rules. Attribute values supports: FQDNs and URLs."
}
