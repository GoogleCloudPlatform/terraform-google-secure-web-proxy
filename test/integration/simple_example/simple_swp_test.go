// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package secure_web_proxy

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSecureWebProxy(t *testing.T) {
	swp := tft.NewTFBlueprintTest(t)

	swp.DefineVerify(func(assert *assert.Assertions) {
		swp.DefaultVerify(assert)
		projectId := swp.GetStringOutput("project_id")
		region := swp.GetStringOutput("region")
		gcOpts := gcloud.WithCommonArgs([]string{"--project", projectId, "--location", region, "--format", "json"})

		tests := []struct {
			name             string
			command          string
			jsonKey          string
			moduleOutput     string
			moduleOutputType string
		}{
			{
				name:             "swp gateway creation",
				command:          "network-services gateways list",
				jsonKey:          "name",
				moduleOutput:     "gateway_id",
				moduleOutputType: "string",
			},
			{
				name:             "swp policy creation",
				command:          "network-security gateway-security-policies list",
				jsonKey:          "name",
				moduleOutput:     "policy_id",
				moduleOutputType: "string",
			},
			{
				name:             "swp rules creation",
				command:          "network-security gateway-security-policies rules list --gateway-security-policy=simple-proxy-policy",
				jsonKey:          "name",
				moduleOutput:     "rule_ids",
				moduleOutputType: "map",
			},
			{
				name:             "url lists creation",
				command:          "network-security url-lists list",
				jsonKey:          "name",
				moduleOutput:     "url_list_ids",
				moduleOutputType: "map",
			},
		}

		var want []string
		for _, test := range tests {
			t.Run(test.name, func(t *testing.T) {
				switch test.moduleOutputType {
				case "string":
					want = []string{swp.GetStringOutput(test.moduleOutput)}
				case "map":
					outputMap := terraform.OutputMap(t, swp.GetTFOptions(), test.moduleOutput)
					fmt.Println(outputMap)
					for _, v := range outputMap {
						want = append(want, v)
					}
				default:
					t.Errorf("Invalid comparision type in test cases.")
				}

				gotList := gcloud.Run(t, test.command, gcOpts).Array()
				for _, item := range gotList {
					assert.Contains(want, item.Get(test.jsonKey).String(), test.name)
				}
			})
		}

	})
	swp.Test()
}
