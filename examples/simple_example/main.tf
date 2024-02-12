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

module "secure_web_proxy" {
  source = "../.."

  gateway_name     = "simple-swp"
  project_id       = var.project_id
  region           = var.region
  certificate_urls = [google_certificate_manager_certificate.this.id]
  network          = google_compute_network.this.id
  subnetwork       = google_compute_subnetwork.resource_subnet.id

  policy = {
    name        = "simple-proxy-policy"
    description = "Policy for secure web proxy"
  }

  rules = {
    "allow-example1-com" = {
      enabled         = true
      description     = "Allow example1.com host traffic."
      priority        = 100
      session_matcher = "host() == 'example1.com'"
      basic_profile   = "ALLOW"
    },
    "allow-url-list-1" = {
      enabled         = true
      description     = "All the URLs in URL list test-url-list-1."
      priority        = 102
      session_matcher = "inUrlList(host(), 'projects/${var.project_id}/locations/${var.region}/urlLists/test-url-list-1')"
      basic_profile   = "ALLOW"
    },
  }


  url_lists = {
    "test-url-list-1" = {
      description = "url-list-1 description."
      values      = ["www.example.com", "about.example.com", "github.com/example-org/*"]
    }
  }
}
