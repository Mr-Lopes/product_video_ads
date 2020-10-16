#!/bin/bash

# Copyright 2020 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#    https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

gsutil -m cp -r gs://product-video-ads/c/frontend/dist .
gsutil cp gs://product-video-ads/c/frontend/app.yaml app.yaml

echo -n 'Type the project name: '
read CLOUD_PROJECT_NAME

gcloud config set project $CLOUD_PROJECT_NAME
gcloud config list

echo 'Enabling some needed APIs...'
gcloud services enable drive.googleapis.com
gcloud services enable sheets.googleapis.com

echo 'Installing Web Frontend on App Engine...'

echo -n 'Type the (OAuth Web) Client ID: '
read FRONTEND_CLIENT_ID
export FRONTEND_CLIENT_ID=$FRONTEND_CLIENT_ID

echo -n 'Type API Key: '
read FRONTEND_API_KEY
export FRONTEND_API_KEY=$FRONTEND_API_KEY

mv dist/assets/js/env.js dist/assets/js/env.js.orig
envsubst < dist/assets/js/env.js.orig > dist/assets/js/env.js
rm dist/assets/js/env.js.orig

gcloud app deploy
gcloud app browse