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

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "this" {
  private_key_pem = tls_private_key.this.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "terraform module example"
  }

  validity_period_hours = 5

  allowed_uses = [
    "server_auth",
  ]
}

resource "google_certificate_manager_certificate" "this" {
  name     = "swp-certificate-${var.region}"
  project  = var.project_id
  location = var.region
  self_managed {
    pem_certificate = tls_self_signed_cert.this.cert_pem
    pem_private_key = tls_private_key.this.private_key_pem
  }
}
