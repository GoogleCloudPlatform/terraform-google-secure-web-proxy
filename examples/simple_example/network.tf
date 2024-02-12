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

resource "random_string" "suffix" {
  length  = 4
  upper   = "false"
  lower   = "true"
  numeric = "false"
  special = "false"
}

resource "google_compute_network" "this" {
  name                    = "cft-cloud-swp-test-${random_string.suffix.result}"
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Subnet in which the SWP will be created. The SWP static IP address will be created from this subnet.
resource "google_compute_subnetwork" "resource_subnet" {
  name          = "swp-test-subnet-resource"
  project       = var.project_id
  region        = var.region
  ip_cidr_range = "10.2.0.0/22"
  network       = google_compute_network.this.self_link
}

# A proxy subnet is required by SWP to operate.
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "swp-test-subnet-proxyonly"
  project       = var.project_id
  region        = var.region
  ip_cidr_range = "10.3.0.0/22"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.this.self_link
}
